#!/bin/bash -ex
cd `dirname $0`

BROWSERIFY=node_modules/browserify/bin/cmd.js
WATCHIFY=node_modules/watchify/bin/cmd.js

rm -rf dist/*
mkdir -p dist dist/js dist/css

#./images.sh
#cp build/css/sprity.css dist/css/sprity.css
#cp -R build/images dist/images

if [ ! -e build/piwik.js ]; then
  curl https://raw.githubusercontent.com/piwik/piwik/b88b165f066fe462f06b4960202a4c126d149dae/piwik.js > build/piwik.js
fi

echo "var _paq = _paq || []; _paq.push(['setDomains', ['digitalocean.vocabincontext.com', 'vocabincontext.com']]); _paq.push(['trackPageView']); _paq.push(['enableLinkTracking']); var u='//192.81.213.170/piwik/'; _paq.push(['setTrackerUrl', u+'piwik.php']); _paq.push(['setSiteId', 1]);" > dist/js/vendor.js
cat build/piwik.js >> dist/js/vendor.js
tee -a dist/js/vendor.js <<EOF
window.onerror = function () {
  var errors = Array.prototype.slice.apply(arguments);
  var error_message = errors[0];
  var error_url = errors[1];
  var error_line = errors[2];
  var error_column = errors[3] + 1;
  var line_string = isNaN(error_line) ? "" : " (line: " + error_line + "";
  var column_string = isNaN(error_column) ? "" : ", column: " + error_column + ")";
  var error_event = "[" + error_message + "][" + error_url + line_string + column_string + "]";
  _paq.push(['trackEvent', 'Exceptions', 'JS errors', error_event]);
}
EOF
cat node_modules/react/dist/react.min.js >> dist/js/vendor.js
cat node_modules/react-dom/dist/react-dom.min.js >> dist/js/vendor.js
cat node_modules/underscore/underscore-min.js >> dist/js/vendor.js
echo >> dist/js/vendor.js # needs a newline if anything follows

$BROWSERIFY -t coffeeify src/coffee/app.coffee -v \
  -x react -x react-dom -x underscore \
  | node_modules/uglify-js/bin/uglifyjs --compress --mangle \
  > dist/js/app.js

sass --sourcemap=none --update src/scss:dist/css --style compressed

mkdir -p dist/images
cp src/images/*.png dist/images

rm -f dist/assets.json
node_modules/hashmark/bin/hashmark dist/css/*.css -r true -l 5 -m dist/assets.json 'dist/css/{name}.{hash}{ext}'
node_modules/hashmark/bin/hashmark dist/js/*.js -r true -l 5 -m dist/assets.json 'dist/js/{name}.{hash}{ext}'

ruby -e "
require 'json'
assets = JSON.load(File.read('dist/assets.json'))
assets.each do |key, value|
  value.gsub! 'dist/', ''
end
index = File.read('src/index.html')
index.gsub! '<link rel=\'stylesheet\' href=\'css/app.css\'>',
  \"<link rel='stylesheet' href='#{assets.fetch('dist/css/app.css')}'>\"
#index.gsub! '<link rel=\'stylesheet\' href=\'css/sprity.css\'>',
#  \"<link rel='stylesheet' href='#{assets.fetch('dist/css/sprity.css')}'>\"
index.gsub! '<script src=\'js/vendor.js\'></script>',
  \"<script src='#{assets.fetch('dist/js/vendor.js')}'></script>\"
index.gsub! '<script src=\'js/app.js\'></script>',
  \"<script src='#{assets.fetch('dist/js/app.js')}'></script>\"
File.open('dist/index.html', 'w') do |f|
  f.write index
end
"

rm -rf ~/dev/vocabincontext/public/*
cp -R dist/* ~/dev/vocabincontext/public
