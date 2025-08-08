# WOPR Display - Current Architecture Analysis

## Application Overview
**Location**: `projects/home-lab/apps/wopr-display/`  
**Type**: Go backend with embedded HTML/CSS/JS frontend  
**Purpose**: WarGames WOPR-inspired K3s cluster monitoring display for 7.84" 1280x400 touchscreen

## Current Technology Stack

### Backend (Go)
- **Framework**: Standard Go HTTP server 
- **WebSocket**: Real-time updates via custom WebSocket hub
- **Dependencies**:
  - Prometheus client for metrics collection
  - Ollama API integration for AI-generated ASCII art
  - Custom military scenario transformer
- **Port**: 8080 (configurable via PORT env var)

### Frontend (Embedded)
- **Architecture**: Single HTML template embedded in Go handler (`internal/handlers/handlers.go:50-445`)
- **Real-time**: WebSocket client with automatic reconnection
- **Display**: Carousel rotation every 5 seconds between 4 sections
- **Resolution**: Fixed 1280x400 for touchscreen display

### Data Flow
```
Prometheus Metrics → Military Transformer → Ollama AI → ASCII Art → WebSocket → Frontend Display
```

## Current Visual Design

### Color Palette (CURRENT)
- **Background**: Dark gray (#1a1a1a)
- **Primary Accent**: Orange (#ff6600) 
- **Secondary Accent**: Yellow (#ffcc00)
- **Text**: Light gray (#c0c0c0, #e0e0e0)
- **Status Colors**: Red (#ff0000), Orange (#ff8800), Yellow (#ffff00), Cyan (#00ffff), Green (#00ff00)

### Typography (CURRENT)
- **Font Stack**: 'Courier New', 'Lucida Console', monospace
- **Sizes**: 16px (headers), 14px (responses), 12px (content), 10px (intel)

### Layout Structure
1. **Header** (40px): WOPR title with blinking animation
2. **DEFCON Bar** (50px): Current alert level with pulse animation  
3. **Content Carousel** (310px): 4 rotating sections
   - ASCII Art Display (AI-generated tactical scenarios)
   - Operational Forces (Pod/service status as military units)
   - Intelligence Reports (Cluster metrics as tactical intel)
   - Ollama Response (AI personality responses)

### Current Effects
- **Animations**: Blink (2s), Pulse (1.5s)
- **Gradients**: Subtle radial gradients for depth
- **Shadows**: Text shadows and box shadows for glow effects
- **Transitions**: 1s opacity fade for carousel sections

## Key Components Analysis

### 1. WebSocket Integration
- **Real-time updates** every 5 minutes from backend
- **Auto-reconnect** with 5-second retry interval  
- **Bidirectional** command system (unused in current UI)

### 2. Carousel System
- **4 sections** with smooth opacity transitions
- **5-second rotation** timing
- **Touch-friendly** design for kiosk display

### 3. Military Theming
- **Transformer layer** converts K8s metrics to military scenarios
- **DEFCON levels** based on cluster health
- **Forces mapping** pods to military units
- **Intel reports** metrics as tactical intelligence

## Current Limitations for Retro Terminal Style

### Missing Features (User Requirements)
1. **VT323 Font**: Currently uses generic monospace fonts
2. **Black/Green Palette**: Uses orange/yellow instead of pure black/green
3. **Typing Animation**: No typewriter effect implemented
4. **Blinking Cursor**: Only has general blink animations
5. **CRT Effects**: No scanlines or flicker simulation

### Architecture Considerations
- **Embedded Frontend**: CSS/JS changes require Go recompilation
- **Static Assets**: No separate CSS/JS files (main.go:38 serves ./static/ but none exist)
- **Font Loading**: No web font integration
- **CSS Complexity**: 200+ lines of embedded CSS in Go template

## Deployment Architecture

### Kubernetes Integration
- **Namespace**: `wopr-display`
- **Ingress**: `wopr-display.k3s.home.com`
- **ARM64 Container**: Built for Raspberry Pi K3s cluster
- **Monitoring**: Prometheus ServiceMonitor integration

### Hardware Target
- **Display**: 7.84" 1280x400 touchscreen  
- **Kiosk Mode**: Lenovo mini PC with automated browser setup
- **Touch Interface**: Optimized for finger interaction

## Integration Points

### Data Sources
- **Prometheus**: `http://prometheus-k8s.monitoring.svc.cluster.local:9090`
- **Ollama API**: `http://192.168.1.185:11434` (local AI server)
- **K8s API**: Via Prometheus metrics aggregation

### External Dependencies
- **Ollama Model**: gemma3:latest for ASCII art generation
- **Monitoring Stack**: Requires prometheus-operator for metrics
- **Container Registry**: DockerHub `muldoon/wopr-display`

## Development Workflow
- **Local Development**: `go run main.go`
- **ARM64 Build**: `GOOS=linux GOARCH=arm64 go build`
- **Container Build**: Dockerfile with multi-stage build
- **Deployment**: Kubernetes manifests in `manifests/` directory