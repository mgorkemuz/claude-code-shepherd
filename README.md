# claude-clean

Find and kill the dev servers, test watchers, and build processes that Claude Code leaves behind.

## The problem

Claude Code spawns background processes through its Bash tool — `npm run dev`, `next dev`, `vitest --watch`, build processes. When a session ends (`/clear`, terminal closed, Claude crashes), these children don't always die. On macOS they reparent to `launchd` (PID 1) and keep running: holding ports, eating RAM, accumulating. An orphaned `next dev` can grow past 8 GB.

Upstream: [#43944](https://github.com/anthropics/claude-code/issues/43944), [#29011](https://github.com/anthropics/claude-code/issues/29011), [#22978](https://github.com/anthropics/claude-code/issues/22978), [#36117](https://github.com/anthropics/claude-code/issues/36117), [#20369](https://github.com/anthropics/claude-code/issues/20369).

## Install

As a Claude Code plugin:

```
/plugin install claude-clean
```

Or from a local clone, for development:

```sh
claude --plugin-dir /path/to/claude-clean
```

Requires `jq`. macOS and Linux only.

### Upgrading from v0.1.0 (shell install)

v0.1.0 used a shell-mode `install.sh`. v0.2.0+ ships as a plugin. If you installed v0.1.0 previously:

```sh
./uninstall.sh          # removes the shell-mode binary, hook scripts, and settings.json entries
/plugin install claude-clean
```

## Use

```sh
claude-clean status                  # 2 sessions (1 active), 4 processes, 1 orphans
claude-clean list                    # grouped by session, with ports/RSS/uptime
claude-clean list --orphans          # only processes whose Claude is dead
claude-clean kill --session cc7b3a   # terminate everything one session spawned
claude-clean kill --orphans          # clean up all orphans
claude-clean kill 12403              # kill one tree by PID
```

When a Claude session ends, the **Stop** hook prints a summary of the still-running processes plus the exact `claude-clean kill --session …` command.

## How it works

Claude hooks provide the event stream:
- **SessionStart** records `session_id`, `cwd`, and the Claude PID in `~/.claude/.clean/<id>.json`.
- **PostToolUse** (matcher `Bash`) walks the descendants of the Claude PID after every Bash tool call and records any new persistent processes. Idempotent — repeated walks don't duplicate entries.
- **Stop** surfaces the still-alive tracked processes.

`claude-clean list` intersects the tracked PIDs with live `ps` output and walks each tracked PID's descendants, so it finds children the hook never saw directly (e.g. a `next-server` forked by `next dev`). Orphans are processes still alive for a session whose `claude_pid` is no longer running.

`kill` sends SIGTERM to the tree deepest-first, waits up to 3 seconds, then SIGKILLs any survivors.

A note on hooks: the spec called for `PreToolUse`, but the wrapper doesn't exist yet when `PreToolUse` fires. `PostToolUse` is the right moment. The Stop hook prints instead of prompting interactively, because Claude Code doesn't hand a TTY to hooks.

## Uninstall

Plugin users:

```
/plugin uninstall claude-clean
```

v0.1.0 shell-mode users (legacy):

```sh
./uninstall.sh
```

Either path clears tracking state at `~/.claude/.clean/` unless you pass `--keep-state`.

## Related

Complementary, not competing:
- [theQuert/cc-reaper](https://github.com/theQuert/cc-reaper) — cleans up Claude's own internal leaks (MCP servers, subagents). claude-clean cleans up the processes *you* told Claude to run in the background. Safe to run side-by-side.
- [Stargx/claude-code-dashboard](https://github.com/Stargx/claude-code-dashboard) — GUI session overview
- claude-sessions-monitor, claude-control — conversation-level views

## Testing

`./test/test-detect.sh` and `./test/test-tree.sh` exercise the detection and tree-walk libraries with synthetic processes.

## License

MIT
