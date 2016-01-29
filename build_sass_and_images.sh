#!/bin/bash -ex

mkdir -p build/images
cp -v src/images/*.png build/images

sass --update src/scss:build/css
