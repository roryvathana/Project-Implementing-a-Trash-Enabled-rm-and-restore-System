#!/bin/bash

TRASH_DIR="/tmp/trash"
LOG_FILE="$TRASH_DIR/trash.log"

[ -f "$LOG_FILE" ] || { echo "Trash log not found."; exit 1; }

query="$1"
[ -z "$query" ] && { echo "Usage: restore filename"; exit 1; }

# Find most recent match in log
entry=$(grep "$query" "$LOG_FILE" | tail -n 1)

if [ -z "$entry" ]; then
  echo "No matching file found in trash."
  exit 1
fi

IFS=',' read -r original_path trash_path timestamp <<< "$entry"

# Handle destination path
dest_dir=$(dirname "$original_path")
[ -d "$dest_dir" ] || mkdir -p "$dest_dir"

# Restore, check for conflicts
if [ -e "$original_path" ]; then
  echo "Conflict: File already exists at $original_path"
  new_path="${original_path}_restored_$(date +%s)"
  mv "$trash_path" "$new_path"
  echo "Restored as $new_path"
else
  mv "$trash_path" "$original_path"
  echo "Restored to $original_path"
fi
