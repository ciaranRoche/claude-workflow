# Discovery Questions: MTG Score Tracker

**Date**: 2025-07-28T15:32:00Z  
**Phase**: Business Logic Discovery  
**Status**: Questions prepared, awaiting user input

## Question 1: Match Organization and Player Limits

**Question**: How should matches be organized and what are the player limits for different game formats?

**Smart Default**: 
- **Standard Format**: 2 players per match (traditional 1v1)
- **Commander Format**: 2-4 players per match (multiplayer support)
- **Match Creation**: Any user can create a match and share a join code
- **Privacy**: Matches can be public (discoverable) or private (invite-only)

**Reasoning**: Standard MTG is primarily 1v1, while Commander is designed for multiplayer (typically 4 players). This approach provides flexibility while respecting format conventions. Join codes provide easy sharing without complex friend systems.

---

## Question 2: Scoring System and Life Total Management

**Question**: What scoring mechanics should be tracked for each format, and how should life totals be managed?

**Smart Default**:
- **Standard Format**: 
  - Starting life: 20
  - Track life total changes with +/- buttons
  - Win condition: Opponent reaches 0 life (or other win conditions)
- **Commander Format**:
  - Starting life: 40
  - Track commander damage separately per opponent
  - Support poison counters (optional)
  - Track elimination order for multiplayer

**Reasoning**: These are the official starting life totals for each format. Commander's unique mechanics (commander damage, higher life total) require additional tracking. The +/- button approach is common in digital life counter apps and provides intuitive control.

---

## Question 3: Real-time Updates and Synchronization

**Question**: How should real-time score updates work during active matches, and who has permission to update scores?

**Smart Default**:
- **Update Permissions**: Each player can only update their own life total
- **Real-time Sync**: All players see updates immediately via WebSocket
- **Conflict Resolution**: Timestamp-based updates with 5-second undo window
- **Connection Issues**: Offline capability with sync when reconnected
- **Match State**: Show who's currently "active" or whose turn it is (optional)

**Reasoning**: Self-service updates prevent disputes while maintaining control. Real-time sync keeps everyone informed. Undo windows handle mistakes. Offline capability ensures gameplay isn't interrupted by network issues.

---

## Question 4: Game History and Comment System

**Question**: What level of detail should be stored in game history, and how should the post-match comment system work?

**Smart Default**:
- **Stored Data**:
  - Final scores and winner(s)
  - Match duration and timestamps
  - Deck names for each player
  - Game format (Standard/Commander)
  - Complete life total change history (optional replay)
- **Comment System**:
  - Comments added only after match completion
  - Each player can leave one comment per match
  - Comments are visible to all match participants
  - Character limit: 500 characters
  - No editing after submission (promote honest reflection)

**Reasoning**: This provides enough detail for meaningful analysis without overwhelming storage. One comment per player prevents spam while encouraging thoughtful reflection. Immutable comments maintain integrity of historical records.

---

## Question 5: Deck Management and Integration

**Question**: How should deck information be managed and associated with matches?

**Smart Default**:
- **Deck Storage**: Simple deck name + format + optional description
- **Match Association**: Players select from their saved decks when joining matches
- **Deck Details**: Store deck name, format, colors, and brief strategy notes
- **Privacy**: Deck lists are private to the owner
- **Sharing**: Optional deck sharing with match participants after game completion
- **Import**: Manual entry only (no external deck list integration initially)

**Reasoning**: Keeps deck management simple while providing enough information for game analysis. Privacy respects competitive aspects of MTG. Post-match sharing allows learning and discussion. Manual entry avoids complex integrations with external deck databases.

---

## Summary of Smart Defaults

These defaults are based on:
- **MTG Official Rules**: Correct life totals and format conventions
- **Technology Research**: WebSocket capabilities for real-time features
- **User Experience**: Intuitive controls and clear permissions
- **Privacy Considerations**: Player control over their own data
- **Scalability**: Simple systems that can grow with usage

**Next Step**: Present these questions to the user one at a time for confirmation or modification, then proceed to expert-level technical questions once business logic is clarified.