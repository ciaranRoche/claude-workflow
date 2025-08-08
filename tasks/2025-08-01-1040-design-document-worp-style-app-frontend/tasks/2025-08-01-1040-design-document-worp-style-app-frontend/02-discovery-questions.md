# Discovery Questions: WOPR Display Frontend Requirements

## Question 1: Font Integration Strategy
**Question**: Should we load the VT323 font from Google Fonts CDN, bundle it locally in the application, or use a different web font source?

**Smart Default**: Load VT323 from Google Fonts CDN (`@import url('https://fonts.googleapis.com/css2?family=VT323&display=swap')`) as it's the most reliable and performant option for the specified retro terminal font.

**Reasoning**: Google Fonts CDN provides the authentic VT323 font with built-in caching, fallback handling, and optimal delivery. Since the WOPR display runs in a connected K3s environment, CDN access should be reliable. Local bundling would increase container size and complicate updates.

---

## Question 2: Color Palette Transition Approach  
**Question**: Should we completely replace the current orange/yellow color scheme with strict black/green, or maintain some orange accents for alerts while making green the primary theme?

**Smart Default**: Complete transition to strict black (#000000) background and neon green (#00ff00) as primary color, but preserve red (#ff0000) for critical DEFCON 1 alerts to maintain functional color coding for emergency states.

**Reasoning**: User specifically requested "strictly black and neon green" palette, indicating a desire for authentic terminal aesthetics. However, preserving red for maximum alert states maintains critical safety visibility for cluster monitoring while staying true to classic terminal color schemes.

---

## Question 3: Typing Animation Implementation Scope
**Question**: Should the typewriter effect apply to all text content (ASCII art, status updates, responses) or only specific elements like the AI responses and command outputs?

**Smart Default**: Apply typing animation primarily to AI responses and ASCII art generation, while keeping status information (forces, intel) as instant updates to maintain operational readability and avoid overwhelming visual effects.

**Reasoning**: Based on the current carousel system, applying typewriter effects to everything would create visual chaos and reduce operational readability. Focusing on AI-generated content (responses and ASCII art) provides the retro feel while keeping critical monitoring data immediately visible.

---

## Question 4: CRT Filter Intensity Level
**Question**: What intensity level should the CRT effects (scanlines and flicker) have - subtle for operational readability, or more pronounced for authentic retro aesthetics?

**Smart Default**: Implement subtle CRT effects with 0.8 opacity scanlines and minimal flicker (0.95-1.0 opacity range at 2-3 second intervals) to maintain readability for operational monitoring while providing authentic retro visual appeal.

**Reasoning**: Since this is an operational monitoring display for a K3s cluster, readability must take priority over pure aesthetics. Subtle effects provide the desired retro feel without compromising the ability to quickly read critical system status information.

---

## Question 5: Blinking Cursor Implementation Context
**Question**: Where should the blinking cursor appear - as a general screen element, at the end of text during typing animations, or in a command input area for interactive use?

**Smart Default**: Implement the blinking cursor at the end of typing animations for AI responses and ASCII art, plus add a command prompt area at the bottom of the display with a persistent blinking cursor for potential interactive commands.

**Reasoning**: The current application has command handling capability (HandleCommand) but no visible input interface. Adding a terminal-style command prompt with blinking cursor enhances both the retro aesthetic and provides potential for future interactive features while staying true to classic terminal behavior.