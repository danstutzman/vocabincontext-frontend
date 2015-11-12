#!/bin/bash -ex
cd `dirname $0`

BROWSERIFY=node_modules/browserify/bin/cmd.js
WATCHIFY=node_modules/watchify/bin/cmd.js

mkdir -p build
mkdir -p build/js

ln -sf ../src/index.html build/index.html

cp node_modules/react/dist/react.js build/js/vendor.js
cat node_modules/react-dom/dist/react-dom.js >> build/js/vendor.js
cat >>build/js/vendor.js <<EOF
  function require(name) {
    if (name === 'react') { return window.React; }
    else if (name === 'react-dom') { return window.ReactDOM; }
    else { throw new Error("Unknown library '" + name + "'"); }
  }
EOF
#$BROWSERIFY -r underscore -d -v >> build/js/vendor.js

$WATCHIFY -t coffeeify src/js/app.coffee -d \
  -x react -x react-dom -x underscore \
  -v -o build/js/app.js
