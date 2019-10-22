TODAY_FILTER="$(date +%y/%m/%d)"
todoist --csv cl | rg "$TODAY_FILTER" | rg -e '^\d.+#"?([^"]+)"?,"?([^"]+)"?$' -r '- [$1] $2'
