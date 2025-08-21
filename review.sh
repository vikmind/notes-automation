#!/usr/bin/env bash
set -euo pipefail

# Requires: curl, jq
command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

# Go to repo root (parent of this script)
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

# Pull latest
git pull

# Compute current Monday (ISO week) and week number (BSD macOS vs GNU date)
if date -v +0d >/dev/null 2>&1; then
  dow="$(date +%u)"                  # 1=Mon..7=Sun
  offset=$((dow-1))
  monday="$(date -v -"${offset}"d +%Y-%m-%d)"
  week="$(date -j -f "%Y-%m-%d" "$monday" +%V)"
else
  dow="$(date +%u)"
  monday="$(date -d "today -$((dow-1)) days" +%F)"
  week="$(date -d "$monday" +%V)"
fi

current_filename="_Done_${monday}_W${week}.md"
since="$(date +"%Y-%m-%dT00:00:00")"
header="$(date "+%A, %B %d")"

# Read Todoist token
config="$HOME/.todoist.config.json"
if [[ ! -f "$config" ]]; then
  echo "Config not found: $config" >&2
  exit 1
fi
token="$(jq -r '.token' "$config")"
if [[ -z "$token" || "$token" == "null" ]]; then
  echo "Token not found in $config" >&2
  exit 1
fi

# Fetch completed items since local midnight
response="$(curl -sS --get \
  -H "Authorization: Bearer $token" \
  --data-urlencode "since=$since" \
  "https://api.todoist.com/sync/v9/completed/get_all")"

# Append markdown
{
  printf "\n#### %s\n" "$header"
  echo "$response" | jq -r '
    def to_project_map:
      if (.projects | type == "object") then .projects
      else reduce (.projects // [])[] as $p ({}; .[$p.id|tostring] = $p)
      end;
    to_project_map as $projects
    | (.items // [])[]
    | "- [\($projects[.project_id|tostring].name)] \(.content)"
  '
} >> "$current_filename"

# Open in editor (fallback to vi)
"${EDITOR:-vi}" "$current_filename"
