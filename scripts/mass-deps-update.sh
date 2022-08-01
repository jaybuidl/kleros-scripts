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
    sed -i "" 's/0d41f2b054031b35c03e437462b69650c3ad48b13f0b9e0f3ae9871bb5dddbd757819db8447cdce6e1f08bd44d572b15d383a876a2c5ad994ebb00ca17a89104/872685026db07ad1687056a78388f17c6a9bcd22bbf9d99d1e2b21e2d196c6e99a128bcff48063b3f0cf692a4365142fae9dd06cf8c532bc557a45f8ac853308/' yarn.lock

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

