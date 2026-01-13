# KTANE TUI Implementation Plan

## Overview

Build a Terminal User Interface (TUI) for "Keep Talking and Nobody Explodes" using:
- **Go + Bubbletea** for the TUI framework
- **Charmbracelet Wish** for SSH server delivery
- **Existing gRPC backend** (`keep-talking/`) for game logic

The TUI will be a **new service** that acts as a gRPC client to the existing backend.

---

## Project Structure

```
keep-talking-tui/
├── cmd/
│   └── server/
│       └── main.go              # SSH server entry point
├── internal/
│   ├── client/
│   │   └── grpc.go              # gRPC client to backend
│   ├── tui/
│   │   ├── app.go               # Main Bubbletea model
│   │   ├── header.go            # Timer + strikes header component
│   │   ├── footer.go            # Command hints footer
│   │   ├── module_list.go       # Module overview/selection
│   │   └── modules/
│   │       ├── base.go          # Module interface + helpers
│   │       ├── wires.go         # Wires module TUI
│   │       ├── big_button.go    # Big Button module TUI
│   │       ├── simon.go         # Simon Says module TUI
│   │       ├── password.go      # Password module TUI
│   │       ├── keypad.go        # Keypad module TUI
│   │       ├── whos_on_first.go # Who's On First module TUI
│   │       ├── memory.go        # Memory module TUI
│   │       ├── morse.go         # Morse Code module TUI
│   │       ├── maze.go          # Maze module TUI
│   │       ├── needy_vent.go    # Needy Vent Gas module TUI
│   │       └── needy_knob.go    # Needy Knob module TUI
│   └── styles/
│       └── styles.go            # Lipgloss styles
├── proto/                       # Symlink or copy from keep-talking/proto
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

---

## Phase 1: Foundation (SSH Server + Basic Shell)

### 1.1 Project Setup
- [x] Initialize Go module: `github.com/ZaneH/keep-talking-tui`
- [x] Add dependencies:
  - `github.com/charmbracelet/wish` (SSH server)
  - `github.com/charmbracelet/bubbletea` (TUI framework)
  - `github.com/charmbracelet/lipgloss` (styling)
  - `github.com/charmbracelet/bubbles` (reusable components)
  - `google.golang.org/grpc` (gRPC client)
- [x] Copy proto files from `keep-talking/proto/`
- [x] Generate Go protobuf client code

### 1.2 gRPC Client
- [x] Create client wrapper in `internal/client/grpc.go`
- [x] Implement methods:
  ```go
  type GameClient interface {
      CreateGame(ctx context.Context) (sessionID string, err error)
      GetBombs(ctx context.Context, sessionID string) ([]*pb.Bomb, error)
      SendInput(ctx context.Context, input *pb.PlayerInput) (*pb.PlayerInputResult, error)
  }
  ```

### 1.3 SSH Server Setup
- [x] Create Wish server with Bubbletea middleware
- [x] Configure SSH key handling (auto-generate host keys)
- [x] Basic connection logging
- [ ] Configuration via environment variables:
  - `TUI_SSH_PORT` (default: 2222)
  - `TUI_GRPC_ADDR` (default: localhost:50051)

---

## Phase 2: Core TUI Architecture

### 2.1 Main Application Model

```go
type AppState int
const (
    StateMenu AppState = iota
    StateModuleList     // Viewing all modules
    StateModuleActive   // Interacting with a module
    StateGameOver       // Win or explosion
)

type Model struct {
    state        AppState
    client       client.GameClient
    sessionID    string
    bombs        []*pb.Bomb
    activeBomb   *pb.Bomb
    activeModule ModuleModel  // Current module being interacted with

    // UI state
    width, height int
    selectedIdx   int

    // Timer
    startedAt    time.Time
    duration     time.Duration
}
```

### 2.2 Header Component
Displays at top of screen (always visible):
```
┌─────────────────────────────────────────────────────────────────────┐
│ KEEP TALKING AND NOBODY EXPLODES - DEFUSER TERMINAL               │
│ Time Remaining: 03:00 | Strikes: ☐ ☐ ☐ | Serial: AB3CD5           │
└─────────────────────────────────────────────────────────────────────┘
```
- [ ] Timer countdown (updates every second via `tea.Tick`)
- [ ] Strike indicators (☐ empty, ☒ struck)
- [ ] Serial number display
- [ ] Flashing/color change when strike occurs

### 2.3 Footer Component
Command hints (context-sensitive):
```
Commands: [S]witch module | [R]ead state | [H]elp | [Q]uit
```

### 2.4 Module List View
Grid of all modules showing status:
```
┌────────────────────┬────────────────────┬────────────────────────┐
│ MODULE 1: WIRES    │ MODULE 2: BUTTON   │ MODULE 3: KEYPAD       │
│ [✓ SOLVED]         │ [○ PENDING]        │ [◉ ACTIVE]             │
└────────────────────┴────────────────────┴────────────────────────┘
```
- [ ] Arrow key navigation
- [ ] Enter to select/focus module
- [ ] Visual indication of solved/pending/active

---

## Phase 3: Module Implementations

Each module implements a common interface:

```go
type ModuleModel interface {
    tea.Model
    ID() string
    Type() pb.ModuleType
    IsSolved() bool
    Render(width, height int) string
}
```

### 3.1 Wires Module
**Input**: Number key (1-6) to cut wire
**Display**:
```
│  Wire 1: ████████████████ RED                                    │
│  Wire 2: ████████████████ BLUE                                   │
│  Wire 3: ─ ─ ─ ─ ─ ─ ─ ─  YELLOW (CUT)                          │
│  Wire 4: ████████████████ BLACK                                  │
│                                                                   │
│  > Cut wire [1-4]:                                               │
```
- [ ] Colored wire blocks using lipgloss
- [ ] Show cut state (dashed line)
- [ ] 3-6 wires dynamically

### 3.2 Big Button Module
**Input**: `T` for tap, `H` to hold (then release with `R`)
**Display**:
```
│     ╔═══════════════════╗                                        │
│     ║                   ║                                        │
│     ║      [ABORT]      ║   Color: BLUE                         │
│     ║                   ║   Label: ABORT                        │
│     ╚═══════════════════╝                                        │
│                                                                   │
│     Strip Color: YELLOW (release when timer has 4)              │
│                                                                   │
│  > [T]ap or [H]old (then [R]elease):                            │
```
- [ ] Button color displayed
- [ ] Strip color appears on hold
- [ ] Release timing display

### 3.3 Simon Says Module
**Input**: `R`/`B`/`Y`/`G` for colors
**Display** (from your mockup):
```
│                     ╔═══════╗                                    │
│                     ║ [RED] ║                                    │
│                ╔═══════╗ ╔═══════╗                               │
│                ║ [BLU] ║ ║ [YEL] ║                               │
│                ╚═══════╝ ╚═══════╝                               │
│                     ╔═══════╗                                    │
│                     ║ [GRN] ║                                    │
│                     ╚═══════╝                                    │
│    Sequence Shown:  [YEL] → [RED] → [BLU]                       │
│    Your Input:  [YEL] [RED] [___]                                │
```
- [ ] Flashing animation via lipgloss bold/bright
- [ ] Sequence display
- [ ] Input progress tracking

### 3.4 Password Module
**Input**: Arrow keys to scroll letters, `Enter` to submit
**Display**:
```
│     ┌───┬───┬───┬───┬───┐                                       │
│     │ A │ B │ O │ U │ T │                                       │
│     │ ▲ │ ▲ │ ▲ │ ▲ │ ▲ │                                       │
│     │ ▼ │ ▼ │ ▼ │ ▼ │ ▼ │                                       │
│     └───┴───┴───┴───┴───┘                                       │
│                                                                   │
│  > Use ←/→ to select column, ↑/↓ to change letter              │
│  > Press [Enter] to submit                                       │
```
- [ ] 5 columns with scrollable letters
- [ ] Current column highlight
- [ ] Submit action

### 3.5 Keypad Module
**Input**: Number keys 1-4 to press symbols
**Display**:
```
│     ┌─────────┬─────────┐                                        │
│     │    ©    │    Ω    │                                        │
│     │   [1]   │   [2]   │                                        │
│     ├─────────┼─────────┤                                        │
│     │    ¶    │    λ    │                                        │
│     │   [3]   │   [4]   │                                        │
│     └─────────┴─────────┘                                        │
│                                                                   │
│  Pressed: © ✓                                                    │
│  > Press symbol [1-4]:                                           │
```
- [ ] Symbol character mapping (Unicode approximations)
- [ ] Pressed state indicators

### 3.6 Who's On First Module
**Input**: Number key to select button word
**Display**:
```
│     Screen: "BLANK"                                              │
│                                                                   │
│     ┌─────────┬─────────┐                                        │
│     │ [1]YES  │ [2]WHAT │                                        │
│     ├─────────┼─────────┤                                        │
│     │ [3]UHHH │ [4]WAIT │                                        │
│     ├─────────┼─────────┤                                        │
│     │ [5]READY│ [6]PRESS│                                        │
│     └─────────┴─────────┘                                        │
│                                                                   │
│     Stage: 2/3                                                   │
```
- [ ] Screen word display
- [ ] 6 button words
- [ ] Stage progress

### 3.7 Memory Module
**Input**: Number key 1-4 for button position
**Display**:
```
│     Screen Display: [ 3 ]                                        │
│                                                                   │
│     ┌───┬───┬───┬───┐                                           │
│     │ 2 │ 4 │ 1 │ 3 │                                           │
│     │[1]│[2]│[3]│[4]│                                           │
│     └───┴───┴───┴───┘                                           │
│                                                                   │
│     Stage: 3/5                                                   │
│     > Press button [1-4]:                                        │
```
- [ ] Large screen number display
- [ ] 4 buttons with labels and positions
- [ ] Stage progress

### 3.8 Morse Code Module
**Input**: `←`/`→` to change frequency, `Enter` to transmit
**Display**:
```
│     ╭─────────────────────────────────────╮                      │
│     │  ● ● ● ─ ─ ─ ● ● ●                  │   ● = blinking      │
│     │  (... --- ...)                      │                      │
│     ╰─────────────────────────────────────╯                      │
│                                                                   │
│     Frequency: [◀ 3.505 MHz ▶]                                  │
│                                                                   │
│  > ←/→ to change frequency, [Enter] to TX                       │
```
- [ ] Morse pattern display (animated blink via tick)
- [ ] Frequency slider
- [ ] TX action

### 3.9 Maze Module
**Input**: `W`/`A`/`S`/`D` or arrow keys
**Display** (from your mockup):
```
│    ┌─┬───┬─┬───┬─┬───┐                                          │
│    │ │   │ │   │ │   │                                          │
│    ├ ┼ ┬ ┤ └ ┬ ┴ ┤ ┬ ┤                                          │
│    │ │ │ │ ◉ │   │ │ │    ◉ = You                              │
│    ├ ┴ ┤ ├ ┬ ┼ ┬ ┴ ┤ ├                                          │
│    │   │ │ │ │ │   │ │    ● = Target                           │
│    ├ ┬ ┴ ┤ ├ ┤ ├ ┬ ┤ │                                          │
│    │ │   │ │ │ │ │ │ │    ○ = Marker                           │
│    ├ ┴ ┬ ┴ ┤ └ ┤ ├ ┤ ●                                          │
│    │   │   │   │ │ │ │                                          │
│    └───┴───┴───┴─┴─┴─┘                                          │
```
- [ ] 6x6 maze grid with box-drawing characters
- [ ] Player position (◉)
- [ ] Goal position (●)
- [ ] Marker positions (○)
- [ ] Wall rendering (need maze data from backend - note: backend doesn't expose walls, only validates moves)

### 3.10 Needy Vent Gas Module
**Input**: `Y`/`N`
**Display**:
```
│     ╔═════════════════════════════╗                              │
│     ║   VENT GAS?       [15s]    ║                              │
│     ║                             ║                              │
│     ║      [Y]ES    [N]O          ║                              │
│     ╚═════════════════════════════╝                              │
```
- [ ] Countdown timer
- [ ] Question display
- [ ] Y/N input

### 3.11 Needy Knob Module
**Input**: `R` to rotate
**Display**:
```
│     LED Pattern:                                                 │
│     ○ ● ● ○ ● ○       [18s]                                     │
│     ● ○ ○ ● ○ ●                                                 │
│                                                                   │
│     Dial Position: [▲ NORTH]                                    │
│                                                                   │
│  > Press [R] to rotate clockwise                                │
```
- [ ] LED pattern (● lit, ○ unlit)
- [ ] Current dial direction
- [ ] Countdown timer

---

## Phase 4: Game Flow & Polish

### 4.1 Game State Management
- [ ] Create game on SSH connection
- [ ] Fetch bombs and initialize modules
- [ ] Handle module switching
- [ ] Track strikes (flash screen red on strike)
- [ ] Win condition (all modules solved)
- [ ] Loss condition (3 strikes or timer expires)

### 4.2 Timer System
- [ ] Real-time countdown using `tea.Tick`
- [ ] Sync with server `started_at` timestamp
- [ ] Warning colors as time runs low (<1 min, <30s)

### 4.3 Visual Polish
- [ ] Lipgloss color scheme (consistent across modules)
- [ ] Box-drawing characters for borders
- [ ] Strike flash effect (red background momentarily)
- [ ] Solved module green highlight
- [ ] Responsive layout (adapt to terminal size)

### 4.4 Sound Effects (Optional)
- [ ] Terminal bell (`\a`) on strike
- [ ] Terminal bell pattern on explosion
- [ ] Consider: ANSI escape for sound on supporting terminals

---

## Phase 5: Deployment & Testing

### 5.1 Docker Support
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o /tui-server ./cmd/server

FROM alpine:latest
COPY --from=builder /tui-server /tui-server
EXPOSE 2222
CMD ["/tui-server"]
```

### 5.2 Docker Compose Integration
Update existing `docker-compose.yml` to include TUI service:
```yaml
services:
  grpc-server:
    # existing...

  tui-server:
    build: ./keep-talking-tui
    ports:
      - "2222:2222"
    environment:
      - TUI_GRPC_ADDR=grpc-server:50051
    depends_on:
      - grpc-server
```

### 5.3 Testing
- [ ] Unit tests for module rendering
- [ ] Integration tests for gRPC client
- [ ] Manual SSH testing with various terminals

---

## Technical Considerations

### Keypad Symbols Unicode Mapping
```go
var symbolMap = map[pb.Symbol]string{
    pb.Symbol_COPYRIGHT:    "©",
    pb.Symbol_FILLEDSTAR:   "★",
    pb.Symbol_HOLLOWSTAR:   "☆",
    pb.Symbol_SMILEYFACE:   "☺",
    pb.Symbol_DOUBLEK:      "Ж",
    pb.Symbol_OMEGA:        "Ω",
    pb.Symbol_SQUIDKNIFE:   "Ѯ",
    pb.Symbol_PUMPKIN:      "Ѫ",
    pb.Symbol_HOOKN:        "Ҩ",
    pb.Symbol_SIX:          "б",
    pb.Symbol_SQUIGGLYN:    "Ҋ",
    pb.Symbol_AT:           "Ѧ",
    pb.Symbol_AE:           "Æ",
    pb.Symbol_MELTEDTHREE:  "Ӭ",
    pb.Symbol_EURO:         "€",
    pb.Symbol_NWITHHAT:     "Ñ",
    pb.Symbol_DRAGON:       "Ψ",
    pb.Symbol_QUESTIONMARK: "¿",
    pb.Symbol_PARAGRAPH:    "¶",
    pb.Symbol_RIGHTC:       "Ͽ",
    pb.Symbol_LEFTC:        "Ͼ",
    pb.Symbol_PITCHFORK:    "Ѱ",
    pb.Symbol_CURSIVE:      "ϗ",
    pb.Symbol_TRACKS:       "☰",
    pb.Symbol_BALLOON:      "Ѳ",
    pb.Symbol_UPSIDEDOWNY:  "λ",
    pb.Symbol_BT:           "Ƀ",
}
```

### Wire Colors via Lipgloss
```go
var wireColors = map[pb.Color]lipgloss.Style{
    pb.Color_RED:    lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Background(lipgloss.Color("196")),
    pb.Color_BLUE:   lipgloss.NewStyle().Foreground(lipgloss.Color("21")).Background(lipgloss.Color("21")),
    pb.Color_YELLOW: lipgloss.NewStyle().Foreground(lipgloss.Color("226")).Background(lipgloss.Color("226")),
    pb.Color_BLACK:  lipgloss.NewStyle().Foreground(lipgloss.Color("232")).Background(lipgloss.Color("232")),
    pb.Color_WHITE:  lipgloss.NewStyle().Foreground(lipgloss.Color("255")).Background(lipgloss.Color("255")),
}
```

### Maze Rendering Challenge
The backend doesn't expose maze walls - it only validates moves. Options:
1. **Option A**: Hardcode the 9 maze variants in the TUI (they're static)
2. **Option B**: Show only player/goal positions, no walls (simpler but less visual)
3. **Option C**: Add maze wall data to proto response (requires backend change)

**Recommendation**: Option A - hardcode mazes. They're defined in the original game and don't change.

---

## Estimated Timeline

| Phase | Description | Effort |
|-------|-------------|--------|
| 1 | Foundation (SSH + gRPC client) | 1-2 days |
| 2 | Core TUI architecture | 2-3 days |
| 3 | Module implementations (11 modules) | 5-7 days |
| 4 | Game flow & polish | 2-3 days |
| 5 | Deployment & testing | 1-2 days |
| **Total** | | **11-17 days** |

---

## Questions Resolved

- **Manual not needed**: Defuser-only view
- **New service**: Separate Go binary, gRPC client to existing backend
- **No emojis**: Unicode/ASCII art only
- **SSH delivery**: Charmbracelet Wish with Bubbletea middleware

---

## Backend API Reference

### gRPC Service
- **Endpoint**: `localhost:50051`
- **Service**: `GameService`

### RPC Methods
1. `CreateGame` - Creates a new game session
2. `GetBombs` - Retrieves all bombs for a session
3. `SendInput` - Sends player input to a module

### Proto Files
Proto files are symlinked/copied from `keep-talking/proto/`:
- `game.proto` - Main service definition
- `player.proto` - Player input/output messages
- `session.proto` - Session messages
- `bomb.proto` - Bomb entity
- `modules.proto` - Module definitions
- `common.proto` - Common types (Color, Direction, etc.)
- `*_module.proto` - Module-specific types

### Module Types (pb.ModuleType)
- `CLOCK = 1`
- `WIRES = 2`
- `PASSWORD = 3`
- `BIG_BUTTON = 4`
- `SIMON = 5`
- `KEYPAD = 6`
- `WHOS_ON_FIRST = 7`
- `MEMORY = 8`
- `MORSE = 9`
- `NEEDY_VENT_GAS = 10`
- `NEEDY_KNOB = 11`
- `MAZE = 12`
