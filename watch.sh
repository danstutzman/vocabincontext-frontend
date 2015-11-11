#!/bin/bash -ex
cd `dirname $0`

BROWSERIFY=node_modules/browserify/bin/cmd.js
WATCHIFY=node_modules/watchify/bin/cmd.js

mkdir -p build
mkdir -p build/js
ln -sf ../src/index.html build/index.html
$BROWSERIFY -r react -r react-dom -d -v -o build/js/vendor.js
$WATCHIFY -t coffeeify src/js/app.coffee -d -x react -x react-dom -v -o build/js/app.js
