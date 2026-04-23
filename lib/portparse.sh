#!/usr/bin/env bash
# portparse.sh — extract ports a shell command is likely to bind.
# Used by awareness.sh port-conflict check; unit-tested in test-awareness.sh.

# cc_parse_ports_from_cmd <cmd>
# Emit ports (one per line) the command will probably listen on. Conservative —
# false positives are annoying, misses are fine (we warn, never block).
cc_parse_ports_from_cmd() {
  local cmd="$1"
  [ -z "$cmd" ] && return 0

  # Explicit --port N / -p N / --port=N / -p=N
  echo "$cmd" | grep -oE -- '(--port[ =]|--port=|[[:space:]]-p[ =]|^-p[ =]|-p=)[0-9]+' \
    | grep -oE '[0-9]+$'

  # python -m http.server [N] (default 8000)
  if echo "$cmd" | grep -qE 'python[0-9]*[[:space:]]+-m[[:space:]]+http\.server'; then
    local n
    n=$(echo "$cmd" | grep -oE 'http\.server[[:space:]]+[0-9]+' | grep -oE '[0-9]+$')
    echo "${n:-8000}"
  fi

  # Default ports for well-known dev servers that don't require an explicit flag.
  local nopflag=1
  echo "$cmd" | grep -qE -- '(--port|-p[ =]|-p$)' && nopflag=0

  if [ "$nopflag" -eq 1 ]; then
    if echo "$cmd" | grep -qE '(^|[^a-z])next[[:space:]]+(dev|start)';          then echo 3000; fi
    if echo "$cmd" | grep -qE '(^|[^a-z])vite([[:space:]]|$)';                  then echo 5173; fi
    if echo "$cmd" | grep -qE 'webpack-dev-server|webpack[[:space:]]+serve';    then echo 8080; fi
    if echo "$cmd" | grep -qE 'jekyll[[:space:]]+serve';                         then echo 4000; fi
    if echo "$cmd" | grep -qE 'astro[[:space:]]+dev';                            then echo 4321; fi
    if echo "$cmd" | grep -qE 'nuxt[[:space:]]+(dev|start)';                     then echo 3000; fi
  fi
}
