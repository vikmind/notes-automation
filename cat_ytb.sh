cd ../

CURRENT_YEAR="$(date +%Y)"
PROJECT=${1:-Default}
FILENAME="_${PROJECT}_YTB_$CURRENT_YEAR.txt"
PREV_LINE=$(sed -n '/\*\*/=' $FILENAME | sed -n 2p)

git pull
head -n $(($PREV_LINE-1)) $FILENAME
