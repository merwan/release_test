#!/usr/bin/env bash
set -e

[ -z "$1" ] && echo "You must supply the VERSION to release" && exit 1

read -p "This will DELETE UNSTAGED/STAGED changes. Proceed? (yN) " -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "### Download new data from origin/master"
git fetch origin master

echo "### Checkout and reset master branch"
git checkout master
git reset --hard origin/master

echo "### Download new data from origin/production"
git fetch origin production

echo "### Checkout and reset production branch"
git checkout production
git reset --hard origin/production

echo "### Merge master to production"
git merge master production

echo "### Update VERSION to $1"
echo $1 > VERSION

VERSION=$(cat VERSION)

echo "### Commit and tag release"
git commit -am "Release v$VERSION"
git tag $VERSION

echo "### Push to remote"
git push && git push --tags

echo "### Merge back to master"
git checkout master
git merge production master

echo "### Set development version"
VERSION="$VERSION-dev"
echo "$VERSION" > VERSION
git commit -am "Set development version to $VERSION"
git push

echo "########## SUCCESS! ##########"
