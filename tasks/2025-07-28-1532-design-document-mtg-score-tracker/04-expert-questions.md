# Expert-Level Technical Questions: MTG Score Tracker

**Date**: 2025-07-28T15:32:00Z  
**Phase**: Expert Requirements Clarification  
**Status**: Questions prepared based on technical analysis

## Question 1: WebSocket Connection Management and Scalability

**Question**: How should WebSocket connections be managed for match rooms, and what happens when players disconnect during active games?

**Smart Default**: 
- **Connection Strategy**: One WebSocket connection per user, with room-based message routing
- **Reconnection**: Automatic reconnection with exponential backoff (1s, 2s, 4s, 8s max)
- **Disconnection Handling**: 
  - Match continues if other players remain connected
  - Disconnected player's last known state preserved
  - 10-minute timeout before marking player as "away"
  - Match can be paused by agreement of remaining players
- **State Recovery**: Full match state sent on reconnection

**Technical Reasoning**: Based on WebSocket best practices for 2025, this approach handles network instability common in home/casual environments while maintaining game continuity. Room-based routing scales well for friend groups.

---

## Question 2: Data Consistency for Concurrent Life Total Updates

**Question**: How should the system handle race conditions when multiple players update scores simultaneously, especially in Commander games?

**Smart Default**:
- **Update Strategy**: Optimistic locking with conflict detection
- **Conflict Resolution**: 
  - Each update includes timestamp and previous value
  - Server validates update against current state
  - If conflict detected, reject update and send current state
  - Client shows brief "Update failed, please retry" message
- **Undo Window**: 5-second server-side undo buffer per player
- **Commander Damage**: Separate update stream from life totals to prevent conflicts

**Technical Reasoning**: Given the real-time nature and friend group usage, optimistic locking provides better UX than pessimistic locking. The validation approach prevents data corruption while keeping the interface responsive.

---

## Question 3: Historical Data Storage and Query Performance

**Question**: How should game history be structured for efficient querying of player statistics and match trends over time?

**Smart Default**:
- **Database Schema**:
  - Matches table: match metadata (id, format, start_time, duration, winner)
  - Players table: user info and deck association per match
  - Game_events table: life changes, eliminations, win conditions
  - Personal_notes table: private comments linked to match + player
- **Indexing Strategy**: 
  - Composite index on (player_id, match_date) for player history
  - Index on (format, match_date) for format-specific analysis
  - Full-text search on personal notes
- **Archival**: Keep all data (no automatic deletion) with optional export

**Technical Reasoning**: This structure supports both quick "recent games" queries and deep historical analysis. Separate events table enables match replay feature while maintaining query performance.

---

## Question 4: Authentication and Session Management for Friend Groups

**Question**: How should user authentication and session management work for a private friend group app?

**Smart Default**:
- **Authentication**: Google OAuth 2.0 with Firebase Authentication
- **User Registration**: 
  - First user becomes "admin" automatically
  - Admin can send invite links to friends
  - New users must use invite link + Google OAuth
  - No public registration
- **Session Management**:
  - JWT tokens with 7-day expiry
  - Refresh tokens for extended sessions
  - WebSocket authentication via token validation
- **User Data**: Store Google profile info + custom display name for games

**Technical Reasoning**: Firebase Auth handles OAuth complexity while invite-only system maintains privacy. Extended sessions reduce re-authentication friction for friend groups playing regularly.

---

## Question 5: Deployment Architecture and Resource Management on k3s

**Question**: How should the application be deployed on k3s with appropriate resource allocation and high availability?

**Smart Default**:
- **Container Strategy**:
  - Frontend: Nginx + Node.js (Next.js) - 512MB RAM, 0.5 CPU
  - Backend: Node.js API server - 1GB RAM, 1 CPU  
  - Database: PostgreSQL 16 - 2GB RAM, 1 CPU
  - Cache: Redis 7 - 512MB RAM, 0.5 CPU
- **High Availability**:
  - 2 replicas for API server behind load balancer
  - Single PostgreSQL with automated backups
  - Redis with persistence enabled
- **Persistent Storage**: 
  - PostgreSQL: 10GB initial, auto-expanding
  - Redis: 1GB for session + cache data
- **Networking**: Ingress controller with TLS termination

**Technical Reasoning**: Resource allocation appropriate for friend group usage (~10-20 concurrent users max). 2 API replicas provide availability without over-provisioning. Single DB acceptable for private app with good backup strategy.

---

## Summary of Technical Decisions

These expert questions address the core technical challenges:

1. **Real-time Communication**: WebSocket room management with robust reconnection
2. **Data Consistency**: Optimistic locking for concurrent updates  
3. **Performance**: Proper indexing strategy for historical queries
4. **Security**: Private authentication with invite-only access
5. **Operations**: Right-sized k3s deployment for friend group scale

**Next Step**: Present these questions to validate technical approach, then proceed to requirements specification and final design document.