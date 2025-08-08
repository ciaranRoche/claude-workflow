# Expert-Level Questions: WOPR Display Technical Implementation

## Question 1: Typewriter Animation Synchronization Strategy
**Question**: Should the typewriter animations wait for each section to complete typing before starting the next carousel rotation, or should the 5-second carousel rotation continue independently while typing animations are in progress?

**Smart Default**: Extend carousel timing dynamically based on content length - wait for typing completion before rotating, with a maximum 15-second timeout to prevent indefinite delays on long content.

**Technical Context**: Current carousel rotates every 5 seconds, but with typewriter effects at 50-100ms per character, long ASCII art or intel reports could take 10+ seconds to fully type. The WebSocket sends updates every 5 minutes with potentially different content lengths each time.

---

## Question 2: WebSocket Update Handling During Animations
**Question**: When new WebSocket data arrives while typewriter animations are still in progress, should we interrupt the current animations and start fresh, or queue the new data until current animations complete?

**Smart Default**: Interrupt current animations and immediately start fresh with new data to ensure the display always shows the most current cluster state, since this is operational monitoring data.

**Technical Context**: WebSocket updates arrive every 5 minutes with fresh cluster metrics. The military transformer may generate completely different scenarios, force lists, and intel reports that should take priority over partially-typed old data.

---

## Question 3: CRT Scanline Implementation Approach
**Question**: Should the scanlines be implemented as a CSS overlay using `::before` pseudo-elements, SVG patterns, or CSS gradients, and should they scroll/animate or remain static?

**Smart Default**: Use CSS `::before` pseudo-element with repeating linear gradient for performance, with subtle vertical scrolling animation (5-10 second cycle) to simulate authentic CRT phosphor persistence.

**Technical Context**: The display runs on ARM64 Raspberry Pi hardware via touchscreen, so performance is critical. CSS transforms are hardware-accelerated, while complex SVG patterns may impact performance on limited hardware.

---

## Question 4: Multi-Section Typing Coordination  
**Question**: Since the carousel shows one section at a time but all sections get updated via WebSocket, should invisible sections also run typing animations simultaneously, or only animate the currently visible section?

**Smart Default**: Only animate the currently visible section to optimize performance, pre-render invisible sections instantly, then apply typing animation when they become visible during carousel rotation.

**Technical Context**: All 4 sections (ASCII art, forces, intel, responses) receive data simultaneously via WebSocket updateDisplay() function. Running 4 concurrent typing animations could overwhelm the ARM64 processor and cause visual stuttering.

---

## Question 5: Terminal Footer Integration with Fixed Layout
**Question**: Should the terminal footer with blinking cursor reduce the main content area height (currently 310px) to accommodate it, or overlay on top of the existing layout?

**Smart Default**: Reduce main content area to 280px height and add 30px terminal footer, maintaining the total 400px display height while ensuring all content remains fully visible within the fixed touchscreen dimensions.

**Technical Context**: The display is hardcoded for 1280x400 touchscreen with specific height allocations: header (40px), DEFCON barrier (50px), content (310px). The footer needs space without breaking the existing military dashboard layout or causing content to be cut off.