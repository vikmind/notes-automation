DIR="$( cd "$( dirname "$0" )/../" && pwd )"
CURRENT_MONDAY=$(date -d'next monday - 7 days' +%Y-%m-%d_W%V)
CURRENT_FILE="$DIR/_Done_$CURRENT_MONDAY.md"
TODAY_FILTER="$(date +%y/%m/%d)"

TODAY_TASKS=$(todoist --csv cl -f today | rg -e '^\d.+#"?([^"]+)"?,"?([^"]+)"?$' -r '- [$1] $2\n' | tr -d '\n')

echo -e $TODAY_TASKS >> $CURRENT_FILE

numdaycheck="$(date +%u)"
TOMORROW=$(date -dtomorrow "+%A, %B %d")

if [ $numdaycheck != 7 ]; then
  echo "#### $TOMORROW" >> $CURRENT_FILE
fi

$EDITOR $CURRENT_FILE
