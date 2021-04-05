#!/bin/sh

set -e

js=$1
min=$2
esbuild --minify --outfile=$min $js
