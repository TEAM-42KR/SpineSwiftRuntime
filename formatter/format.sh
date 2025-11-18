#!/usr/bin/env sh
set -e
BASEDIR=$(dirname "$0")



find $BASEDIR/.. -iname '*.h' -o -iname '*.cpp' -o -iname '*.hpp' -o -iname '*.c' -o -iname '*.m' -o -iname '*.mm' | clang-format --style=file:"$BASEDIR/clang-format.txt" -i --files=/dev/stdin


swift-format --in-place --configuration $BASEDIR/swift-format.txt $BASEDIR/.. --recursive 
