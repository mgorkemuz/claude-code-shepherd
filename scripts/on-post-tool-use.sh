#!/usr/bin/env bash
# Claude Code PostToolUse hook (matcher: Bash) — capture persistent
# descendants of the Claude process after each Bash tool call.
#
# The wrapper doesn't exist yet when PreToolUse fires, so PostToolUse is
# the right moment to observe it — after spawn, before Claude tears down.
set -u
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" ]; then
  exec "${CLAUDE_PLUGIN_ROOT}/bin/claude-processes" hook post-tool-use
fi
for p in "$HOME/.local/bin/claude-processes" "/usr/local/bin/claude-processes" "/opt/homebrew/bin/claude-processes"; do
  if [ -x "$p" ]; then exec "$p" hook post-tool-use; fi
done
if command -v claude-processes >/dev/null 2>&1; then exec claude-processes hook post-tool-use; fi
exit 0
