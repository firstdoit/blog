#!/bin/sh
git checkout gh-pages
git merge master
wintersmith build
git commit -am "New build for deployment"
git push origin gh-pages
git checkout master