#!/usr/bin/env bash
set -euo pipefail

# Moves the Claude Code metadata of a project (handovers, sessions, memories)
# when the project folder is relocated on disk. Does NOT move the project
# folder itself; neither path needs to exist.
#
# Affected stores, keyed by the encoded absolute project path:
#   ~/.claude/handovers/<encoded>.md
#   ~/.claude/projects/<encoded>/
# Entries for subdirectories of the project (<encoded>-*) are moved too.

HANDOVERS_DIR="$HOME/.claude/handovers"
PROJECTS_DIR="$HOME/.claude/projects"

usage() {
  echo "Usage: $(basename "$0") [-y|--yes] <source-path> <dest-path>" >&2
  echo "  Moves Claude Code metadata (handovers, projects) from source to dest." >&2
  echo "  Paths may be relative or absolute, and need not exist on disk." >&2
  exit 1
}

ASSUME_YES=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=true ;;
    -h|--help) usage ;;
    *) ARGS+=("$arg") ;;
  esac
done
[ "${#ARGS[@]}" -eq 2 ] || usage

# Resolve to an absolute path by string manipulation only: the path may not
# exist (metadata can be moved before or after the actual folder).
abs_path() {
  local path="$1"
  case "$path" in
    /*) ;;
    *) path="$PWD/$path" ;;
  esac
  local -a parts=() out=()
  IFS='/' read -r -a parts <<< "$path"
  for part in "${parts[@]}"; do
    case "$part" in
      ''|'.') ;;
      '..') [ "${#out[@]}" -gt 0 ] && unset 'out[${#out[@]}-1]' ;;
      *) out+=("$part") ;;
    esac
  done
  local result=""
  for part in "${out[@]+"${out[@]}"}"; do
    result+="/$part"
  done
  echo "${result:-/}"
}

# Claude Code encodes an absolute path by replacing every non-alphanumeric
# character with '-'.
encode() {
  printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'
}

SRC="$(abs_path "${ARGS[0]}")"
DST="$(abs_path "${ARGS[1]}")"
if [ "$SRC" = "$DST" ]; then
  echo "Error: source and destination resolve to the same path: $SRC" >&2
  exit 1
fi

SRC_ENC="$(encode "$SRC")"
DST_ENC="$(encode "$DST")"

# Collect planned moves as "from|to" pairs. Matches are the exact encoded
# name or the encoded name followed by '-' (a subdirectory entry) — never a
# raw string prefix, so moving .../a cannot capture .../agentkit.
MOVES=()
collect() {
  local dir="$1" suffix="$2" entry name rest
  [ -d "$dir" ] || return 0
  for entry in "$dir/$SRC_ENC$suffix" "$dir/$SRC_ENC"-*"$suffix"; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    rest="${name#"$SRC_ENC"}"
    MOVES+=("$entry|$dir/$DST_ENC$rest")
  done
}
collect "$HANDOVERS_DIR" ".md"
collect "$PROJECTS_DIR" ""

if [ "${#MOVES[@]}" -eq 0 ]; then
  echo "No Claude metadata found for $SRC"
  exit 0
fi

COLLISIONS=()
for move in "${MOVES[@]}"; do
  to="${move#*|}"
  [ -e "$to" ] && COLLISIONS+=("$to")
done
if [ "${#COLLISIONS[@]}" -gt 0 ]; then
  echo "Error: destination already exists, nothing moved:" >&2
  printf '  %s\n' "${COLLISIONS[@]}" >&2
  exit 1
fi

echo "Moving Claude metadata: $SRC -> $DST"
for move in "${MOVES[@]}"; do
  echo "  ${move%%|*}"
  echo "    -> ${move#*|}"
done

if [ "$ASSUME_YES" = false ]; then
  read -r -p "Proceed? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Aborted, nothing moved."; exit 1 ;;
  esac
fi

for move in "${MOVES[@]}"; do
  mv "${move%%|*}" "${move#*|}"
done
echo "Done (${#MOVES[@]} moved)."
