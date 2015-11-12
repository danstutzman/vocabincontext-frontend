#!/bin/bash -ex
cd `dirname $0`
rm -rf build/images build/images-single
mkdir -p build/images build/images-single
convert ~/dev/iphone_mockup2/icons/finger/noun_12250_cc.png -crop 610x610+50+0 -resize 120x120 build/images-single/hand.png
convert ~/dev/iphone_mockup2/icons/pencil/noun_347_cc.png -crop 610x610+50+0 -resize 120x120 build/images-single/pencil.png
node_modules/sprity-cli/index.js create \
  --dimension 1:72 --dimension 2:192 \
  --prefix sprity -n sprity -s ../../build/css/sprity.css \
  build/images build/images-single/*.png
node_modules/hashmark/bin/hashmark build/images/*.png -r true -l 5 -m \
  build/images/assets.json 'build/images/{name}.{hash}{ext}'
ruby -e "
require 'json'
assets = JSON.load(File.read('build/images/assets.json'))
assets.each do |key, value|
  value.gsub! 'build/', ''
end
css = File.read('build/css/sprity.css')
css.gsub! 'background-image: url(../images/sprity.png);',
  \"background-image: url(../#{assets.fetch('build/images/sprity.png')});\"
css.gsub! 'background-image: url(../images/sprity@2x.png);',
  \"background-image: url(../#{assets.fetch('build/images/sprity@2x.png')});\"
File.open('build/css/sprity.css', 'w') { |f| f.write css }
"
rm build/images/assets.json
rm -rf build/images-single
