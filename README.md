# Keep Talking TUI

A Terminal User Interface (TUI) recreation of "Keep Talking and Nobody Explodes" served over SSH.

## Overview

This project provides a text-based interface for playing KTANE, connectable via SSH. It connects to the existing Go gRPC backend (`keep-talking/`) for game logic.

## Quick Start

### Prerequisites

- Go 1.21+
- The gRPC backend server running (`keep-talking/cmd/server`)

### Building

```bash
make build
```

This creates the `tui-server` binary.

### Running

```bash
# Set the gRPC server address if not localhost:50051
export TUI_GRPC_ADDR=localhost:50051

# Run the server (default SSH port: 2222)
./tui-server
```

Or use the Makefile:
```bash
TUI_GRPC_ADDR=localhost:50051 make run
```

### Connecting

```bash
ssh -p 2222 localhost
# Or from another machine:
ssh -p 2222 <server-ip>
```

On first run, SSH host keys will be generated in `.ssh/`.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TUI_SSH_PORT` | `2222` | SSH listen port |
| `TUI_GRPC_ADDR` | `localhost:50051` | gRPC backend address |

## Project Structure

```
keep-talking-tui/
├── cmd/server/         # SSH server entry point
├── internal/
│   ├── client/         # gRPC client wrapper
│   ├── tui/            # Bubbletea application
│   └── styles/         # Lipgloss styling
├── proto/              # Protobuf definitions
├── Makefile
└── README.md
```

## Architecture

- **SSH Server**: Charmbracelet Wish
- **TUI Framework**: Bubbletea
- **Styling**: Lipgloss
- **Backend**: Existing Go gRPC server

## License

MIT
