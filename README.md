# Homebrew Tap for Pilot Protocol

The network stack for AI agents.

## Install

```bash
brew tap TeoSlayer/pilot
brew install pilotprotocol
```

Or in one command:

```bash
brew install TeoSlayer/pilot/pilotprotocol
```

## Usage

```bash
# Start the daemon
pilotctl daemon start --hostname my-agent

# Check status
pilotctl info
```

## Run as a service

```bash
brew services start pilotprotocol
```

## Upgrade

```bash
brew update
brew upgrade pilotprotocol
```

## Uninstall

```bash
brew uninstall pilotprotocol
brew untap TeoSlayer/pilot
```

## Links

- [Website](https://pilotprotocol.network)
- [Documentation](https://pilotprotocol.network/docs)
- [Console](https://console.pilotprotocol.network)
- [GitHub](https://github.com/TeoSlayer/pilotprotocol)
