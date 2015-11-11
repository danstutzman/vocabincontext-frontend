#!/bin/bash -ex
cd `dirname $0`

mkdir -p dist
rm -f dist/assets.json
node_modules/hashmark/bin/hashmark build/js/*.js -l 5 -m dist/assets.json 'dist/js/{name}.{hash}{ext}'

ruby -e "
require 'json'
assets = JSON.load(File.read('dist/assets.json'))
assets.each do |key, value|
  value.gsub! /^dist\//, ''
end
index = File.read('src/index.html')
index.gsub! '<script src=\'js/vendor.js\'></script>',
  \"<script src='#{assets['build/js/vendor.js']}'></script>\"
index.gsub! '<script src=\'js/app.js\'></script>',
  \"<script src='#{assets['build/js/app.js']}'></script>\"
File.open('dist/index.html', 'w') do |f|
  f.write index
end
"
