# Remote Machines

The goal is reliable access to remote machines — staying connected through network drops, keeping work alive across SSH sessions, and not losing context when a connection closes. SSH handles most connections; mosh handles unstable ones; tmux on the remote end means the session survives regardless.

## SSH

No host aliases are currently configured. For hosts you connect to regularly, add them to `~/.ssh/config` (once that's managed via chezmoi) or define shell aliases in `~/.config/zsh/local/`:

```bash
# in ~/.config/zsh/local/remote.zsh
alias myserver='ssh user@myserver.example.com'
```

> **Gap**: SSH config isn't yet managed by chezmoi. Adding `~/.ssh/config` would let you use tab-completion on hostnames and centralise connection options (KeepAlive, IdentityFile, etc.).

### Key management

SSH keys need to be loaded into the agent once per login so you're not prompted for the passphrase on every connection:

```bash
ssh-add ~/.ssh/id_ed25519     # load a key into the agent
ssh-add -l                     # list loaded keys
```

On macOS, Keychain integration keeps keys loaded across reboots — add `UseKeychain yes` and `AddKeysToAgent yes` to `~/.ssh/config`. Until SSH config is managed by chezmoi, set this up manually after each new machine bootstrap.

---

## Unstable connections

`mosh` is installed for SSH over flaky or high-latency connections — it stays connected through IP changes and network drops:

```bash
mosh user@host
```

`mosh` requires the server to have `mosh` installed too.

---

## Keeping work alive across connections

Start a tmux session on the remote machine before doing any work. Disconnecting doesn't kill it:

```bash
# On remote machine
to project          # attach or create "project" session
# work here — closing the SSH connection doesn't kill the session

# Reconnect later
ssh user@host
tmux attach -t project
```

See [Sessions & Multitasking](sessions.md) for the full tmux reference.

---

## Truecolor over SSH

tmux is configured with `default-terminal "tmux-256color"`. If colors look wrong on a remote box, it's usually because the `tmux-256color` terminfo isn't installed there:

```bash
# Check on the remote host
infocmp tmux-256color

# If missing, copy it from your local machine
infocmp -x tmux-256color | ssh user@host -- tic -x -
```
