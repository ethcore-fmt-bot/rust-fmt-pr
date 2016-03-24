#!/bin/bash
set -e

if ! [ -x "$(command -v rustfmt)" ]; then
  echo 'Rustfmt doesnt seem to be installed. Please run ./install.sh first'
  exit 1
fi

COMMAND="cargo fmt"
TARGET_OWNER=""
TARKET_REPO=""
TARGET_BRANCH=master
WORK_DIR=/tmp/work
WORK_OWNER=""
WORK_REPO=""
WORK_KEY=""
LOG_FILE="./fmt-log"

. ./vars.sh

if [ "x$TARGET_OWNER" == "x" ]; then
  echo "Please provide TARGET_OWNER";
  exit 2
fi
if [ "x$TARGET_REPO" == "x" ]; then
  echo "Please provide TARGET_REPO";
  exit 3
fi
if [ "x$WORK_OWNER" == "x" ]; then
  echo "Please provide WORK_OWNER";
  exit 4
fi
if [ "x$WORK_REPO" == "x" ]; then
  echo "Please provide WORK_REPO";
  exit 5
fi
if [ "x$WORK_KEY" == "x" ]; then
  echo "Please provide WORK_KEY";
  exit 6
fi

# Clone repo
echo "Cloning repo"
rm -rf $WORK_DIR || true
git clone -b $TARGET_BRANCH --single-branch "git@github.com:$TARGET_OWNER/$TARGET_REPO.git" $WORK_DIR
cd $WORK_DIR
# Format code
echo "Formatting"
$COMMAND > $LOG_FILE
# Commit
echo "Committing work"
git commit -am "Formatting code using rustfmt v`rustfmt -V`"
# And push
echo "Pushing work to repo"
git remote add fmt "https://${WORK_OWNER}:${WORK_KEY}@github.com/$WORK_OWNER/${WORK_REPO}.git"
git push -u fmt $TARGET_BRANCH --force
# Prepare PR
echo "Preparing PR"
curl -i \
    -H "Content-Type: application/json" \
    -H "Authorization: token ${WORK_KEY}" \
    -X POST \
    -d "{\"title\": \"Formatting code.\", \"head\": \"$WORK_OWNER:$TARGET_BRANCH\", \"base\": \"$TARGET_BRANCH\", \"body\": \"\`\`\`\n$(sed -e ':a;N;$!ba;s/\n/\\n/g;s/"/_/g' $LOG_FILE)\n\`\`\`\"}" \
  "https://api.github.com/repos/$TARGET_OWNER/$TARGET_REPO/pulls"
  
# Cleanup
echo "Cleaning..."
rm $LOG_FILE
cd -
rm $WORK_DIR -rf
