#!/usr/bin/env bash
# Claude Code Stop hook — surface any background processes the ended
# session is leaving behind, plus the exact command to kill them.
set -u
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" ]; then
  exec "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" hook stop
fi
for p in "$HOME/.local/bin/claude-processes" "/usr/local/bin/claude-processes" "/opt/homebrew/bin/claude-processes"; do
  if [ -x "$p" ]; then exec "$p" hook stop; fi
done
if command -v claude-processes >/dev/null 2>&1; then exec claude-processes hook stop; fi
exit 0
