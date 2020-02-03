#/bin/bash
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'
DIR="$(dirname $0)/.."
COUNT=0
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  ARGS='-e'
fi

echo $ARGS ""
echo $ARGS "${RED}FOCUS ON:${NC}"
echo $ARGS ""
while read line
do
  COUNT=$(($COUNT+1))
  DIV3=$(($COUNT % 3))
  if [ $DIV3 == 1 ]; then
    echo $ARGS "$GREEN$line$NC"
  else
    echo $ARGS "$line"
  fi
done < $DIR/focus.txt

echo ""
