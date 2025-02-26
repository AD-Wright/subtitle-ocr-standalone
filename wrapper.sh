#!/bin/bash

# Set up the environment
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="$HERE/usr/lib/mkvtoolnix:$PATH"
export PATH="$HERE/usr/lib/tesseract:$PATH"
export PATH="$HERE/usr/lib/subtile-ocr:$PATH"
export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
export TESSDATA_PREFIX="$HERE/usr/share/tessdata"

# Launch the actual script
"$HERE/usr/bin/mkv-subtitle-converter" "$@"
