#!/bin/bash -ex
cd `dirname $0`
rm -rf build/images build/images-single
mkdir -p build/images build/images-single

convert ~/dev/iphone_mockup2/icons/thought/noun_14958_cc.png -crop 610x610+50+0 -resize 120x120 build/images-single/thought.png
convert ~/dev/iphone_mockup2/icons/speech/noun_42533_cc.png -crop 610x610+50+0 -resize 120x120 build/images-single/speech.png
convert ~/dev/iphone_mockup2/icons/arrow/noun_204591_cc.png -crop 610x610+50+0 -resize 120x120 build/images-single/right-arrow.png

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
