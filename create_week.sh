DIR="$( cd "$( dirname "$0" )/../" && pwd )"
cd $DIR

# 0. Preparations
numdaycheck="$(date +%u)"
sum=$((8-$numdaycheck))
NEXT_MONDAY_COMMAND="date -v+$(echo $sum)d"
NEXT_SUNDAY_COMMAND="date -v+$(echo $(($sum + 7)))d"

# 1. Move current week to YEAR folder
CURRENT_MONDAY_COMMAND="date -v-$(($(date +%u)-1))d"
CURRENT_YEAR="$($CURRENT_MONDAY_COMMAND +%Y)"
FROM_FILE="_Done_$($CURRENT_MONDAY_COMMAND +%Y-%m-%d_W%V).md"
TO_FILE="$($CURRENT_MONDAY_COMMAND +'%Y/Done_%Y-%m-%d_W%V').md"

# 1.1 Clean file
sed -i '' '/Meditate/d' $FROM_FILE
sed -i '' '/Exercise:/d' $FROM_FILE
sed -i '' '/Grooming/d' $FROM_FILE

# 1.2 Create YEAR folder
mkdir -p $($CURRENT_MONDAY_COMMAND +%Y)

# 1.3 Move
mv $FROM_FILE $TO_FILE

# 2. Append week header to YEAR/Done_YEAR.md
MONDAY_LINE=$(sed -n '/#### Monday/=' $TO_FILE)
echo "" >> $CURRENT_YEAR/Done_$CURRENT_YEAR.md
head -n $(($MONDAY_LINE - 2)) $TO_FILE >> $CURRENT_YEAR/Done_$CURRENT_YEAR.md

# 3. Create file for new week
NEXT_WEEK_NUMBER="$($NEXT_MONDAY_COMMAND +%V)"
NEXT_MONDAY_FORMATTED="$($NEXT_MONDAY_COMMAND +%d.%m)"
NEXT_SUNDAY_FORMATTED="$($NEXT_SUNDAY_COMMAND +%d.%m)"
NEW_FILE_NAME="_Done_$($NEXT_MONDAY_COMMAND +%Y-%m-%d_W%V).md"

# 3.1 Start creating header
touch $NEW_FILE_NAME
echo "### $($NEXT_MONDAY_COMMAND +%Y) week $NEXT_WEEK_NUMBER" >> $NEW_FILE_NAME
echo "#### $NEXT_MONDAY_FORMATTED - $NEXT_SUNDAY_FORMATTED" >> $NEW_FILE_NAME
echo "* * *" >> $NEW_FILE_NAME
echo "Project|Goal|Mon|Tue|Wed|Thu|Fri|Sat|Sun|All|Complete?" >> $NEW_FILE_NAME
echo "---|---|---|---|---|---|---|---|---|---|---" >> $NEW_FILE_NAME

# 3.2 Write weekly tasks to header and align them
COUNT=0
LONGEST_PROJECT=0
LONGEST_GOAL=0
while read line
do
  COUNT=$(($COUNT+1))
  DIV3=$(($COUNT % 3))
  if [ $DIV3 == 1 ]; then
    if [ "${#line}" -gt "$LONGEST_PROJECT" ]; then
      LONGEST_PROJECT=${#line}
    fi
    PROJECTS[${#PROJECTS[@]}]="$line"
  fi
  if [ $DIV3 == 2 ]; then
    if [ "${#line}" -gt "$LONGEST_GOAL" ]; then
      LONGEST_GOAL=${#line}
    fi
    GOALS[${#GOALS[@]}]="$line"
  fi
done < focus.txt

for (( i = 0 ; i < ${#PROJECTS[@]} ; i++ )) do
  PROJECT_SPACES_COUNT=$(($LONGEST_PROJECT-${#PROJECTS[$i]}+1))
  PROJECTS[$i]=${PROJECTS[$i]}$(seq -f " " -s '' $PROJECT_SPACES_COUNT)

  GOAL_SPACES_COUNT=$(($LONGEST_GOAL-${#GOALS[$i]}+1))
  GOALS[$i]=${GOALS[$i]}$(seq -f " " -s '' $GOAL_SPACES_COUNT)

  echo "${PROJECTS[$i]}| ${GOALS[$i]}|-|-|-|-|-|-|-|**0.0**|**N**" >> $NEW_FILE_NAME
done

echo "\n#### $($NEXT_MONDAY_COMMAND "+%A, %B %d")" >> $NEW_FILE_NAME
