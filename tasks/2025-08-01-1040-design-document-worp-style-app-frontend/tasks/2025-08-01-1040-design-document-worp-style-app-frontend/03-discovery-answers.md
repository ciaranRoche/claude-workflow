# Discovery Answers: WOPR Display Frontend Requirements

## Question 1: Font Integration Strategy
**Answer**: Use Google Fonts CDN to load VT323 font
**Implementation**: `@import url('https://fonts.googleapis.com/css2?family=VT323&display=swap')`

## Question 2: Color Palette Transition Approach  
**Answer**: Complete transition to strict black/green - authentic WOPR terminal replication
**Implementation**: 
- Background: Pure black (#000000)
- Text/UI: Neon green (#00ff00) 
- No orange/yellow preservation - full terminal authenticity

## Question 3: Typing Animation Implementation Scope
**Answer**: Apply typewriter effects to ALL text content across all carousel views
**Implementation**: Every element (ASCII art, forces, intel, responses) gets seamless typing animation for complete WOPR replication

## Question 4: CRT Filter Intensity Level
**Answer**: Pronounced CRT effects for maximum authentic retro aesthetics
**Implementation**: Strong scanlines and noticeable flicker effects - visual showcase over operational readability since this is supplementary to AlertManager/Grafana

## Question 5: Blinking Cursor Implementation Context
**Answer**: Blinking cursor as footer element to create terminal illusion
**Implementation**: Terminal-style footer with blinking cursor (no interactive input) - pure visual terminal replication with cursor at bottom of screen

---

## Summary of Requirements
- **Complete visual transformation** to authentic WOPR terminal
- **VT323 font** from Google Fonts CDN
- **Strict black/green palette** (#000000/#00ff00)
- **Universal typewriter effects** on all content
- **Pronounced CRT effects** (strong scanlines + flicker)
- **Terminal footer** with blinking cursor for authenticity
- **Visual showcase focus** - aesthetics over operational readability