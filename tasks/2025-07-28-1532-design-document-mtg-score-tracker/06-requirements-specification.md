# Requirements Specification: MTG Score Tracker

**Date**: 2025-07-28T15:33:00Z  
**Project**: Magic The Gathering Score Tracker  
**Target Users**: Private friend group (10-20 players)  
**Deployment**: k3s cluster

## 1. Executive Summary

The MTG Score Tracker is a private, full-stack web application designed for a friend group to track Magic: The Gathering game scores and results during in-person play sessions. The application provides real-time score tracking, comprehensive game history, and private analysis tools to help players improve their gameplay over time.

## 2. Functional Requirements

### 2.1 User Management
**REQ-UM-001**: The system shall support invite-only user registration
- First user automatically becomes admin
- Admin can generate and send invite links
- New users must use invite link + Google OAuth to register
- No public registration allowed

**REQ-UM-002**: The system shall authenticate users via Google OAuth 2.0
- Firebase Authentication integration
- JWT tokens with 7-day expiry
- Refresh tokens for extended sessions
- WebSocket authentication via token validation

**REQ-UM-003**: The system shall store user profile information
- Google profile data (name, email, avatar)
- Custom display name for games
- User preferences and settings

### 2.2 Match Management
**REQ-MM-001**: The system shall support Standard format matches
- 2 players per match (1v1)
- Starting life total: 20
- Track life total changes
- Record win conditions

**REQ-MM-002**: The system shall support Commander format matches
- 2-4 players per match
- Starting life total: 40
- Track commander damage per opponent
- Support poison counters (optional)
- Track elimination order in multiplayer

**REQ-MM-003**: The system shall provide match creation and joining
- Any user can create matches
- Share matches via join codes
- Private matches only (no public discovery)
- Match format selection (Standard/Commander)

### 2.3 Real-Time Score Tracking
**REQ-RT-001**: The system shall provide real-time score updates
- WebSocket-based live updates
- Each player updates only their own life total
- All match participants see updates immediately
- +/- button interface for life total changes

**REQ-RT-002**: The system shall handle connection management
- Automatic reconnection with exponential backoff
- Match continues if players disconnect
- 10-minute timeout before marking "away"
- Full match state recovery on reconnection
- Optional match pausing by player agreement

**REQ-RT-003**: The system shall prevent data conflicts
- Optimistic locking with timestamp validation
- Server-side conflict detection and resolution
- 5-second undo window per player
- Separate update streams for different mechanics

### 2.4 Game History and Analytics
**REQ-GH-001**: The system shall store comprehensive match data
- Match metadata (format, duration, timestamps)
- Final scores and winner determination
- Complete life total change history
- Deck associations for each player
- Game events (eliminations, win conditions)

**REQ-GH-002**: The system shall provide historical analysis
- Player statistics and win rates
- Format-specific performance metrics
- Deck performance tracking
- Match replay capability
- Searchable game history

**REQ-GH-003**: The system shall support private post-match comments
- Comments added only after match completion
- Each player's comments visible only to themselves
- 500 character limit per comment
- No editing after submission
- Comments linked to specific matches

### 2.5 Deck Management
**REQ-DM-001**: The system shall provide deck storage
- Deck name and format association
- Optional deck description and strategy notes
- Color identity tracking
- Private deck lists per user

**REQ-DM-002**: The system shall integrate decks with matches
- Players select from saved decks when joining matches
- Deck performance tracking over time
- Deck usage statistics and analysis

## 3. Technical Requirements

### 3.1 Performance Requirements
**REQ-PERF-001**: The system shall support concurrent usage
- 10-20 simultaneous users
- Sub-second response times for score updates
- 99.5% uptime during gaming sessions

**REQ-PERF-002**: The system shall handle WebSocket performance
- Support 20+ concurrent WebSocket connections
- Message delivery within 100ms
- Graceful degradation under network stress

### 3.2 Scalability Requirements
**REQ-SCALE-001**: The system shall be horizontally scalable
- Stateless API server design
- Database connection pooling
- Load balancer ready architecture

**REQ-SCALE-002**: The system shall efficiently use k3s resources
- Total resource allocation: ~4GB RAM, 3 CPU cores
- Container-optimized deployment
- Auto-scaling capabilities for API servers

### 3.3 Security Requirements
**REQ-SEC-001**: The system shall implement secure authentication
- OAuth 2.0 compliance with Google
- JWT token validation
- Session management with secure cookies
- HTTPS/WSS encryption mandatory

**REQ-SEC-002**: The system shall protect user data
- Private comments isolated per user
- Invite-only access control
- Rate limiting on API endpoints
- Input validation and sanitization

### 3.4 Data Requirements
**REQ-DATA-001**: The system shall ensure data consistency
- ACID compliance for match data
- Concurrent update conflict resolution
- Database transaction integrity
- Backup and recovery procedures

**REQ-DATA-002**: The system shall provide data persistence
- Permanent game history storage
- No automatic data deletion
- Optional data export functionality
- Efficient query performance for historical data

## 4. Architecture Requirements

### 4.1 Technology Stack
**REQ-TECH-001**: Frontend technology requirements
- React with Next.js 15 (Server Components)
- TypeScript for type safety
- Responsive design for mobile/desktop
- WebSocket client integration

**REQ-TECH-002**: Backend technology requirements
- Node.js with Express/Fastify framework
- Socket.io for WebSocket management
- JWT authentication middleware
- API documentation with OpenAPI

**REQ-TECH-003**: Database requirements
- PostgreSQL 16 for primary data storage
- Redis 7 for caching and session storage
- Proper indexing for query performance
- Database connection pooling

### 4.2 Deployment Requirements
**REQ-DEPLOY-001**: The system shall deploy on k3s
- Container-based deployment with Docker
- Kubernetes manifests for orchestration
- Persistent volume claims for data storage
- Ingress controller with TLS termination

**REQ-DEPLOY-002**: The system shall implement monitoring
- Application health checks
- Resource usage monitoring
- Error tracking and alerting
- Performance metrics collection

## 5. User Experience Requirements

### 5.1 Interface Requirements
**REQ-UI-001**: The system shall provide intuitive game interface
- Clear life total displays
- Easy-to-use +/- buttons
- Real-time update indicators
- Match status visibility

**REQ-UI-002**: The system shall support mobile devices
- Responsive design for phones/tablets
- Touch-friendly controls
- Offline capability during network issues
- Fast loading times

### 5.2 Accessibility Requirements
**REQ-ACCESS-001**: The system shall meet basic accessibility standards
- Keyboard navigation support
- High contrast mode availability
- Screen reader compatibility
- Clear visual hierarchy

## 6. Quality Attributes

### 6.1 Reliability
- 99.5% uptime during active gaming sessions
- Graceful degradation during network issues
- Data backup and recovery procedures
- Error handling with user-friendly messages

### 6.2 Usability
- Intuitive interface requiring minimal learning
- Fast game setup and joining processes
- Clear visual feedback for all actions
- Mobile-friendly design for in-person play

### 6.3 Maintainability
- Clean, documented codebase
- Modular architecture for future enhancements
- Automated testing coverage
- Version control and deployment pipelines

## 7. Constraints and Assumptions

### 7.1 Technical Constraints
- Must deploy on existing k3s infrastructure
- Resource limitations: ~4GB RAM, 3 CPU cores
- Private network deployment (no public internet requirements)
- Google OAuth dependency for authentication

### 7.2 Business Constraints
- Private application for friend group only
- No monetization requirements
- Minimal ongoing maintenance expectations
- In-person gameplay context

### 7.3 Assumptions
- Users have Google accounts for authentication
- Stable local network during gaming sessions
- Basic technical literacy among user group
- Regular gaming sessions to justify development effort

## 8. Success Criteria

### 8.1 Primary Success Metrics
- All friend group members successfully onboarded
- Real-time score tracking works reliably during games
- Historical data provides valuable gameplay insights
- Zero data loss during normal operations

### 8.2 Secondary Success Metrics
- Sub-second response times for score updates
- Mobile usability enables easy in-person use
- Private comments feature enhances gameplay analysis
- System requires minimal ongoing maintenance

## 9. Future Considerations

### 9.1 Potential Enhancements
- Additional Magic formats (Limited, Modern, etc.)
- Tournament bracket management
- Advanced statistics and analytics
- Integration with external deck databases
- Mobile native applications

### 9.2 Scalability Paths
- Microservices architecture extraction
- Multi-group support with isolation
- Advanced real-time features (voice integration)
- Machine learning for gameplay insights

---

**This requirements specification serves as the authoritative definition of the MTG Score Tracker application and guides all design and implementation decisions.**