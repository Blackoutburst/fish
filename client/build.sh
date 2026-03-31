#!/bin/bash
set -e

TRANSPILER="$HOME/.local/bin/unholyc"
NAME=Fish
SRC="out/src/*.cc"
INCLUDE="-Iout/include"

I_VK="/opt/homebrew/include"
L_VK="/opt/homebrew/lib"
VK="-isystem $I_VK -L$L_VK -lvulkan -Wl,-rpath,$L_VK"

I_GLFW="/opt/homebrew/include"
L_GLFW="/opt/homebrew/lib"
GLFW="-I$I_GLFW -L$L_GLFW -lglfw3"

I_UHC="$HOME/.local/include"
L_UHC="$HOME/.local/lib"
UHC="-I${I_UHC} -L${L_UHC} -luhc -luhcgraphics"

F_ERROR="-Wall -Wextra -Wpedantic"
F_DEBUG="-g3 -fno-omit-frame-pointer -fsanitize=address"
FRAMEWORKS="-framework Cocoa -framework IOKit"

F_DISABLED=""

$TRANSPILER -I"${I_UHC}" ./ out/

echo "CLANG:"
clang++ -o "$NAME" $SRC $INCLUDE $UHC $VK $GLFW $F_ERROR $FRAMEWORKS $F_DEBUG $F_DISABLED
CLANG_EXIT=$?

if [ $CLANG_EXIT -ne 0 ]; then
    echo "FAILED"
else
    echo "OK"
fi

slangc shader/terrain.slang -entry vertMain -stage vertex -target spirv -o shader/terrainVert.spv
slangc shader/terrain.slang -entry fragMain -stage fragment -target spirv -o shader/terrainFrag.spv

slangc shader/water.slang -entry vertMain -stage vertex -target spirv -o shader/waterVert.spv
slangc shader/water.slang -entry fragMain -stage fragment -target spirv -o shader/waterFrag.spv

rm -rf out
