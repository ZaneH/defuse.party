# Landing Page Design

## Overview
Modern terminal-themed landing page for defuse.party TUI game. Built with Three.js for 3D bomb visualization.

## Design Philosophy
- **Get users playing ASAP** - Minimal explanation, maximum focus on SSH command
- **Modern dark terminal aesthetic** - Monospace fonts, terminal window frame, programmer-friendly
- **Keep the mystery** - No screenshots of actual TUI, let the 3D bomb be the preview

## Key Features

### Terminal Window Frame
- macOS-style window with colored dots (red/yellow/green)
- Title bar displays "defuse.party"
- Creates authentic terminal application feel
- Box borders with subtle shadows

### 3D Bomb Visualization
- Three.js scene with GLTF models (bomb + modules)
- Auto-rotating with orbit controls
- Loads multiple module types: big-button, simon-says, wires, morse, clock, maze, needy-knob
- 700x400px canvas (responsive down to 300px on mobile)
- Loading spinner during model load

### SSH Command Block
- Click-to-copy functionality
- Blinking cursor animation (1s step-end)
- Hover effect with mint green glow (#6ee7b7)
- Copy tooltip with fade animation
- Monospace font styling

### Tagline
`// bomb defusal in your terminal`
- Brief, mysterious, terminal-styled
- Comment syntax appeals to programmer audience

### Footer (Terminal Status Bar)
- Integrated into terminal window (not fixed position)
- Links to web game (bomb.zaaane.com) and GitHub repo
- Hover effect changes color to mint green
- Responsive flex layout

## Color Palette

```css
Background:        #0d0d12 → #1a1a24 (radial gradient)
Terminal BG:       #0f0f16
Border:            #2a2a3a
Accent (hover):    #6ee7b7 (mint green)
Text:              #e0e0e0
Dim text:          #5a5a6a
Status bar BG:     #0a0a0f
```

## Typography
All text uses monospace:
- SF Mono (macOS)
- Fira Code (programmer font)
- Consolas (Windows)
- Monaco (fallback)

## Responsive Design
- Max width: 700px desktop, 100% mobile
- Canvas: 400px desktop → 300px mobile
- Terminal header padding reduces on small screens
- Footer flex-wraps on narrow viewports

## Assets
- `bomb.glb` - Main bomb model
- `big-button.glb`, `simon-says.glb`, `simple-wires.glb` - Module models
- `morse.glb`, `clock.glb`, `maze.glb`, `needy-knob.glb` - Additional modules

## Technical Notes
- Uses Three.js v0.160.0 via CDN (unpkg)
- DRACO loader for compressed GLTF models (via Google CDN)
- No build step - single HTML file
- Works offline after first load (browser caching)
- Dark Reader disabled via meta tag

## Target Audience
- Programmers familiar with SSH/terminals
- KTANE (Keep Talking and Nobody Explodes) fans
- Terminal enthusiasts and CLI tool users

## Future Enhancements
- Optional: Subtle scanline overlay for CRT effect
- Optional: Typing animation for SSH command on load
- Optional: Terminal history showing previous connections
