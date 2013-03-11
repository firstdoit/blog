#!/bin/sh
git checkout gh-pages
git merge master
wintersmith build
cp -Rfp build/* ./
rm -rf build
git add --all .
git commit -am "New build for deployment"
git push origin gh-pages
git checkout master
