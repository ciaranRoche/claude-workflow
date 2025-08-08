# Detailed Context Analysis: WOPR Display Frontend Implementation

## Current Frontend Architecture Deep Dive

### Template Structure Analysis
- **Location**: `internal/handlers/handlers.go:50-445`  
- **Template Size**: 395 lines of embedded HTML/CSS/JS
- **Architecture**: Single monolithic template with inline styles and scripts
- **Update Mechanism**: Go recompilation required for any frontend changes

### Current CSS Structure (Lines 56-266)
```css
/* Key Current Styles */
body { background-color: #1a1a1a; color: #c0c0c0; font-family: 'Courier New', 'Lucida Console', monospace; }
.container { width: 1280px; height: 400px; }
.header { height: 40px; border-bottom: 2px solid #ff6600; }
.defcon-barrier { border: 2px solid #ff6600; }
.content { height: 310px; }
.carousel-section { position: absolute; opacity: 0; transition: opacity 1s ease-in-out; }
```

### JavaScript Functionality Analysis (Lines 310-443)
- **WebSocket Integration**: Auto-reconnect every 5s on disconnect
- **Carousel System**: 4 sections rotating every 5s
- **Update Handlers**: Dynamic content updates via JSON data
- **Current Sections**: ascii-section, forces-section, intel-section, response-section

## Military Theming System Analysis

### Data Transformation Layer (`internal/transformer/military.go`)
- **Services → Forces**: 11 predefined service mappings (prometheus → SURVEILLANCE_NETWORK)
- **Namespaces → Locations**: 6 location mappings (monitoring → NORAD_CHEYENNE)
- **Alerts → Intel**: 9 alert type transformations (PodCrashLooping → UNIT_UNDER_ATTACK)
- **Status Mapping**: healthy → OPERATIONAL, degraded → COMPROMISED, critical → OFFLINE

### WebSocket Data Structure
```json
{
  "scenario": { "scenario": "PEACETIME_OPERATIONS", "defcon_level": 5, "forces": [...], "intel": [...] },
  "ascii_art": "AI-generated tactical display",
  "response": "WOPR AI response text",
  "timestamp": "2025-08-01T10:40:00Z"
}
```

## Frontend Implementation Requirements for Terminal Style

### 1. Font Integration Strategy
**Current**: Generic monospace fallback chain  
**Required**: VT323 from Google Fonts CDN  
**Implementation Point**: CSS `@import` in template header  
**Impact**: Global font replacement across all elements

### 2. Color Palette Transformation  
**Current Colors to Replace**:
```css
/* Background */
#1a1a1a → #000000 (pure black)

/* Accent Colors */  
#ff6600 (orange) → #00ff00 (neon green)
#ffcc00 (yellow) → #00ff00 (neon green)

/* Text Colors */
#c0c0c0, #e0e0e0, #f0f0f0 → #00ff00 (neon green)

/* Status Colors - Keep Only */
#ff0000 (red) → Remove (complete green/black only)
```

### 3. Typewriter Animation Requirements
**Scope**: ALL text content across all 4 carousel sections  
**Elements to Animate**:
- ASCII art display (12-line tactical scenarios)
- Forces list (service status as military units)  
- Intel reports (alert messages as tactical intelligence)
- Ollama responses (AI personality responses)
- Header text and DEFCON level updates

**Technical Approach**: JavaScript typing effect with character-by-character reveal

### 4. CRT Filter Implementation
**Requirements**: Pronounced vintage CRT monitor effects
- **Scanlines**: Strong horizontal lines across entire display
- **Flicker**: Noticeable screen flicker at 1-2 second intervals  
- **Curvature**: Optional screen curvature effect
- **Glow**: Green phosphor glow around text elements

### 5. Terminal Footer with Blinking Cursor
**Design**: Classic terminal prompt at bottom of display
- **Format**: `> _` with blinking underscore cursor
- **Position**: Fixed footer below main content area
- **Styling**: Same VT323 font, neon green on black
- **Animation**: Cursor blink every 500ms

## Implementation Constraints and Considerations

### Architecture Limitations
- **Embedded Template**: CSS/JS changes require Go rebuild and container restart
- **Static Assets**: No separate CSS/JS files (main.go:38 serves empty ./static/)  
- **Fixed Dimensions**: Hardcoded 1280x400 for specific touchscreen hardware
- **ARM64 Container**: Must build for Raspberry Pi K3s cluster

### WebSocket Data Flow Impact
- **Update Frequency**: 5-minute intervals for cluster data
- **Typing Animation Timing**: Must coordinate with data refresh cycles
- **Carousel Rotation**: 5-second section rotation during typing effects
- **Performance**: Typing animations across all elements simultaneously

### Deployment Considerations
- **Container Size**: VT323 font loading impact
- **Network Dependency**: Google Fonts CDN availability in K3s cluster
- **Browser Compatibility**: Touchscreen device browser capabilities
- **Performance**: CSS animation performance on ARM64 hardware

## Current WebSocket JavaScript Patterns

### Data Update Handler (Lines 341-385)
```javascript
function updateDisplay(data) {
    // Direct text content updates
    document.getElementById('ascii-art').textContent = data.ascii_art;
    document.getElementById('defcon-level').textContent = 'DEFCON ' + defconLevel;
    
    // Dynamic HTML generation for lists
    data.scenario.forces.forEach(force => {
        const div = document.createElement('div');
        div.textContent = force.name + ' [' + force.readiness + '] ' + force.status;
        forcesEl.appendChild(div);
    });
}
```

### Carousel Management (Lines 418-432)
```javascript
function rotateCarousel() {
    document.getElementById(sections[currentSectionIndex]).classList.remove('active');
    currentSectionIndex = (currentSectionIndex + 1) % sections.length;
    document.getElementById(sections[currentSectionIndex]).classList.add('active');
}
```

## Key Files for Frontend Modification

### Primary File
- `internal/handlers/handlers.go` (lines 50-445): Complete template replacement required

### Supporting Files (No Changes Required)
- `internal/websocket/hub.go`: WebSocket infrastructure (keep as-is)
- `internal/transformer/military.go`: Data transformation (keep as-is)  
- `internal/handlers/commands.go`: Command handling (keep as-is)
- `main.go`: Static asset serving (potential future CSS/JS separation)

## Performance and Technical Requirements

### Animation Performance
- **Typing Speed**: 50-100ms per character for readability
- **Concurrent Animations**: All 4 sections may type simultaneously
- **Memory Impact**: Large text content with character-by-character DOM updates
- **ARM64 Optimization**: Efficient CSS animations for Raspberry Pi hardware

### CRT Filter Implementation
- **CSS Approach**: `::before` pseudo-elements for scanlines overlay
- **Animation Approach**: CSS keyframes for flicker effects  
- **Performance**: Hardware acceleration via `transform` properties
- **Fallback**: Graceful degradation for limited hardware capabilities