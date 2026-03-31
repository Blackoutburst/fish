#!/bin/bash
set -e

TRANSPILER="$HOME/.local/bin/unholyc"
NAME=FishServer
SRC="out/src/*.cc"
INCLUDE="-Iout/include"

I_UHC="$HOME/.local/include"
L_UHC="$HOME/.local/lib"
UHC="-I${I_UHC} -L${L_UHC} -luhc"

F_ERROR="-Wall -Wextra -Wpedantic"
F_DEBUG="-g3 -fno-omit-frame-pointer"

$TRANSPILER -I"${I_UHC}" ./ out/

echo "CLANG:"
clang++ -o "$NAME" $SRC $INCLUDE $UHC $F_ERROR $F_DEBUG
CLANG_EXIT=$?

if [ $CLANG_EXIT -ne 0 ]; then
    echo "FAILED"
else
    echo "OK"
fi

rm -rf out
