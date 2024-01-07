#!/bin/sh

set -e

js="elm.js"
min="elm.min.js"

elm make --optimize --output=$js src/Main.elm

minify -o $min $js

echo "Compiled size:$(cat $js | wc -c) bytes  ($js)"
echo "Minified size:$(cat $min | wc -c) bytes  ($min)"
echo "Gzipped size: $(cat $min | gzip -c | wc -c) bytes"
