#!/usr/bin/env bash
# Claude Code PostToolUse hook (matcher: Bash) — capture persistent
# descendants of the Claude process after each Bash tool call.
#
# The wrapper doesn't exist yet when PreToolUse fires, so PostToolUse is
# the right moment to observe it — after spawn, before Claude tears down.
set -u
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/bin/claude-clean" ]; then
  exec "${CLAUDE_PLUGIN_ROOT}/bin/claude-clean" hook post-tool-use
fi
for p in "$HOME/.local/bin/claude-clean" "/usr/local/bin/claude-clean" "/opt/homebrew/bin/claude-clean"; do
  if [ -x "$p" ]; then exec "$p" hook post-tool-use; fi
done
if command -v claude-clean >/dev/null 2>&1; then exec claude-clean hook post-tool-use; fi
exit 0
