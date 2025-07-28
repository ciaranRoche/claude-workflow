# Design Document: Magic The Gathering Score Tracker

**Date**: 2025-07-28T15:33:00Z  
**Version**: 1.0  
**Project**: MTG Score Tracker Full-Stack Application  
**Target**: Private friend group deployment on k3s

## 1. Executive Summary

This design document outlines the architecture and implementation plan for a Magic: The Gathering score tracking application. The system enables real-time score tracking during in-person MTG games, maintains comprehensive game history, and provides private analysis tools for gameplay improvement. Built with modern web technologies optimized for 2025 deployment practices.

### 1.1 Key Design Principles
- **Real-time First**: WebSocket-based live updates for seamless gameplay
- **Privacy by Design**: Invite-only access with private personal analytics
- **Mobile Optimized**: Touch-friendly interface for in-person gaming
- **Resource Efficient**: Optimized for k3s deployment with minimal overhead
- **Extensible Architecture**: Clean separation for future enhancements

## 2. System Architecture

### 2.1 High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Clients   │    │   API Gateway   │    │   Backend API   │
│  (Next.js App)  │◄──►│    (Ingress)    │◄──►│   (Node.js)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         │              WebSocket Connection             │
         └──────────────────────────────────────────────┘
                                     │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
           ┌─────────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
           │  PostgreSQL    │  │    Redis     │  │  Firebase   │
           │   (Primary)    │  │  (Caching)   │  │    Auth     │
           └────────────────┘  └─────────────┘  └─────────────┘
```

### 2.2 Component Architecture

#### Frontend Layer (React + Next.js 15)
- **Pages**: Authentication, Dashboard, Active Match, Game History
- **Components**: Life Counter, Match Setup, Player Management, History Browser
- **State Management**: Zustand for local state, Socket.io for real-time updates
- **UI Framework**: Tailwind CSS with custom MTG-themed components

#### Backend Layer (Node.js + Express)
- **API Routes**: REST endpoints for CRUD operations
- **WebSocket Server**: Socket.io for real-time match communication
- **Authentication Middleware**: Firebase Auth token validation
- **Database Layer**: PostgreSQL with Redis caching

#### Data Layer
- **Primary Database**: PostgreSQL 16 for transactional data
- **Cache Layer**: Redis 7 for sessions and real-time state
- **Authentication**: Firebase Authentication with Google OAuth

### 2.3 Deployment Architecture

```
k3s Cluster Layout:
┌─────────────────────────────────────────────────────────────┐
│  Namespace: mtg-tracker                                     │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Ingress   │  │  Frontend   │  │   Backend   │        │
│  │ (TLS Term)  │  │ (Next.js)   │  │  (Node.js)  │        │
│  │             │  │ 512MB/0.5C  │  │ 768MB/0.5C  │ x2     │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐                         │
│  │ PostgreSQL  │  │    Redis    │                         │
│  │ 2GB/1CPU    │  │ 512MB/0.5C  │                         │
│  │ 10GB PVC    │  │  1GB PVC    │                         │
│  └─────────────┘  └─────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

## 3. Database Design

### 3.1 PostgreSQL Schema

#### Users Table
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    firebase_uid VARCHAR(128) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    google_profile JSONB,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP DEFAULT NOW()
);
```

#### Decks Table
```sql
CREATE TABLE decks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    format VARCHAR(20) NOT NULL CHECK (format IN ('standard', 'commander')),
    colors VARCHAR(10), -- e.g., 'WUBRG'
    description TEXT,
    strategy_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Matches Table
```sql
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    format VARCHAR(20) NOT NULL CHECK (format IN ('standard', 'commander')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    winner_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    match_code VARCHAR(10) UNIQUE NOT NULL, -- join code
    metadata JSONB -- format-specific settings
);
```

#### Match Players Table
```sql
CREATE TABLE match_players (
    id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    deck_id INTEGER REFERENCES decks(id) ON DELETE SET NULL,
    starting_life INTEGER NOT NULL,
    current_life INTEGER,
    position INTEGER, -- player order
    eliminated_at TIMESTAMP,
    elimination_reason VARCHAR(50),
    UNIQUE(match_id, user_id)
);
```

#### Game Events Table
```sql
CREATE TABLE game_events (
    id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(id) ON DELETE CASCADE,
    player_id INTEGER REFERENCES match_players(id) ON DELETE CASCADE,
    event_type VARCHAR(30) NOT NULL, -- 'life_change', 'commander_damage', 'elimination'
    event_data JSONB NOT NULL, -- { amount: -5, from_player: 2, reason: 'combat' }
    timestamp TIMESTAMP DEFAULT NOW()
);
```

#### Personal Notes Table
```sql
CREATE TABLE personal_notes (
    id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    note_text TEXT NOT NULL CHECK (LENGTH(note_text) <= 500),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(match_id, user_id)
);
```

### 3.2 Redis Schema

#### Session Storage
```
Key: session:{user_id}
Value: {
    firebase_token: "...",
    expires_at: timestamp,
    preferences: { theme: "dark", notifications: true }
}
TTL: 7 days
```

#### Active Match State
```
Key: match:{match_id}:state
Value: {
    players: [{id, name, life, commander_damage}],
    last_update: timestamp,
    active_connections: [user_ids]
}
TTL: 24 hours
```

#### WebSocket Room Management
```
Key: room:{match_id}:connections
Value: Set of socket_ids
TTL: 6 hours
```

### 3.3 Database Indexing Strategy

```sql
-- Performance indexes
CREATE INDEX idx_matches_created_by_date ON matches(created_by, started_at DESC);
CREATE INDEX idx_match_players_user_date ON match_players(user_id, match_id);
CREATE INDEX idx_game_events_match_time ON game_events(match_id, timestamp);
CREATE INDEX idx_decks_user_format ON decks(user_id, format);
CREATE INDEX idx_personal_notes_user_match ON personal_notes(user_id, match_id);

-- Full-text search on notes
CREATE INDEX idx_personal_notes_search ON personal_notes USING gin(to_tsvector('english', note_text));
```

## 4. API Design

### 4.1 REST API Endpoints

#### Authentication
```
POST   /api/auth/login          # Firebase token validation
POST   /api/auth/logout         # Session cleanup
GET    /api/auth/me             # Current user profile
POST   /api/auth/invite         # Generate invite link (admin only)
```

#### User Management
```
GET    /api/users               # List users (admin only)
PUT    /api/users/me            # Update current user profile
GET    /api/users/me/stats      # Personal statistics
```

#### Deck Management
```
GET    /api/decks               # List user's decks
POST   /api/decks               # Create new deck
PUT    /api/decks/:id           # Update deck
DELETE /api/decks/:id           # Delete deck
GET    /api/decks/:id/stats     # Deck performance statistics
```

#### Match Management
```
GET    /api/matches             # List matches (with pagination)
POST   /api/matches             # Create new match
GET    /api/matches/:id         # Get match details
PUT    /api/matches/:id         # Update match (end game, etc.)
POST   /api/matches/:id/join    # Join match via code
DELETE /api/matches/:id/leave   # Leave active match
```

#### Game History
```
GET    /api/matches/:id/events  # Get match event timeline
GET    /api/matches/:id/replay  # Get match replay data
POST   /api/matches/:id/notes   # Add personal note
PUT    /api/matches/:id/notes   # Update personal note
```

### 4.2 WebSocket Events

#### Connection Management
```javascript
// Client → Server
socket.emit('join_match', { matchId, userId, token });
socket.emit('leave_match', { matchId });

// Server → Client
socket.emit('match_joined', { matchData, players, gameState });
socket.emit('player_connected', { playerId, playerName });
socket.emit('player_disconnected', { playerId, reason });
```

#### Game Events
```javascript
// Client → Server
socket.emit('update_life', { 
    matchId, 
    playerId, 
    newLife, 
    previousLife, 
    timestamp 
});

socket.emit('commander_damage', {
    matchId,
    fromPlayerId,
    toPlayerId,
    damage,
    timestamp
});

// Server → All Clients in Match
socket.emit('life_updated', {
    playerId,
    newLife,
    change,
    timestamp
});

socket.emit('game_event', {
    type: 'elimination',
    playerId,
    reason,
    timestamp
});
```

#### Match State
```javascript
// Server → Client
socket.emit('match_state', {
    players: [
        {
            id, name, life, 
            commanderDamage: {}, 
            isEliminated, 
            isConnected
        }
    ],
    gameEvents: [...],
    lastUpdate: timestamp
});
```

## 5. User Interface Design

### 5.1 Page Structure

#### Authentication Flow
```
/login                   # Google OAuth login page
/invite/:code           # Invite link acceptance
/register              # Complete profile after OAuth
```

#### Main Application
```
/dashboard             # Personal stats and recent games
/matches               # Active and joinable matches
/matches/new           # Create new match
/matches/:id           # Live match interface
/matches/:id/history   # Match details and timeline
/history               # Personal game history
/decks                 # Deck management
/settings              # User preferences
```

### 5.2 Key UI Components

#### Live Match Interface
```javascript
const LiveMatch = () => {
  return (
    <div className="match-container">
      <MatchHeader 
        format={match.format}
        duration={matchDuration}
        players={players}
      />
      
      <PlayerGrid>
        {players.map(player => (
          <PlayerCard
            key={player.id}
            player={player}
            isCurrentUser={player.id === currentUser.id}
            onLifeChange={handleLifeChange}
            commanderDamage={getCommanderDamage(player)}
          />
        ))}
      </PlayerGrid>
      
      <MatchActions>
        <UndoButton />
        <PauseMatchButton />
        <EndMatchButton />
      </MatchActions>
    </div>
  );
};
```

#### Life Counter Component
```javascript
const LifeCounter = ({ 
  currentLife, 
  onLifeChange, 
  disabled, 
  canUndo 
}) => {
  return (
    <div className="life-counter">
      <div className="life-display">
        {currentLife}
      </div>
      
      <div className="life-controls">
        <Button 
          onClick={() => onLifeChange(-1)}
          disabled={disabled}
          className="life-minus"
        >
          -1
        </Button>
        
        <Button 
          onClick={() => onLifeChange(-5)}
          disabled={disabled}
          className="life-minus-five"
        >
          -5
        </Button>
        
        <Button 
          onClick={() => onLifeChange(1)}
          disabled={disabled}
          className="life-plus"
        >
          +1
        </Button>
        
        <Button 
          onClick={() => onLifeChange(5)}
          disabled={disabled}
          className="life-plus-five"
        >
          +5
        </Button>
      </div>
      
      {canUndo && (
        <UndoButton 
          onClick={handleUndo}
          className="undo-life-change"
        />
      )}
    </div>
  );
};
```

### 5.3 Responsive Design Strategy

#### Breakpoints
```css
/* Mobile First Approach */
.match-container {
  padding: 1rem;
  
  /* Tablet: 768px+ */
  @media (min-width: 768px) {
    padding: 2rem;
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
  
  /* Desktop: 1024px+ */
  @media (min-width: 1024px) {
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

#### Touch Optimization
```css
.life-controls button {
  min-height: 44px; /* iOS touch target minimum */
  min-width: 44px;
  font-size: 1.2rem;
  margin: 0.5rem;
  border-radius: 8px;
  
  /* Touch feedback */
  transition: transform 0.1s ease;
}

.life-controls button:active {
  transform: scale(0.95);
}
```

## 6. Real-Time Implementation

### 6.1 WebSocket Architecture

#### Connection Management
```javascript
class MatchSocketManager {
  constructor() {
    this.socket = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelays = [1000, 2000, 4000, 8000, 8000];
  }
  
  connect(matchId, userId, token) {
    this.socket = io('/matches', {
      auth: { token },
      query: { matchId, userId }
    });
    
    this.setupEventHandlers();
    this.setupReconnectionLogic();
  }
  
  setupReconnectionLogic() {
    this.socket.on('disconnect', (reason) => {
      if (reason === 'io server disconnect') {
        // Server disconnected, manual reconnection needed
        this.handleReconnection();
      }
      // Else: automatic reconnection by Socket.io
    });
  }
  
  handleReconnection() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      const delay = this.reconnectDelays[this.reconnectAttempts];
      
      setTimeout(() => {
        this.reconnectAttempts++;
        this.socket.connect();
      }, delay);
    }
  }
}
```

#### State Synchronization
```javascript
const useMatchState = (matchId) => {
  const [matchState, setMatchState] = useState(null);
  const [connected, setConnected] = useState(false);
  const socketRef = useRef(null);
  
  useEffect(() => {
    socketRef.current = new MatchSocketManager();
    
    socketRef.current.on('match_state', (state) => {
      setMatchState(state);
    });
    
    socketRef.current.on('life_updated', (update) => {
      setMatchState(prev => ({
        ...prev,
        players: prev.players.map(p => 
          p.id === update.playerId 
            ? { ...p, life: update.newLife }
            : p
        )
      }));
    });
    
    return () => {
      socketRef.current.disconnect();
    };
  }, [matchId]);
  
  const updateLife = useCallback((playerId, change) => {
    const player = matchState.players.find(p => p.id === playerId);
    const newLife = player.life + change;
    
    // Optimistic update
    setMatchState(prev => ({
      ...prev,
      players: prev.players.map(p =>
        p.id === playerId ? { ...p, life: newLife } : p
      )
    }));
    
    // Send to server
    socketRef.current.emit('update_life', {
      matchId,
      playerId,
      newLife,
      previousLife: player.life,
      timestamp: Date.now()
    });
  }, [matchState, matchId]);
  
  return { matchState, updateLife, connected };
};
```

### 6.2 Conflict Resolution

#### Optimistic Updates with Rollback
```javascript
class OptimisticUpdateManager {
  constructor() {
    this.pendingUpdates = new Map();
    this.updateTimeout = 5000; // 5 second timeout
  }
  
  applyUpdate(updateId, optimisticState, serverUpdate) {
    // Apply optimistic update immediately
    this.setState(optimisticState);
    
    // Track pending update
    this.pendingUpdates.set(updateId, {
      optimisticState,
      serverUpdate,
      timestamp: Date.now()
    });
    
    // Set timeout for server confirmation
    setTimeout(() => {
      if (this.pendingUpdates.has(updateId)) {
        // Server didn't confirm, rollback
        this.rollbackUpdate(updateId);
      }
    }, this.updateTimeout);
  }
  
  confirmUpdate(updateId, serverState) {
    if (this.pendingUpdates.has(updateId)) {
      this.pendingUpdates.delete(updateId);
      
      // Update with authoritative server state
      this.setState(serverState);
    }
  }
  
  rollbackUpdate(updateId) {
    const update = this.pendingUpdates.get(updateId);
    if (update) {
      this.pendingUpdates.delete(updateId);
      
      // Show error to user
      this.showError('Update failed, please try again');
      
      // Request fresh state from server
      this.requestStateRefresh();
    }
  }
}
```

## 7. Security Implementation

### 7.1 Authentication Flow

#### Firebase Integration
```javascript
// Firebase configuration
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
};

// Authentication hook
const useAuth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        // Get ID token for API calls
        const token = await firebaseUser.getIdToken();
        
        // Validate with backend
        const response = await fetch('/api/auth/validate', {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        if (response.ok) {
          const userData = await response.json();
          setUser({ ...userData, token });
        }
      } else {
        setUser(null);
      }
      setLoading(false);
    });
    
    return unsubscribe;
  }, []);
  
  return { user, loading };
};
```

#### JWT Validation Middleware
```javascript
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  
  try {
    // Verify Firebase token
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    // Get user from database
    const user = await db.users.findByFirebaseUid(decodedToken.uid);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' });
  }
};
```

### 7.2 WebSocket Security

#### Connection Authentication
```javascript
// Server-side socket authentication
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    const user = await db.users.findByFirebaseUid(decodedToken.uid);
    if (!user) {
      return next(new Error('User not found'));
    }
    
    socket.userId = user.id;
    socket.userEmail = user.email;
    next();
  } catch (error) {
    next(new Error('Authentication failed'));
  }
});

// Match authorization
socket.on('join_match', async (data) => {
  const { matchId } = data;
  
  // Verify user is participant in match
  const participant = await db.matchPlayers.findOne({
    match_id: matchId,
    user_id: socket.userId
  });
  
  if (!participant) {
    socket.emit('error', { message: 'Not authorized for this match' });
    return;
  }
  
  socket.join(`match_${matchId}`);
  socket.emit('match_joined', { success: true });
});
```

### 7.3 Input Validation

#### API Request Validation
```javascript
const { body, param, validationResult } = require('express-validator');

// Life update validation
const validateLifeUpdate = [
  param('matchId').isInt().withMessage('Invalid match ID'),
  body('newLife').isInt({ min: -100, max: 1000 }).withMessage('Invalid life total'),
  body('previousLife').isInt().withMessage('Previous life required'),
  body('timestamp').isInt().withMessage('Timestamp required'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];

// Usage
app.put('/api/matches/:matchId/life', 
  authenticateToken, 
  validateLifeUpdate, 
  updateLifeController
);
```

#### WebSocket Message Validation
```javascript
const validateSocketMessage = (schema) => {
  return (data, callback) => {
    const { error, value } = schema.validate(data);
    if (error) {
      callback({ error: error.details[0].message });
      return null;
    }
    return value;
  };
};

// Life update schema
const lifeUpdateSchema = Joi.object({
  matchId: Joi.number().integer().required(),
  playerId: Joi.number().integer().required(),
  newLife: Joi.number().integer().min(-100).max(1000).required(),
  previousLife: Joi.number().integer().required(),
  timestamp: Joi.number().integer().required()
});

// Usage in socket handler
socket.on('update_life', (data, callback) => {
  const validData = validateSocketMessage(lifeUpdateSchema)(data, callback);
  if (!validData) return;
  
  // Process valid update
  handleLifeUpdate(socket, validData);
});
```

## 8. Performance Optimization

### 8.1 Database Optimization

#### Connection Pooling
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20, // Maximum connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Query helper with automatic connection management
const query = async (text, params) => {
  const start = Date.now();
  const client = await pool.connect();
  
  try {
    const result = await client.query(text, params);
    const duration = Date.now() - start;
    
    console.log('Query executed:', { text, duration, rows: result.rowCount });
    return result;
  } finally {
    client.release();
  }
};
```

#### Query Optimization
```javascript
// Efficient match history query with pagination
const getMatchHistory = async (userId, page = 1, limit = 20) => {
  const offset = (page - 1) * limit;
  
  const query = `
    SELECT 
      m.id,
      m.format,
      m.started_at,
      m.completed_at,
      mp.deck_id,
      d.name as deck_name,
      CASE WHEN m.winner_id = mp.user_id THEN true ELSE false END as won,
      array_agg(
        json_build_object(
          'name', u.display_name,
          'deck', od.name
        ) ORDER BY omp.position
      ) as opponents
    FROM matches m
    JOIN match_players mp ON m.id = mp.match_id
    LEFT JOIN decks d ON mp.deck_id = d.id
    LEFT JOIN match_players omp ON m.id = omp.match_id AND omp.user_id != $1
    LEFT JOIN users u ON omp.user_id = u.id
    LEFT JOIN decks od ON omp.deck_id = od.id
    WHERE mp.user_id = $1 AND m.status = 'completed'
    GROUP BY m.id, mp.deck_id, d.name, mp.user_id
    ORDER BY m.completed_at DESC
    LIMIT $2 OFFSET $3
  `;
  
  return await pool.query(query, [userId, limit, offset]);
};
```

### 8.2 Redis Caching Strategy

#### Session Caching
```javascript
class SessionCache {
  constructor(redisClient) {
    this.redis = redisClient;
    this.sessionTTL = 7 * 24 * 60 * 60; // 7 days
  }
  
  async getSession(userId) {
    const sessionKey = `session:${userId}`;
    const cached = await this.redis.get(sessionKey);
    
    if (cached) {
      return JSON.parse(cached);
    }
    
    return null;
  }
  
  async setSession(userId, sessionData) {
    const sessionKey = `session:${userId}`;
    await this.redis.setex(
      sessionKey, 
      this.sessionTTL, 
      JSON.stringify(sessionData)
    );
  }
  
  async invalidateSession(userId) {
    const sessionKey = `session:${userId}`;
    await this.redis.del(sessionKey);
  }
}
```

#### Match State Caching
```javascript
class MatchStateCache {
  constructor(redisClient) {
    this.redis = redisClient;
    this.stateTTL = 24 * 60 * 60; // 24 hours
  }
  
  async getMatchState(matchId) {
    const stateKey = `match:${matchId}:state`;
    const cached = await this.redis.get(stateKey);
    
    if (cached) {
      return JSON.parse(cached);
    }
    
    // Fallback to database
    return await this.loadFromDatabase(matchId);
  }
  
  async updateMatchState(matchId, state) {
    const stateKey = `match:${matchId}:state`;
    
    // Update cache
    await this.redis.setex(
      stateKey,
      this.stateTTL,
      JSON.stringify(state)
    );
    
    // Async database update
    this.persistToDatabase(matchId, state).catch(console.error);
  }
  
  async persistToDatabase(matchId, state) {
    // Batch update match players
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      
      for (const player of state.players) {
        await client.query(
          'UPDATE match_players SET current_life = $1 WHERE match_id = $2 AND user_id = $3',
          [player.life, matchId, player.id]
        );
      }
      
      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}
```

### 8.3 Frontend Optimization

#### Code Splitting
```javascript
// pages/_app.js
import dynamic from 'next/dynamic';

// Lazy load heavy components
const LiveMatch = dynamic(() => import('../components/LiveMatch'), {
  loading: () => <p>Loading match...</p>,
  ssr: false // Client-side only for WebSocket
});

const HistoryBrowser = dynamic(() => import('../components/HistoryBrowser'), {
  loading: () => <p>Loading history...</p>
});

// Route-based code splitting
const App = ({ Component, pageProps }) => {
  return <Component {...pageProps} />;
};

export default App;
```

#### State Management Optimization
```javascript
// Zustand store with selectors
const useMatchStore = create((set, get) => ({
  matches: [],
  activeMatch: null,
  
  // Computed selectors
  getMatchById: (id) => {
    return get().matches.find(m => m.id === id);
  },
  
  getCurrentUserPlayer: () => {
    const { activeMatch, currentUserId } = get();
    return activeMatch?.players.find(p => p.id === currentUserId);
  },
  
  // Optimized updates
  updatePlayerLife: (playerId, newLife) => {
    set(state => ({
      activeMatch: {
        ...state.activeMatch,
        players: state.activeMatch.players.map(p =>
          p.id === playerId ? { ...p, life: newLife } : p
        )
      }
    }));
  }
}));

// Component with selective subscription
const PlayerCard = ({ playerId }) => {
  const player = useMatchStore(state => 
    state.activeMatch?.players.find(p => p.id === playerId)
  );
  
  // Only re-renders when this specific player changes
  return <div>{player?.name}: {player?.life}</div>;
};
```

## 9. Testing Strategy

### 9.1 Unit Testing

#### API Endpoint Testing
```javascript
// __tests__/api/matches.test.js
const request = require('supertest');
const app = require('../../app');
const { setupTestDb, teardownTestDb } = require('../helpers/database');

describe('Matches API', () => {
  beforeAll(async () => {
    await setupTestDb();
  });
  
  afterAll(async () => {
    await teardownTestDb();
  });
  
  describe('POST /api/matches', () => {
    it('should create a new match', async () => {
      const matchData = {
        format: 'standard',
        players: [{ userId: 1, deckId: 1 }]
      };
      
      const response = await request(app)
        .post('/api/matches')
        .set('Authorization', 'Bearer valid-token')
        .send(matchData)
        .expect(201);
      
      expect(response.body).toHaveProperty('id');
      expect(response.body.format).toBe('standard');
      expect(response.body.matchCode).toHaveLength(10);
    });
    
    it('should reject invalid format', async () => {
      const invalidData = {
        format: 'invalid-format',
        players: []
      };
      
      await request(app)
        .post('/api/matches')
        .set('Authorization', 'Bearer valid-token')
        .send(invalidData)
        .expect(400);
    });
  });
});
```

#### WebSocket Testing
```javascript
// __tests__/websocket/match-events.test.js
const Client = require('socket.io-client');
const server = require('../../server');

describe('Match WebSocket Events', () => {
  let clientSocket;
  let serverSocket;
  
  beforeAll((done) => {
    server.listen(() => {
      const port = server.address().port;
      clientSocket = new Client(`http://localhost:${port}`, {
        auth: { token: 'valid-test-token' }
      });
      
      server.on('connection', (socket) => {
        serverSocket = socket;
      });
      
      clientSocket.on('connect', done);
    });
  });
  
  afterAll(() => {
    server.close();
    clientSocket.close();
  });
  
  test('should update life total in real-time', (done) => {
    clientSocket.emit('update_life', {
      matchId: 1,
      playerId: 1,
      newLife: 15,
      previousLife: 20,
      timestamp: Date.now()
    });
    
    clientSocket.on('life_updated', (data) => {
      expect(data.playerId).toBe(1);
      expect(data.newLife).toBe(15);
      done();
    });
  });
});
```

### 9.2 Integration Testing

#### Database Integration
```javascript
// __tests__/integration/match-flow.test.js
describe('Complete Match Flow', () => {
  test('should handle full match lifecycle', async () => {
    // Create users
    const user1 = await createTestUser('player1@test.com');
    const user2 = await createTestUser('player2@test.com');
    
    // Create decks
    const deck1 = await createTestDeck(user1.id, 'Test Deck 1', 'standard');
    const deck2 = await createTestDeck(user2.id, 'Test Deck 2', 'standard');
    
    // Create match
    const match = await request(app)
      .post('/api/matches')
      .set('Authorization', `Bearer ${user1.token}`)
      .send({
        format: 'standard',
        players: [
          { userId: user1.id, deckId: deck1.id },
          { userId: user2.id, deckId: deck2.id }
        ]
      });
    
    expect(match.status).toBe(201);
    
    // Join match as second player
    await request(app)
      .post(`/api/matches/${match.body.id}/join`)
      .set('Authorization', `Bearer ${user2.token}`)
      .send({ matchCode: match.body.matchCode });
    
    // Complete match
    await request(app)
      .put(`/api/matches/${match.body.id}`)
      .set('Authorization', `Bearer ${user1.token}`)
      .send({
        status: 'completed',
        winnerId: user1.id
      });
    
    // Verify match completion
    const completedMatch = await request(app)
      .get(`/api/matches/${match.body.id}`)
      .set('Authorization', `Bearer ${user1.token}`);
    
    expect(completedMatch.body.status).toBe('completed');
    expect(completedMatch.body.winnerId).toBe(user1.id);
  });
});
```

### 9.3 End-to-End Testing

#### Cypress E2E Tests
```javascript
// cypress/e2e/match-gameplay.cy.js
describe('Match Gameplay', () => {
  beforeEach(() => {
    cy.login('testuser@example.com');
    cy.visit('/matches');
  });
  
  it('should create and play a complete match', () => {
    // Create new match
    cy.get('[data-cy=create-match]').click();
    cy.get('[data-cy=format-select]').select('standard');
    cy.get('[data-cy=deck-select]').select('Test Deck');
    cy.get('[data-cy=create-match-button]').click();
    
    // Verify match creation
    cy.url().should('include', '/matches/');
    cy.get('[data-cy=life-total]').should('contain', '20');
    
    // Update life total
    cy.get('[data-cy=life-minus-1]').click();
    cy.get('[data-cy=life-total]').should('contain', '19');
    
    // Verify real-time update (simulate second player)
    cy.window().then((win) => {
      win.testSocket.emit('life_updated', {
        playerId: 2,
        newLife: 18,
        change: -2
      });
    });
    
    cy.get('[data-cy=opponent-life]').should('contain', '18');
    
    // End match
    cy.get('[data-cy=end-match]').click();
    cy.get('[data-cy=confirm-end]').click();
    
    // Add personal note
    cy.get('[data-cy=add-note]').type('Good game, need to improve early game');
    cy.get('[data-cy=save-note]').click();
    
    // Verify match appears in history
    cy.visit('/history');
    cy.get('[data-cy=match-history]').should('contain', 'Test Deck');
  });
});
```

## 10. Deployment Configuration

### 10.1 Kubernetes Manifests

#### Namespace
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mtg-tracker
  labels:
    name: mtg-tracker
```

#### Frontend Deployment
```yaml
# k8s/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mtg-frontend
  namespace: mtg-tracker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mtg-frontend
  template:
    metadata:
      labels:
        app: mtg-frontend
    spec:
      containers:
      - name: frontend
        image: mtg-tracker/frontend:latest
        ports:
        - containerPort: 3000
        env:
        - name: NEXT_PUBLIC_API_URL
          value: "https://mtg-tracker.local/api"
        - name: NEXT_PUBLIC_WS_URL
          value: "wss://mtg-tracker.local"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### Backend Deployment
```yaml
# k8s/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mtg-backend
  namespace: mtg-tracker
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mtg-backend
  template:
    metadata:
      labels:
        app: mtg-backend
    spec:
      containers:
      - name: backend
        image: mtg-tracker/backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DB_HOST
          value: "postgres-service"
        - name: DB_NAME
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: database
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: REDIS_URL
          value: "redis://redis-service:6379"
        - name: FIREBASE_SERVICE_ACCOUNT
          valueFrom:
            secretKeyRef:
              name: firebase-secret
              key: service-account
        resources:
          requests:
            memory: "384Mi"
            cpu: "250m"
          limits:
            memory: "768Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
```

#### PostgreSQL Deployment
```yaml
# k8s/postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: mtg-tracker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:16-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: database
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
```

#### Ingress Configuration
```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mtg-tracker-ingress
  namespace: mtg-tracker
  annotations:
    kubernetes.io/ingress.class: "traefik"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    traefik.ingress.kubernetes.io/redirect-entry-point: https
spec:
  tls:
  - hosts:
    - mtg-tracker.local
    secretName: mtg-tracker-tls
  rules:
  - host: mtg-tracker.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
      - path: /socket.io
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
```

### 10.2 CI/CD Pipeline

#### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy to k3s

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: mtg_tracker_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: |
        npm ci
        cd frontend && npm ci
        cd ../backend && npm ci
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/mtg_tracker_test
        REDIS_URL: redis://localhost:6379
      run: |
        npm run test:backend
        npm run test:frontend
        npm run test:e2e
  
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ secrets.REGISTRY_URL }}
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}
    
    - name: Build and push frontend
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: true
        tags: ${{ secrets.REGISTRY_URL }}/mtg-tracker/frontend:${{ github.sha }}
    
    - name: Build and push backend
      uses: docker/build-push-action@v4
      with:
        context: ./backend
        push: true
        tags: ${{ secrets.REGISTRY_URL }}/mtg-tracker/backend:${{ github.sha }}
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'
    
    - name: Configure kubectl
      run: |
        echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > $HOME/.kube/config
    
    - name: Update image tags
      run: |
        sed -i 's|image: mtg-tracker/frontend:latest|image: ${{ secrets.REGISTRY_URL }}/mtg-tracker/frontend:${{ github.sha }}|' k8s/frontend-deployment.yaml
        sed -i 's|image: mtg-tracker/backend:latest|image: ${{ secrets.REGISTRY_URL }}/mtg-tracker/backend:${{ github.sha }}|' k8s/backend-deployment.yaml
    
    - name: Deploy to k3s
      run: |
        kubectl apply -f k8s/
        kubectl rollout status deployment/mtg-frontend -n mtg-tracker
        kubectl rollout status deployment/mtg-backend -n mtg-tracker
```

### 10.3 Environment Configuration

#### Production Environment Variables
```bash
# .env.production
NODE_ENV=production

# Database
DB_HOST=postgres-service
DB_PORT=5432
DB_NAME=mtg_tracker
DB_USER=mtg_user
DB_PASSWORD=secure_password

# Redis
REDIS_URL=redis://redis-service:6379

# Firebase
FIREBASE_PROJECT_ID=mtg-tracker-prod
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@mtg-tracker-prod.iam.gserviceaccount.com

# Security
JWT_SECRET=ultra_secure_jwt_secret
SESSION_SECRET=ultra_secure_session_secret

# CORS
ALLOWED_ORIGINS=https://mtg-tracker.local

# Monitoring
SENTRY_DSN=https://...@sentry.io/...
LOG_LEVEL=info
```

## 11. Monitoring and Observability

### 11.1 Application Monitoring

#### Health Check Endpoints
```javascript
// routes/health.js
const express = require('express');
const router = express.Router();

// Basic health check
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Readiness check (dependencies)
router.get('/ready', async (req, res) => {
  try {
    // Check database
    await pool.query('SELECT 1');
    
    // Check Redis
    await redis.ping();
    
    res.status(200).json({
      status: 'ready',
      dependencies: {
        database: 'healthy',
        redis: 'healthy'
      }
    });
  } catch (error) {
    res.status(503).json({
      status: 'not ready',
      error: error.message
    });
  }
});

module.exports = router;
```

#### Metrics Collection
```javascript
// middleware/metrics.js
const promClient = require('prom-client');

// Create metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

const activeWebSocketConnections = new promClient.Gauge({
  name: 'websocket_connections_active',
  help: 'Number of active WebSocket connections'
});

const matchesCreated = new promClient.Counter({
  name: 'matches_created_total',
  help: 'Total number of matches created'
});

// Middleware
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || 'unknown', res.statusCode)
      .observe(duration);
  });
  
  next();
};

module.exports = {
  metricsMiddleware,
  activeWebSocketConnections,
  matchesCreated
};
```

### 11.2 Error Tracking

#### Sentry Integration
```javascript
// app.js
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  integrations: [
    new Sentry.Integrations.Http({ tracing: true }),
    new Sentry.Integrations.Express({ app }),
  ],
  tracesSampleRate: 0.1,
});

// Error handling middleware
app.use(Sentry.Handlers.errorHandler());

app.use((error, req, res, next) => {
  console.error('Application error:', error);
  
  // Don't expose error details in production
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  res.status(error.status || 500).json({
    error: isDevelopment ? error.message : 'Internal server error',
    ...(isDevelopment && { stack: error.stack })
  });
});
```

### 11.3 Logging Strategy

#### Structured Logging
```javascript
// utils/logger.js
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'mtg-tracker' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Usage examples
logger.info('Match created', { 
  matchId: match.id, 
  userId: req.user.id, 
  format: match.format 
});

logger.error('Database connection failed', { 
  error: error.message, 
  stack: error.stack 
});

module.exports = logger;
```

## 12. Maintenance and Operations

### 12.1 Database Maintenance

#### Backup Strategy
```bash
#!/bin/bash
# scripts/backup-database.sh

BACKUP_DIR="/backups/mtg-tracker"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="mtg_tracker"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
kubectl exec -n mtg-tracker postgres-0 -- pg_dump -U postgres $DB_NAME > $BACKUP_DIR/backup_$TIMESTAMP.sql

# Compress backup
gzip $BACKUP_DIR/backup_$TIMESTAMP.sql

# Keep only last 30 days of backups
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +30 -delete

echo "Backup completed: backup_$TIMESTAMP.sql.gz"
```

#### Database Migration
```javascript
// migrations/001_initial_schema.js
exports.up = async function(knex) {
  // Users table
  await knex.schema.createTable('users', table => {
    table.increments('id').primary();
    table.string('firebase_uid', 128).unique().notNullable();
    table.string('email', 255).notNullable();
    table.string('display_name', 100).notNullable();
    table.jsonb('google_profile');
    table.boolean('is_admin').defaultTo(false);
    table.timestamps(true, true);
  });
  
  // Add indexes
  await knex.raw('CREATE INDEX idx_users_firebase_uid ON users(firebase_uid)');
  await knex.raw('CREATE INDEX idx_users_email ON users(email)');
};

exports.down = async function(knex) {
  await knex.schema.dropTableIfExists('users');
};
```

### 12.2 Performance Monitoring

#### Database Query Analysis
```sql
-- Find slow queries
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  max_time,
  stddev_time
FROM pg_stat_statements
WHERE mean_time > 100
ORDER BY mean_time DESC
LIMIT 10;

-- Find tables needing vacuum
SELECT 
  schemaname,
  tablename,
  n_dead_tup,
  n_live_tup,
  (n_dead_tup::float / GREATEST(n_live_tup, 1)) * 100 as dead_ratio
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY dead_ratio DESC;
```

#### Redis Monitoring
```javascript
// utils/redis-monitor.js
const redis = require('./redis');

const monitorRedis = () => {
  redis.monitor((time, args, source, database) => {
    console.log(`Redis [${database}]: ${args.join(' ')}`);
  });
  
  // Memory usage
  setInterval(async () => {
    const info = await redis.info('memory');
    const usedMemory = info.match(/used_memory:(\d+)/)[1];
    console.log(`Redis memory usage: ${usedMemory} bytes`);
  }, 60000);
};

module.exports = monitorRedis;
```

### 12.3 Scaling Considerations

#### Horizontal Scaling Strategy
```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mtg-backend-hpa
  namespace: mtg-tracker
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mtg-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 600
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
```

## 13. Conclusion

This design document provides a comprehensive blueprint for implementing the Magic: The Gathering Score Tracker application. The architecture balances modern web technologies with practical deployment requirements, emphasizing real-time capabilities, user privacy, and operational simplicity.

### 13.1 Key Success Factors

- **Technology Alignment**: Node.js ecosystem provides optimal WebSocket performance for the use case
- **Scalable Architecture**: Clean separation enables future growth and feature additions
- **Privacy Focus**: Invite-only access and private comments respect friend group dynamics
- **Resource Efficiency**: Optimized for k3s deployment with minimal infrastructure overhead
- **Developer Experience**: TypeScript, comprehensive testing, and automated deployment pipelines

### 13.2 Implementation Roadmap

1. **Phase 1** (MVP - 4-6 weeks): Core authentication, basic match creation, simple life tracking
2. **Phase 2** (Full Features - 6-8 weeks): Real-time updates, game history, personal notes
3. **Phase 3** (Polish - 2-3 weeks): Mobile optimization, performance tuning, monitoring
4. **Phase 4** (Deployment - 1-2 weeks): k3s deployment, CI/CD pipeline, production hardening

### 13.3 Risk Mitigation

- **WebSocket Complexity**: Comprehensive reconnection logic and fallback strategies
- **Data Consistency**: Optimistic updates with conflict resolution and rollback capabilities
- **Performance**: Proper indexing, caching strategy, and horizontal scaling readiness
- **Security**: Multiple authentication layers, input validation, and secure deployment practices

This design provides a solid foundation for building a robust, scalable, and maintainable MTG score tracking application that will serve your friend group effectively while being prepared for future enhancements and growth.