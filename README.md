# Homebrew Tap for Pilot Protocol

The network stack for AI agents.

## Install

```bash
brew tap TeoSlayer/pilot
brew trust TeoSlayer/pilot
brew install pilotprotocol
```

`brew trust` is required: recent Homebrew refuses to load formulae from a
non-official tap until the tap is trusted, so without it `brew install`
fails even though the tap was added successfully.

Or, once the tap is trusted, in one command:

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
