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

# Fetch completed items since local midnight until now
response="$(curl -sS --get \
  -H "Authorization: Bearer $token" \
  --data-urlencode "since=$since" \
  --data-urlencode "until=$(date +"%Y-%m-%dT23:59:59")" \
  "https://api.todoist.com/api/v1/tasks/completed/by_completion_date")"

# Fetch projects
projects_array="$(
  curl -sS \
    -H "Authorization: Bearer $token" \
    "https://api.todoist.com/api/v1/projects" \
  | jq '.results'
)"

tasks_json="$(echo "$response" | jq --argjson projects "$projects_array" '
  .items
  | map(
      . as $t
      | ($projects[] | select(.id == $t.project_id)) as $p
      | {
          task_id:      $t.task_id,
          content:      $t.content,
          completed_at: $t.completed_at,
          project_id:   $t.project_id,
          project_name: $p.name
        }
    )
')"

# Append markdown
{
  printf "\n#### %s\n" "$header"
  echo "$tasks_json" | jq -r '.[] | "- [\(.project_name)] \(.content)"'
} >> "$current_filename"


# Open in editor (fallback to vi)
"${EDITOR:-vi}" "$current_filename"
