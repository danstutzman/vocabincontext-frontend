#!/bin/bash -ex
cd `dirname $0`

BROWSERIFY=node_modules/browserify/bin/cmd.js
WATCHIFY=node_modules/watchify/bin/cmd.js

mkdir -p build build/js build/css

ruby -e "
index = File.read('src/index.html')
index.gsub! '<script src=\'js/vendor.js\'></script>', %q{
  <script src='https://cdnjs.cloudflare.com/ajax/libs/react/0.14.7/react-with-addons.js'></script>
  <script src='https://cdnjs.cloudflare.com/ajax/libs/react/0.14.7/react-dom.js'></script>
  <script src='https://cdnjs.cloudflare.com/ajax/libs/bluebird/3.2.1/bluebird.js'></script>
  <script src='https://cdnjs.cloudflare.com/ajax/libs/redux/3.2.1/redux.js'></script>
  <script src='https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore.js'></script>}
File.open('build/index.html', 'w') do |file|
  file.write index
end
"

$WATCHIFY -t coffeeify src/coffee/app.coffee -d \
  -x react -x react-dom -x underscore -x bluebird -x react-addons-update -x redux \
  -v -o build/js/app.js
