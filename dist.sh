#!/bin/bash -ex
cd `dirname $0`

rm -rf dist/*
mkdir -p dist dist/js dist/css

#./images.sh
#cp build/css/sprity.css dist/css/sprity.css
#cp -R build/images dist/images

cat node_modules/react/dist/react.min.js > dist/js/vendor.js
cat node_modules/react-dom/dist/react-dom.min.js >> dist/js/vendor.js
cat node_modules/underscore/underscore-min.js >> dist/js/vendor.js
echo >> dist/js/vendor.js # needs a newline if anything follows

docker run --rm \
  --mount type=bind,source=$PWD,destination=/app \
  node:4.8.7-alpine sh -c \
   "set -ex
    cd /app
    npm install
    node_modules/.bin/browserify \
      -t coffeeify src/coffee/app.coffee -v \
      -x react -x react-dom -x underscore \
    | /app/node_modules/uglify-js/bin/uglifyjs --compress --mangle \
    > /app/dist/js/app.js
    
    cp -v src/css/app.css dist/css/app.css
    mkdir -p dist/images
    cp src/images/*.png dist/images

    rm -f dist/assets.json
    node_modules/hashmark/bin/hashmark dist/css/*.css \
      -r true -l 5 -m dist/assets.json 'dist/css/{name}.{hash}{ext}'
    node_modules/hashmark/bin/hashmark dist/js/*.js \
      -r true -l 5 -m dist/assets.json 'dist/js/{name}.{hash}{ext}'
    node dist-rewrite-index.js"
