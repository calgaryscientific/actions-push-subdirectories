#!/bin/bash

set -e

FOLDER=$1
TARGET_BRANCH=$2
TARGET_REPO=$3
GITHUB_USERNAME=github-actions
BASE=$(pwd)

git config --global user.email "github-actions-bot@github.com"
git config --global user.name "$GITHUB_USERNAME"

# clone, delete files in the clone, and copy (new) files over
# this handles file deletions, additions, and changes seamlessly
CLONE_DIR="__${FOLDER}__clone__"

git clone --depth 1 https://$API_TOKEN_GITHUB@github.com/$TARGET_REPO.git  $CLONE_DIR &> /dev/null
cd $CLONE_DIR
find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions in monorepo)
cp -r $BASE/$FOLDER/. .

# Commit if there is anything to
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit --message "Update $TARGET_REPO from $GITHUB_REPOSITORY"
  git push origin $TARGET_BRANCH
else
  echo "  No changes, skipping update"
fi
