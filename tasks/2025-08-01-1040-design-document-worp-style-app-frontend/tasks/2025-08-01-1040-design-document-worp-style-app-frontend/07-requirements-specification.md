# Requirements Specification: WOPR Display Frontend Transformation

## Problem Statement
Transform the existing WOPR Display K3s monitoring application from its current orange/yellow color scheme to an authentic WOPR terminal aesthetic with strict black/green colors, VT323 monospace font, typewriter animations, and CRT monitor effects while maintaining the existing military-themed data visualization and ARM64 Raspberry Pi deployment compatibility.

## Solution Overview
Complete frontend redesign of the embedded HTML/CSS/JS template in `internal/handlers/handlers.go` to replicate classic 1980s computer terminal visuals with modern web technologies, preserving all existing functionality while transforming the visual presentation to match the WarGames movie aesthetic.

## Functional Requirements

### FR-1: Typography Transformation
- **FR-1.1**: Replace all fonts with VT323 loaded from Google Fonts CDN
- **FR-1.2**: Maintain existing font size hierarchy (16px headers, 14px responses, 12px content, 10px intel)
- **FR-1.3**: Apply VT323 to all text elements: headers, content, status indicators, and terminal footer
- **FR-1.4**: Implement fallback to generic monospace fonts if CDN unavailable

### FR-2: Color Palette Conversion
- **FR-2.1**: Convert background from #1a1a1a to pure black (#000000)
- **FR-2.2**: Convert all accent colors (orange #ff6600, yellow #ffcc00) to neon green (#00ff00)
- **FR-2.3**: Convert all text colors to neon green (#00ff00)
- **FR-2.4**: Maintain visual hierarchy through opacity variations and glow effects
- **FR-2.5**: Remove all non-black/green colors except for transition states

### FR-3: Typewriter Animation System
- **FR-3.1**: Implement character-by-character typing animation at 50-100ms per character
- **FR-3.2**: Apply to ALL text content across all 4 carousel sections:
  - ASCII art displays (AI-generated tactical scenarios)
  - Forces list (Kubernetes services as military units)  
  - Intel reports (cluster alerts as tactical intelligence)
  - Ollama AI responses (WOPR personality interactions)
- **FR-3.3**: Animate only the currently visible carousel section for performance
- **FR-3.4**: Queue WebSocket updates during active animations (do not interrupt)
- **FR-3.5**: Extend carousel rotation timing dynamically to wait for typing completion (max 15s timeout)

### FR-4: CRT Monitor Effects
- **FR-4.1**: Implement pronounced horizontal scanlines using CSS `::before` pseudo-elements
- **FR-4.2**: Add subtle vertical scrolling animation to scanlines (5-10 second cycle)
- **FR-4.3**: Implement screen flicker effect with noticeable intensity for authenticity
- **FR-4.4**: Add green phosphor glow effects around text elements
- **FR-4.5**: Use hardware-accelerated CSS transforms for ARM64 optimization

### FR-5: Terminal Footer Interface
- **FR-5.1**: Add terminal-style footer at bottom of display (30px height)
- **FR-5.2**: Display format: `> _` with blinking underscore cursor
- **FR-5.3**: Reduce main content area from 310px to 280px to accommodate footer
- **FR-5.4**: Cursor blink animation at 500ms intervals
- **FR-5.5**: Maintain total 400px display height for touchscreen compatibility

### FR-6: Animation Coordination
- **FR-6.1**: Coordinate typewriter animations with 5-second carousel rotation
- **FR-6.2**: Pre-render invisible carousel sections instantly (no animation)
- **FR-6.3**: Trigger typing animation when section becomes visible
- **FR-6.4**: Handle content length variations gracefully with timeout mechanism
- **FR-6.5**: Preserve smooth visual experience over real-time data accuracy

## Technical Requirements

### TR-1: Performance Optimization
- **TR-1.1**: Optimize for ARM64 Raspberry Pi hardware limitations
- **TR-1.2**: Use hardware-accelerated CSS properties (transform, opacity)
- **TR-1.3**: Minimize DOM manipulation during animations
- **TR-1.4**: Implement efficient character-by-character rendering
- **TR-1.5**: Avoid concurrent animations across multiple sections

### TR-2: WebSocket Integration
- **TR-2.1**: Maintain existing WebSocket data structure and update frequency (5 minutes)
- **TR-2.2**: Preserve existing updateDisplay() function signatures
- **TR-2.3**: Queue incoming WebSocket data during active typing animations
- **TR-2.4**: Ensure animation state management doesn't block WebSocket processing
- **TR-2.5**: Handle WebSocket reconnection without breaking animation state

### TR-3: Layout Compatibility
- **TR-3.1**: Maintain fixed 1280x400 pixel dimensions for touchscreen
- **TR-3.2**: Preserve existing carousel section structure (4 sections)
- **TR-3.3**: Keep header (40px) and DEFCON barrier (50px) proportions
- **TR-3.4**: Adjust content area height to 280px for terminal footer
- **TR-3.5**: Ensure touch-friendly interactive elements remain accessible

### TR-4: Browser Compatibility
- **TR-4.1**: Support modern browsers on ARM64 Linux touchscreen devices
- **TR-4.2**: Graceful degradation for limited CSS animation support
- **TR-4.3**: Fallback fonts for offline Google Fonts CDN scenarios
- **TR-4.4**: Responsive behavior within fixed 1280x400 constraints
- **TR-4.5**: Touch event compatibility for kiosk mode operation

### TR-5: Deployment Requirements
- **TR-5.1**: Maintain embedded template architecture (no external CSS/JS files)
- **TR-5.2**: Preserve Go build process and ARM64 container compatibility
- **TR-5.3**: Keep total template size manageable for compilation
- **TR-5.4**: Ensure CDN dependencies work within K3s cluster networking
- **TR-5.5**: Maintain existing Kubernetes deployment manifests compatibility

## Implementation Constraints

### IC-1: Architecture Limitations
- **IC-1.1**: All changes must be made to embedded template in `internal/handlers/handlers.go`
- **IC-1.2**: CSS and JavaScript remain inline within Go template
- **IC-1.3**: No separate static asset files can be introduced
- **IC-1.4**: Changes require Go recompilation and container rebuild
- **IC-1.5**: No modification to WebSocket data structures or backend Go code

### IC-2: Hardware Constraints  
- **IC-2.1**: ARM64 Raspberry Pi 4 performance limitations
- **IC-2.2**: 1280x400 touchscreen display fixed resolution
- **IC-2.3**: Kiosk mode browser environment restrictions
- **IC-2.4**: Limited GPU acceleration capabilities
- **IC-2.5**: Network connectivity requirements for Google Fonts CDN

### IC-3: Operational Constraints
- **IC-3.1**: Must not break existing military scenario data transformation
- **IC-3.2**: Preserve all current WebSocket communication patterns
- **IC-3.3**: Maintain existing Prometheus metrics integration
- **IC-3.4**: Keep Ollama AI integration functional
- **IC-3.5**: Preserve existing command handling capabilities

## Acceptance Criteria

### AC-1: Visual Transformation Complete
- [ ] All text uses VT323 font from Google Fonts CDN
- [ ] Complete black (#000000) and neon green (#00ff00) color palette
- [ ] No orange, yellow, or other non-terminal colors visible
- [ ] Terminal footer with blinking cursor displayed at bottom
- [ ] Pronounced CRT scanlines and flicker effects active

### AC-2: Animation System Functional
- [ ] Typewriter animations work on all 4 carousel sections
- [ ] Only visible section animates at 50-100ms per character
- [ ] Carousel rotation waits for typing completion (max 15s)
- [ ] WebSocket updates queue during active animations
- [ ] Animation state handles content length variations gracefully

### AC-3: Performance Requirements Met
- [ ] Smooth animations on ARM64 Raspberry Pi hardware
- [ ] No visual stuttering or performance degradation
- [ ] Hardware-accelerated CSS effects function properly
- [ ] Memory usage remains within acceptable limits
- [ ] Touch responsiveness maintained during animations

### AC-4: Integration Preserved
- [ ] All existing WebSocket data updates function correctly
- [ ] Military scenario transformation displays properly
- [ ] Carousel rotation timing coordination works as designed
- [ ] Command handling system remains functional
- [ ] Kubernetes deployment process unchanged

### AC-5: Deployment Compatibility
- [ ] Go compilation successful with embedded template changes
- [ ] ARM64 container builds and deploys to K3s cluster
- [ ] Touchscreen display renders correctly at 1280x400
- [ ] Google Fonts CDN loads successfully in cluster network
- [ ] Kiosk mode browser compatibility maintained

## Assumptions and Dependencies

### Assumptions
- Google Fonts CDN is accessible from K3s cluster network
- ARM64 Raspberry Pi hardware supports CSS animations adequately  
- Existing WebSocket update frequency (5 minutes) is sufficient for queued updates
- Current military theming and data transformation logic remains unchanged
- Touchscreen device browser supports modern CSS features

### Dependencies
- Google Fonts CDN for VT323 font delivery
- Existing Prometheus metrics system for cluster data
- Ollama API for AI-generated ASCII art and responses
- WebSocket infrastructure for real-time updates
- K3s cluster networking and ingress configuration

## Risk Assessment and Mitigation

### High Risk: Performance Impact
- **Risk**: Complex animations may overwhelm ARM64 hardware
- **Mitigation**: Implement single-section animation, hardware acceleration, graceful degradation

### Medium Risk: Font Loading Failure
- **Risk**: Google Fonts CDN unavailable in cluster environment
- **Mitigation**: Implement fallback to local monospace fonts, test CDN connectivity

### Medium Risk: Animation Timing Issues
- **Risk**: Long content causing carousel timing problems
- **Mitigation**: Implement maximum timeout, dynamic timing adjustment, content length detection

### Low Risk: Visual Accessibility
- **Risk**: High contrast green/black may impact readability
- **Mitigation**: Use opacity variations, glow effects, maintain sufficient contrast ratios