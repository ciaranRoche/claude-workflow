# Expert-Level Technical Answers: MTG Score Tracker

**Date**: 2025-07-28T15:32:00Z  
**Phase**: Expert Questions Complete  
**Status**: All technical questions answered

## Question 1: WebSocket Connection Management and Scalability
**Answer**: **APPROVED** - Room-based WebSocket management
- **Connection Strategy**: One WebSocket per user with room-based routing ✓
- **Reconnection**: Automatic with exponential backoff (1s, 2s, 4s, 8s max) ✓
- **Disconnection Handling**: Match continues, 10-minute timeout, pausable by agreement ✓
- **State Recovery**: Full match state sent on reconnection ✓
- **Technical Fit**: Appropriate for home network conditions and friend group gameplay

## Question 2: Data Consistency for Concurrent Life Total Updates
**Answer**: **APPROVED** - Optimistic locking with conflict detection
- **Update Strategy**: Optimistic locking with server-side validation ✓
- **Conflict Resolution**: Timestamp + previous value validation ✓
- **Failed Updates**: "Update failed, please retry" messaging ✓
- **Undo Window**: 5-second server-side undo buffer per player ✓
- **Commander Damage**: Separate update stream to prevent conflicts ✓
- **UX Consideration**: Good balance of responsiveness and data integrity

## Question 3: Historical Data Storage and Query Performance
**Answer**: **APPROVED** - Comprehensive relational schema
- **Database Schema**: 
  - Matches table (metadata) ✓
  - Players table (deck association) ✓
  - Game_events table (life changes, eliminations) ✓
  - Personal_notes table (private comments) ✓
- **Indexing Strategy**: Composite indexes on (player_id, match_date) and (format, match_date) ✓
- **Data Retention**: Permanent storage with optional export ✓
- **Performance**: Supports both quick queries and deep historical analysis

## Question 4: Authentication and Session Management for Friend Groups
**Answer**: **APPROVED** - Invite-only Firebase Authentication
- **Authentication**: Google OAuth 2.0 with Firebase Authentication ✓
- **User Registration**: 
  - First user becomes admin ✓
  - Admin sends invite links ✓
  - Invite link + Google OAuth required ✓
  - No public registration ✓
- **Session Management**: JWT tokens with 7-day expiry, refresh tokens ✓
- **User Data**: Google profile + custom display name ✓
- **Privacy**: Invite-only system maintains friend group privacy

## Question 5: k3s Deployment Architecture and Resource Management
**Answer**: **APPROVED** - Node.js-based deployment with efficiency optimizations
- **Technology Choice**: **Node.js confirmed** over Go for WebSocket performance
- **Container Strategy**:
  - Frontend: Nginx + Node.js (Next.js) - 512MB RAM, 0.5 CPU ✓
  - Backend: Node.js API server - **768MB RAM, 0.5 CPU** (optimized)
  - Database: PostgreSQL 16 - 2GB RAM, 1 CPU ✓
  - Cache: Redis 7 - 512MB RAM, 0.5 CPU ✓
- **High Availability**: 2 API replicas, single PostgreSQL with backups ✓
- **Storage**: 10GB PostgreSQL (auto-expanding), 1GB Redis ✓
- **Total Resources**: ~4GB RAM, 3 CPU cores (k3s appropriate)

## Key Technical Decisions Finalized

### Architecture Decisions
1. **Real-time Communication**: WebSocket rooms with robust reconnection handling
2. **Data Consistency**: Optimistic locking for responsive concurrent updates
3. **Performance**: Indexed relational schema for efficient historical queries
4. **Security**: Private invite-only authentication with Google OAuth
5. **Deployment**: Right-sized Node.js containers for friend group scale

### Technology Stack Confirmed
- **Frontend**: React with Next.js 15 (Server Components)
- **Backend**: Node.js with Express/Fastify + Socket.io
- **Database**: PostgreSQL 16 with Redis 7 caching
- **Authentication**: Firebase Authentication (Google OAuth)
- **Deployment**: k3s with container orchestration
- **Real-time**: WebSocket with Socket.io library

### Scaling Considerations
- **Current Target**: 10-20 concurrent users (friend group)
- **Resource Efficiency**: Total ~4GB RAM, 3 CPU cores
- **Growth Path**: Horizontal scaling ready, microservices extraction possible
- **Performance**: WebSocket benchmarks favor Node.js for this scale

### Security and Privacy
- **Authentication**: Invite-only with Google OAuth 2.0 compliance
- **Data Privacy**: Personal comments private, no social features
- **Network Security**: WSS protocols, origin validation, rate limiting
- **Session Management**: JWT with refresh tokens, 7-day expiry

**Next Phase**: Proceed to comprehensive requirements specification and final design document creation.