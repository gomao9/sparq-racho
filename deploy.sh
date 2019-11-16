#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build

# navigate into the build output directory
cd dist

echo 'idols.gomao.org' > CNAME

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:gomao9/sparq-racho.git master:gh-pages

cd -
