const fs = require('fs')
const assets = JSON.parse(fs.readFileSync('dist/assets.json', 'utf8'))

for (key in assets) {
  assets[key] = assets[key].replace('dist/', '')
}

var index = fs.readFileSync('src/index.html', 'utf8')

function replace(assetKey, needle, replacement) {
  if (!assets['dist/css/app.css']) {
    throw new Error('No dist/css/app.css in assets.json')
  }
  const index2 = index.replace(needle, replacement)
  if (index2 === index) {
    throw new Error(`No ${needle} in src/index.html`)
  }
  return index2
}

index = replace('dist/css/app.css',
    "<link rel='stylesheet' href='css/app.css'>",
    `<link rel='stylesheet' href='${assets['dist/css/app.css']}'>`)
index = replace('dist/js/vendor.js',
    "<script src='js/vendor.js'></script>",
    `<script src='${assets['dist/js/vendor.js']}'></script>`)
index = replace('dist/js/app.js',
    "<script src='js/app.js'>",
    `<script src='${assets['dist/js/app.js']}'></script>`)

fs.writeFileSync('dist/index.html', index)
