DIR="$( cd "$( dirname "$0" )/../" && pwd )"
cd $DIR

# 1. Move current week to YEAR folder
CURRENT_MONDAY_COMMAND="date -v-$(($(date +%u)-1))d"
CURRENT_YEAR="$($CURRENT_MONDAY_COMMAND +%Y)"
FROM_FILE="_Done_$($CURRENT_MONDAY_COMMAND +%Y-%m-%d_W%V).md"
TO_FILE="$($CURRENT_MONDAY_COMMAND +'%Y/Done_%Y-%m-%d_W%V').md"

# 1.1 Clean file: remove tasks from "Chores" project
sed -i '' '/Chores/d' $FROM_FILE

# 1.2 Create YEAR folder
mkdir -p $($CURRENT_MONDAY_COMMAND +%Y)

# 1.3 Move
mv $FROM_FILE $TO_FILE

# 2. Append week header to YEAR/Done_YEAR.md
MONDAY_LINE=$(sed -n '/#### Monday/=' $TO_FILE)
echo "" >> $CURRENT_YEAR/Done_$CURRENT_YEAR.md
head -n $(($MONDAY_LINE - 2)) $TO_FILE >> $CURRENT_YEAR/Done_$CURRENT_YEAR.md
