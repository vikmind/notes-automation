git pull
DIR="$( cd "$( dirname "$0" )/../" && pwd )"

CURRENT_MONDAY_COMMAND="date -v-$(($(date +%u)-1))d"
CURRENT_FILE="$DIR/_Done_$($CURRENT_MONDAY_COMMAND +%Y-%m-%d_W%V).md"
TODAY_FILTER="$(date +%y/%m/%d)"

TODAY_TASKS=$(todoist --csv cl | rg "$TODAY_FILTER" | rg -e '^\d.+#"?([^"]+)"?,"?([^"]+)"?$' -r '- [$1] $2\n' | tr -d '\n')

echo $TODAY_TASKS >> $CURRENT_FILE

numdaycheck="$(date +%u)"
TOMORROW_COMMAND="date -v+1d"

if [ $numdaycheck != 7 ]; then
  echo "#### $($TOMORROW_COMMAND "+%A, %B %d")" >> $CURRENT_FILE
fi

$EDITOR $CURRENT_FILE
