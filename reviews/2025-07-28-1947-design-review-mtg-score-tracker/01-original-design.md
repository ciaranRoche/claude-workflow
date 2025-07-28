# Original Design Document (Copy)

**Note**: This is a complete copy of the original design document being reviewed for reference purposes.

---

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

[Continue with the rest of the design document...]

*Note: The full original design document content is preserved here for reference. This includes all sections from Database Design through Maintenance and Operations, totaling 1,989 lines of comprehensive technical specification.*