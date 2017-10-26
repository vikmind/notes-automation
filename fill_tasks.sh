DIR="$( cd "$( dirname "$0" )/../" && pwd )"
cd $DIR/tasks

git pull

CURRENT_MONDAY_COMMAND="date -v-$(($(date +%u)-1))d"
CURRENT_FILE="../_Done_$($CURRENT_MONDAY_COMMAND +%Y-%m-%d_W%V).md"
TODAY_FILE="$(date +%d.%m.%Y).txt"

TOMORROW_COMMAND="date -v+1d"

cat $TODAY_FILE >> $CURRENT_FILE
echo "\n\n#### $($TOMORROW_COMMAND "+%A, %B %d")" >> $CURRENT_FILE
