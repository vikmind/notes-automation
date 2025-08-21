#!/usr/bin/env bash
set -euo pipefail

# Go to repo root (parent of this script)
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

# Compute current Monday and ISO week/year (BSD macOS vs GNU date)
if date -v +0d >/dev/null 2>&1; then
  dow="$(date +%u)"                                  # 1=Mon..7=Sun
  monday="$(date -v -"${dow-1}"d +%Y-%m-%d)"
  week="$(date -j -f "%Y-%m-%d" "$monday" +%V)"
  year="$(date -j -f "%Y-%m-%d" "$monday" +%Y)"
  monday_header="$(date -j -f "%Y-%m-%d" "$monday" +"#### %A, %B %d")"
else
  dow="$(date +%u)"
  monday="$(date -d "today -$((dow-1)) days" +%F)"
  week="$(date -d "$monday" +%V)"
  year="$(date -d "$monday" +%Y)"
  monday_header="$(date -d "$monday" +"#### %A, %B %d")"
fi

current_filename="_Done_${monday}_W${week}.md"
year_dir="$year"
mkdir -p "$year_dir"
new_filename="$year_dir/Done_${monday}_W${week}.md"

# Ensure current file exists
if [[ ! -f "$current_filename" ]]; then
  echo "Not found: $current_filename" >&2
  exit 1
fi

# Filter out lines containing [Chores] and write archive file
awk '!/\[Chores\]/' "$current_filename" > "$new_filename"
rm -f "$current_filename"
echo "${current_filename} is filtered and moved to ${new_filename}"

# Append current week headers (before the Monday header) to year report
year_filename="$year_dir/Done_${year}.md"
header_line_num="$(grep -n -m1 -x "$monday_header" "$new_filename" | cut -d: -f1 || true)"
if [[ -z "${header_line_num:-}" ]]; then
  echo "Header '$monday_header' not found in $new_filename" >&2
  exit 1
fi

# Python sliced 0:idx-1 → up to two lines before the header (if present)
count_to_write=$((header_line_num - 2))
{
  printf "\n"
  if (( count_to_write > 0 )); then
    head -n "$count_to_write" "$new_filename"
  fi
  printf "\n"
} >> "$year_filename"

echo "${year_filename} is updated with new week"
