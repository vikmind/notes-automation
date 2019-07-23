#/bin/bash
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'
DIR="$(dirname $0)/.."

echo -e "\n${RED}FOCUS ON:${NC}\n"
COUNT=0
while read line
do
  COUNT=$(($COUNT+1))
  DIV3=$(($COUNT % 3))
  if [ $DIV3 == 1 ]; then
    echo -e "$GREEN$line$NC"
  else
    echo -e "$line"
  fi
done < $DIR/focus.txt

echo ""
