#!/bin/bash

TRASH_DIR="/tmp/trash"
LOG_FILE="$TRASH_DIR/trash.log"
TIMESTAMP=$(date +%Y%m%dT%H%M%S)

# Check if trash directory exists
[ -d "$TRASH_DIR" ] || mkdir -p "$TRASH_DIR"
touch "$LOG_FILE"

# Usage message
usage() {
  echo "Usage: rm [-r] file1 [file2 ...]"
  exit 1
}

# Parse options
recursive=false
files=()

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -r) recursive=true ;;
    -*) echo "Unsupported option: $1"; usage ;;
    *) files+=("$1") ;;
  esac
  shift
done

# Ensure at least one file
[ "${#files[@]}" -eq 0 ] && usage

for target in "${files[@]}"; do
  if [ ! -e "$target" ]; then
    echo "Error: $target does not exist"
    continue
  fi

  if [ -d "$target" ] && [ "$recursive" != true ]; then
    echo "Error: '$target' is a directory. Use -r to delete."
    continue
  fi

  filename=$(basename "$target")
  trash_path="$TRASH_DIR/${filename}_$TIMESTAMP"

  mv "$target" "$trash_path"
  echo "$target,$trash_path,$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
done
