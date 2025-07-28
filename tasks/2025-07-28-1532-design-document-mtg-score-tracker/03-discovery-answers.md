# Discovery Answers: MTG Score Tracker

**Date**: 2025-07-28T15:32:00Z  
**Phase**: Discovery Complete  
**Status**: All questions answered

## Question 1: Match Organization and Player Limits
**Answer**: **MODIFIED** - Private friend group app
- **Standard Format**: 2 players per match (1v1) ✓
- **Commander Format**: 2-4 players per match ✓  
- **Match Creation**: Any user can create matches ✓
- **Privacy**: **Private app for friends only** - no public discovery needed
- **Usage Context**: **In-person games** with digital score tracking

## Question 2: Scoring System and Life Total Management
**Answer**: **APPROVED** - Official MTG rules
- **Standard Format**: Starting life 20, +/- buttons, win at 0 life ✓
- **Commander Format**: Starting life 40, commander damage tracking, poison counters, elimination order ✓
- **Interface**: +/- button approach for intuitive in-person use ✓

## Question 3: Real-time Updates and Synchronization  
**Answer**: **APPROVED** - Self-service with real-time sync
- **Update Permissions**: Each player updates own life total ✓
- **Real-time Sync**: WebSocket updates for all players ✓
- **Conflict Resolution**: Timestamp-based with 5-second undo ✓
- **Offline Capability**: Sync when reconnected ✓
- **Turn Tracking**: Optional active player indication ✓

## Question 4: Game History and Comment System
**Answer**: **MODIFIED** - Private comments for personal analysis
- **Stored Data**: Final scores, duration, deck names, format, life history ✓
- **Comment System**: **Private comments per player** (not shared)
- **Comment Privacy**: Each player's comments visible only to them
- **Comment Purpose**: Personal game analysis and improvement notes
- **Character Limit**: 500 characters ✓
- **Editing**: No editing after submission ✓

## Question 5: Deck Management and Integration
**Answer**: **APPROVED** - Simple manual deck tracking
- **Deck Storage**: Name + format + optional description ✓
- **Match Association**: Select from saved decks when joining ✓
- **Deck Details**: Name, format, colors, strategy notes ✓
- **Privacy**: Deck lists private to owner ✓
- **Sharing**: No automatic sharing (aligns with private comments) ✓
- **Import**: Manual entry only ✓

## Key Requirements Clarifications

### Application Scope
- **Target Users**: Private friend group
- **Usage Context**: In-person MTG games with digital tracking
- **Privacy Level**: No public features needed
- **User Management**: Simple Google OAuth for friend group

### Core Features Confirmed
1. **Real-time Score Tracking**: WebSocket-based live updates during matches
2. **Format Support**: Standard (1v1) and Commander (2-4 players) with correct mechanics
3. **Game History**: Complete match records with replay capability
4. **Personal Analysis**: Private comments for individual improvement tracking
5. **Deck Association**: Simple deck management tied to match records

### Technology Implications
- **Authentication**: Google OAuth sufficient for friend group
- **Real-time**: WebSocket implementation confirmed necessary
- **Privacy**: No social features, focus on personal data management
- **Deployment**: k3s suitable for private group usage
- **Database**: Game history and personal comments require robust storage

**Next Phase**: Proceed to expert-level technical questions to finalize implementation details.