#!/usr/bin/env bash
# Claude Code SessionStart hook — record session in tracking state.
# Plugin-bundled binary first, then fallbacks for shell-mode (v0.1.0) users.
# Errors never block Claude.
set -u
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" ]; then
  exec "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" hook session-start
fi
for p in "$HOME/.local/bin/claude-processes" "/usr/local/bin/claude-processes" "/opt/homebrew/bin/claude-processes"; do
  if [ -x "$p" ]; then exec "$p" hook session-start; fi
done
if command -v claude-processes >/dev/null 2>&1; then exec claude-processes hook session-start; fi
exit 0
