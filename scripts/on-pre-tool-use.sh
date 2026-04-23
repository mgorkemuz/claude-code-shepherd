#!/usr/bin/env bash
# Claude Code PreToolUse hook (matcher: Bash) — warn Claude when the
# pending Bash command looks like it will bind a port already held by
# another tracked session. Advisory only; never blocks.
set -u
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" ]; then
  exec "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" hook pre-tool-use
fi
for p in "$HOME/.local/bin/claude-processes" "/usr/local/bin/claude-processes" "/opt/homebrew/bin/claude-processes"; do
  if [ -x "$p" ]; then exec "$p" hook pre-tool-use; fi
done
if command -v claude-processes >/dev/null 2>&1; then exec claude-processes hook pre-tool-use; fi
exit 0
