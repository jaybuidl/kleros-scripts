#!/bin/bash

# Dependabot does not update the lockfile automatically.
# This script helps applying the patch and updating the lockfile for all the currently open dependabot PRs.

git checkout -B chore/patches
git push --set-upstream origin chore/patches

for pr in $(gh pr list -s open -l dependencies --json number --jq .[].number)
do 
    gh pr edit $pr -B chore/patches 
    gh pr merge --rebase $pr
done

echo "If there is any conflict, resolve and merge to chore/patches manually (without --rebase)..."
echo 
read -p "Are all the conflicts resolved? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git pull
    YARN_CHECKSUM_BEHAVIOR=update yarn install --no-immutable

    # gluegun mismatch workaround
    sed -i "" 's/872685026db07ad1687056a78388f17c6a9bcd22bbf9d99d1e2b21e2d196c6e99a128bcff48063b3f0cf692a4365142fae9dd06cf8c532bc557a45f8ac853308/7a45a5a606a1e651c891467a693552b5237f8e90410f9c9daad4621ff0693d1c92b69aa35fc30eccf7c3b92ee724f15fc297e054086cfb312717ef01f48d2290/' yarn.lock

    git add -u
    git status
    git commit -m "chore: lockfile update"
    git push
fi

echo "If everything looks fine: 
git checkout master
git pull
git rebase origin/chore/patches
git push
"

