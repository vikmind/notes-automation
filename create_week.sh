#!/usr/bin/env bash
set -euo pipefail

# Go to repo root (parent of this script)
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

# Helpers for BSD (macOS) vs GNU date
if date -v +0d >/dev/null 2>&1; then
  # BSD date
  dow="$(date +%u)"                                 # 1=Mon..7=Sun
  days_to_next_monday=$((8 - dow))                  # Mon→7, Tue→6, ..., Sun→1
  days_to_next_sunday=$((14 - dow))                 # Mon→13, ..., Sun→7
  next_monday="$(date -v +"${days_to_next_monday}"d +%Y-%m-%d)"
  next_sunday="$(date -v +"${days_to_next_sunday}"d +%Y-%m-%d)"
  week="$(date -j -f "%Y-%m-%d" "$next_monday" +%V)"
  year="$(date -j -f "%Y-%m-%d" "$next_monday" +%Y)"
  next_monday_ddmm="$(date -j -f "%Y-%m-%d" "$next_monday" +%d.%m)"
  next_sunday_ddmm="$(date -j -f "%Y-%m-%d" "$next_sunday" +%d.%m)"
else
  # GNU date
  dow="$(date +%u)"
  days_to_next_monday=$((8 - dow))
  days_to_next_sunday=$((14 - dow))
  next_monday="$(date -d "today +${days_to_next_monday} days" +%F)"
  next_sunday="$(date -d "today +${days_to_next_sunday} days" +%F)"
  week="$(date -d "$next_monday" +%V)"
  year="$(date -d "$next_monday" +%Y)"
  next_monday_ddmm="$(date -d "$next_monday" +%d.%m)"
  next_sunday_ddmm="$(date -d "$next_sunday" +%d.%m)"
fi

new_file_name="_Done_${next_monday}_W${week}.md"

# Write header
{
  printf "### %s week %s\n" "$year" "$week"
  printf "#### %s - %s\n" "$next_monday_ddmm" "$next_sunday_ddmm"
  printf "* * *\n"
  printf "Project|Goal|Mon|Tue|Wed|Thu|Fri|Sat|Sun|All|Complete?\n"
  printf "---|---|---|---|---|---|---|---|---|---|---\n"
} > "$new_file_name"

# Read focus.txt
if [[ ! -f focus.txt ]]; then
  echo "focus.txt not found in $repo_root" >&2
  exit 1
fi
mapfile -t focus_lines < focus.txt

# Collect projects and goals (lines 1 and 2 of each group of 3)
declare -a projects=()
declare -a goals=()
longest_project=0
longest_goal=0

count=0
for line in "${focus_lines[@]}"; do
  ((count++))
  mod=$((count % 3))
  if [[ $mod -eq 1 ]]; then
    projects+=( "$line" )
    (( ${#line} > longest_project )) && longest_project=${#line}
  elif [[ $mod -eq 2 ]]; then
    goals+=( "$line" )
    (( ${#line} > longest_goal )) && longest_goal=${#line}
  fi
done

# Write rows with padded columns
rows_count="${#projects[@]}"
for ((i=0; i<rows_count; i++)); do
  project="${projects[i]}"
  goal="${goals[i]:-}"

  project_pad_len=$((longest_project - ${#project}))
  goal_pad_len=$((longest_goal - ${#goal}))

  project_pad="$(printf "%*s" "$project_pad_len" "")"
  goal_pad="$(printf "%*s" "$goal_pad_len" "")"

  printf "%s%s | %s%s |-|-|-|-|-|-|-|**0.0**|**N**\n" \
    "$project" "$project_pad" "$goal" "$goal_pad" >> "$new_file_name"
done

echo "File $new_file_name created"
