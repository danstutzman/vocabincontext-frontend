#!/bin/bash -ex
cd `dirname $0`

BROWSERIFY=node_modules/browserify/bin/cmd.js
WATCHIFY=node_modules/watchify/bin/cmd.js

rm -rf dist/*
mkdir -p dist dist/js

cat node_modules/react/dist/react.min.js > dist/js/vendor.js
cat node_modules/react-dom/dist/react-dom.min.js >> dist/js/vendor.js
cat >>dist/js/vendor.js <<EOF
  function require(name) {
    if (name === 'react') { return window.React; }
    else if (name === 'react-dom') { return window.ReactDOM; }
    else { throw new Error("Unknown library '" + name + "'"); }
  }
EOF
#NODE_ENV=production $BROWSERIFY -r underscore -v \
#  | node_modules/uglify-js/bin/uglifyjs --compress --mangle \
#  >> dist/js/vendor.js

$BROWSERIFY -t coffeeify src/coffee/app.coffee -v \
  -x react -x react-dom -x underscore \
  | node_modules/uglify-js/bin/uglifyjs --compress --mangle \
  > dist/js/app.js

rm -f dist/assets.json
node_modules/hashmark/bin/hashmark dist/js/*.js -r true -l 5 -m dist/assets.json 'dist/js/{name}.{hash}{ext}'

ruby -e "
require 'json'
assets = JSON.load(File.read('dist/assets.json'))
assets.each do |key, value|
  value.gsub! 'dist/', ''
end
index = File.read('src/index.html')
index.gsub! '<script src=\'js/vendor.js\'></script>',
  \"<script src='#{assets.fetch('dist/js/vendor.js')}'></script>\"
index.gsub! '<script src=\'js/app.js\'></script>',
  \"<script src='#{assets.fetch('dist/js/app.js')}'></script>\"
File.open('dist/index.html', 'w') do |f|
  f.write index
end
"
