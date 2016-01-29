#!/bin/bash -ex

mkdir -p build/images
cp src/images/*.png build/images

sass --update src/scss:build/css
