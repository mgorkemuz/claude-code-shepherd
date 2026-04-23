#!/usr/bin/env bash
# units.sh — duration + size parsers used by cmd_cleanup / cmd_digest.

# cc_parse_duration <N[smhd]>
# Echo seconds. Bare number is seconds. Empty output on any error.
cc_parse_duration() {
  local s="$1"
  [ -z "$s" ] && return 0
  case "$s" in
    *[!0-9smhd]*|'') return 0 ;;
  esac
  local num unit
  num="${s%[smhd]}"
  if [ "$num" = "$s" ]; then unit="s"; else unit="${s#$num}"; fi
  case "$unit" in
    s) echo "$num" ;;
    m) echo "$((num * 60))" ;;
    h) echo "$((num * 3600))" ;;
    d) echo "$((num * 86400))" ;;
    *) return 0 ;;
  esac
}

# cc_parse_ram_size <N[KB|MB|GB]>
# Echo size in kilobytes (matches `ps -o rss=`). Empty on error.
cc_parse_ram_size() {
  local s="$1"
  [ -z "$s" ] && return 0
  local num; num=$(echo "$s" | grep -oE '^[0-9]+')
  [ -z "$num" ] && return 0
  local unit; unit=$(echo "$s" | sed "s/^$num//" | tr '[:lower:]' '[:upper:]')
  case "$unit" in
    ''|KB|K) echo "$num" ;;
    MB|M)    echo "$((num * 1024))" ;;
    GB|G)    echo "$((num * 1024 * 1024))" ;;
    *) return 0 ;;
  esac
}

# cc_etime_to_seconds "[DD-]HH:MM:SS" | "MM:SS" | "SS"
# Convert `ps etime` output to total seconds. Empty on error.
cc_etime_to_seconds() {
  local e="$1"
  [ -z "$e" ] && return 0
  local days=0 hours=0 mins=0 secs=0 rest="$e" colons
  case "$rest" in
    *-*) days=${rest%%-*}; rest=${rest#*-} ;;
  esac
  colons=$(awk -F: '{print NF-1}' <<< "$rest")
  case "$colons" in
    2) hours=${rest%%:*}; rest=${rest#*:}; mins=${rest%%:*}; secs=${rest#*:} ;;
    1) mins=${rest%%:*}; secs=${rest#*:} ;;
    0) secs=$rest ;;
    *) return 0 ;;
  esac
  days=$((10#${days:-0}))
  hours=$((10#${hours:-0}))
  mins=$((10#${mins:-0}))
  secs=$((10#${secs:-0}))
  echo $((days*86400 + hours*3600 + mins*60 + secs))
}
