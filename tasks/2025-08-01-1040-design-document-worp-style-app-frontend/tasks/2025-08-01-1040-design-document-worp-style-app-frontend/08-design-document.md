# Design Document: WOPR Display Retro Terminal Frontend

## Executive Summary

This design document outlines the complete transformation of the WOPR Display K3s monitoring application frontend from its current orange/yellow military theme to an authentic 1980s computer terminal aesthetic. The redesign will implement VT323 monospace fonts, strict black/green color palette, universal typewriter animations, pronounced CRT monitor effects, and a terminal footer with blinking cursor, while preserving all existing functionality and ARM64 Raspberry Pi deployment compatibility.

## System Architecture

### Current Architecture Overview
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   Web Frontend      │    │   Go Backend        │    │   Data Sources      │
│   (Embedded HTML)   │◄───┤   (WebSocket)       │◄───┤   - Prometheus      │
│   - 1280x400 Fixed  │    │   - Military Theme  │    │   - Ollama API      │
│   - 4-Section UI    │    │   - Real-time Data  │    │   - K8s Metrics     │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

### Design Transformation Scope
- **Frontend Only**: No backend Go code modifications required
- **Embedded Template**: All changes within `internal/handlers/handlers.go` lines 50-445
- **Preserve APIs**: WebSocket data structures and update patterns unchanged
- **Visual Complete**: Total aesthetic transformation to terminal theme

## Design Components

### 1. Typography System

#### Font Integration
```css
@import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');

body {
    font-family: 'VT323', 'Courier New', 'Lucida Console', monospace;
}
```

#### Font Size Hierarchy (Preserved)
- **Headers**: 16px (h1 titles, section headers)
- **Responses**: 14px (Ollama AI responses)  
- **Content**: 12px (ASCII art, forces list)
- **Intel**: 10px (intelligence reports, metadata)

### 2. Color Palette Transformation

#### Color Mapping Strategy
```css
/* Background Transformation */
background-color: #000000; /* Pure black everywhere */

/* Text and UI Elements */
color: #00ff00; /* Neon green for all text */
border-color: #00ff00; /* Green borders replace orange */
text-shadow: 0 0 8px #00ff00; /* Green glow effects */

/* Accent Variations */
rgba(0, 255, 0, 0.8) /* Semi-transparent green */
rgba(0, 255, 0, 0.3) /* Low-opacity green for backgrounds */
```

#### Complete Color Replacement
- `#1a1a1a` → `#000000` (backgrounds)
- `#ff6600` → `#00ff00` (primary accents)  
- `#ffcc00` → `#00ff00` (secondary accents)
- `#c0c0c0, #e0e0e0, #f0f0f0` → `#00ff00` (all text)

### 3. Typewriter Animation System

#### Core Animation Implementation
```javascript
class TypewriterEffect {
    constructor(element, text, speed = 75) {
        this.element = element;
        this.text = text;
        this.speed = speed;
        this.currentIndex = 0;
        this.isTyping = false;
    }
    
    async startTyping() {
        this.isTyping = true;
        this.element.textContent = '';
        
        for (this.currentIndex = 0; this.currentIndex < this.text.length; this.currentIndex++) {
            if (!this.isTyping) break; // Handle interruption
            
            this.element.textContent += this.text[this.currentIndex];
            await this.delay(this.speed);
        }
        
        this.isTyping = false;
        return Promise.resolve();
    }
    
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

#### Animation Coordination Strategy
1. **Single Section Focus**: Only animate visible carousel section
2. **Content Queuing**: Queue WebSocket updates during active animations
3. **Dynamic Timing**: Extend carousel rotation to wait for typing completion
4. **Timeout Protection**: Maximum 15-second animation duration
5. **Performance Optimization**: Pre-render invisible sections instantly

### 4. CRT Monitor Effects

#### Scanline Implementation
```css
.crt-overlay::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: repeating-linear-gradient(
        0deg,
        transparent,
        transparent 2px,
        rgba(0, 255, 0, 0.1) 2px,
        rgba(0, 255, 0, 0.1) 4px
    );
    animation: scanlines 8s linear infinite;
    pointer-events: none;
    z-index: 1000;
}

@keyframes scanlines {
    0% { transform: translateY(-100%); }
    100% { transform: translateY(100%); }
}
```

#### Flicker Effect Implementation
```css
.crt-container {
    animation: flicker 3s ease-in-out infinite alternate;
}

@keyframes flicker {
    0%, 84%, 100% { opacity: 1; }
    85%, 99% { opacity: 0.92; }
}
```

#### Phosphor Glow System
```css
.terminal-text {
    color: #00ff00;
    text-shadow: 
        0 0 5px #00ff00,
        0 0 10px #00ff00,
        0 0 15px #00ff00;
}
```

### 5. Layout Architecture

#### Dimensional Restructuring
```css
.container { width: 1280px; height: 400px; } /* Unchanged */
.header { height: 40px; } /* Unchanged */
.defcon-barrier { height: 50px; } /* Unchanged */
.content { height: 280px; } /* Reduced from 310px */
.terminal-footer { height: 30px; } /* New addition */
```

#### Terminal Footer Design
```html
<div class="terminal-footer">
    <span class="terminal-prompt">></span>
    <span class="terminal-cursor">_</span>
</div>
```

```css
.terminal-footer {
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 30px;
    background-color: #000000;
    color: #00ff00;
    font-family: 'VT323', monospace;
    font-size: 16px;
    padding: 5px 10px;
    display: flex;
    align-items: center;
}

.terminal-cursor {
    animation: blink 1s infinite;
}

@keyframes blink {
    0%, 50% { opacity: 1; }
    51%, 100% { opacity: 0; }
}
```

## Data Flow Architecture

### WebSocket Integration (Unchanged)
```javascript
// Existing WebSocket data structure preserved
{
    "scenario": {
        "scenario": "PEACETIME_OPERATIONS",
        "defcon_level": 5,
        "forces": [...],
        "intel": [...]
    },
    "ascii_art": "AI-generated display",
    "response": "WOPR response text",
    "timestamp": "2025-08-01T10:40:00Z"
}
```

### Enhanced Update Handler
```javascript
function updateDisplay(data) {
    // Queue data if animations are active
    if (isTypingActive) {
        queuedUpdate = data;
        return;
    }
    
    // Process update for current visible section
    const activeSection = sections[currentSectionIndex];
    
    switch(activeSection) {
        case 'ascii-section':
            typewriterDisplay('ascii-art', data.ascii_art);
            break;
        case 'forces-section':
            typewriterForces(data.scenario.forces);
            break;
        case 'intel-section':
            typewriterIntel(data.scenario.intel);
            break;
        case 'response-section':
            typewriterDisplay('ollama-response', data.response);
            break;
    }
}
```

## Performance Considerations

### ARM64 Raspberry Pi Optimization
- **Hardware Acceleration**: Use CSS `transform` and `opacity` properties
- **Single Animation**: Only animate visible carousel section
- **Efficient Rendering**: Minimize DOM manipulation during typing
- **Memory Management**: Clean up completed animations promptly
- **Fallback Handling**: Graceful degradation for limited GPU support

### Animation Performance Strategy
```javascript
// Use requestAnimationFrame for smooth animations
function typeCharacter(element, char) {
    return new Promise(resolve => {
        requestAnimationFrame(() => {
            element.textContent += char;
            resolve();
        });
    });
}
```

## Implementation Timeline

### Phase 1: Core Transformation (Week 1)
- [ ] Font integration with Google Fonts CDN
- [ ] Complete color palette conversion
- [ ] Basic CRT effects implementation
- [ ] Terminal footer addition

### Phase 2: Animation System (Week 2)  
- [ ] Typewriter animation engine development
- [ ] Carousel coordination system
- [ ] WebSocket update queuing mechanism
- [ ] Performance optimization for ARM64

### Phase 3: Integration & Testing (Week 3)
- [ ] End-to-end testing on target hardware
- [ ] Performance validation on Raspberry Pi
- [ ] Visual effect fine-tuning
- [ ] Deployment to K3s cluster

### Phase 4: Polish & Deployment (Week 4)
- [ ] Final visual adjustments
- [ ] Documentation updates
- [ ] Production deployment
- [ ] User acceptance testing

## Testing Strategy

### Visual Testing
- [ ] Color accuracy verification across all UI elements
- [ ] Font rendering consistency on target hardware
- [ ] CRT effects visual authenticity assessment  
- [ ] Animation smoothness evaluation

### Performance Testing
- [ ] ARM64 Raspberry Pi performance benchmarking
- [ ] Memory usage monitoring during animations
- [ ] Battery life impact assessment (if applicable)
- [ ] Network dependency testing (Google Fonts CDN)

### Functional Testing
- [ ] WebSocket data flow preservation
- [ ] Carousel rotation timing coordination
- [ ] Animation queuing system validation
- [ ] Touch interaction compatibility

### Integration Testing
- [ ] K3s cluster deployment verification
- [ ] Prometheus metrics integration testing
- [ ] Ollama API connectivity validation
- [ ] Container build process confirmation

## Risk Mitigation

### Performance Risks
- **Mitigation**: Implement animation throttling, hardware acceleration, single-section focus
- **Fallback**: Graceful degradation to static display if performance inadequate

### Font Loading Risks
- **Mitigation**: Local monospace fallback fonts, CDN connectivity validation
- **Fallback**: Generic monospace fonts maintain readability

### Animation Complexity Risks
- **Mitigation**: Timeout mechanisms, queue size limits, performance monitoring
- **Fallback**: Instant display mode if animations cause issues

### Deployment Risks
- **Mitigation**: Staged rollout, rollback capability, comprehensive testing
- **Fallback**: Maintain current version as backup during deployment

## Success Metrics

### Visual Authenticity
- Complete elimination of orange/yellow colors
- Authentic 1980s terminal appearance
- Pronounced CRT monitor effects
- Consistent VT323 font usage

### Performance Targets
- Smooth 60fps animations on ARM64 hardware
- <500ms initial load time
- <100ms animation frame timing
- <50MB memory usage during operation

### User Experience Goals
- Seamless typewriter effects across all content
- Coordinated carousel timing with animations
- Authentic terminal interaction feel
- Maintained operational monitoring capability

## Conclusion

This design provides a comprehensive transformation of the WOPR Display application to achieve authentic 1980s computer terminal aesthetics while preserving all existing functionality. The implementation focuses on performance optimization for ARM64 hardware, smooth animation coordination, and visual authenticity to create an impressive retro computing showcase for the home lab environment.

The design maintains the existing military theming and data transformation logic while completely transforming the visual presentation layer, ensuring a successful balance between aesthetic goals and operational requirements.