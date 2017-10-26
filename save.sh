DIR="$( cd "$( dirname "$0" )/../" && pwd )"
cd $DIR

git add .
git commit --message "Review $(date "+%d.%m.%Y")"
git push
