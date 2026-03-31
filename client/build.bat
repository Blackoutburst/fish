@echo off
set NAME=Fish
set SRC=out/src/*.cc
set INCLUDE=-Iout\include

set I_GLFW=C:\GLFW\include
set L_GLFW=C:\GLFW\lib-mingw-w64
set GLFW=-I"%I_GLFW%" -L"%L_GLFW%" -lglfw3dll

set I_VK=C:\VulkanSDK\1.4.341.1\Include
set L_VK=C:\VulkanSDK\1.4.341.1\Lib
set VK=-I"%I_VK%" -L"%L_VK%" -lvulkan-1

set I_GLFW=C:\GLFW\include
set L_GLFW=C:\GLFW\lib-mingw-w64
set GLFW=-I"%I_GLFW%" -L"%L_GLFW%" -lglfw3dll

set I_UHC="%USERPROFILE%\.local\include"
set L_UHC="%USERPROFILE%\.local\lib"
set UHC=-I"%I_UHC%" -L"%L_UHC%" -luhc -luhcgraphics

set F_ERROR=-Wall -Wextra -Wpedantic
set F_DEBUG=-g3 -fno-omit-frame-pointer -fsanitize=address -fsanitize-address-use-after-return=always
set F_DISABLED=

unholyc -I%I_UHC% ./ out/

echo CLANG:
clang++ -o %NAME% %SRC% %INCLUDE% %UHC% %VK% %GLFW% %F_ERROR% %F_DEBUG% %F_DISABLED% -lws2_32
set CLANG_EXIT=%ERRORLEVEL%

if %CLANG_EXIT% neq 0 (
    echo FAILED
) else (
    echo OK
)

slangc shader/terrain.slang -entry vertMain -stage vertex -target spirv -o shader/terrainVert.spv 
slangc shader/terrain.slang -entry fragMain -stage fragment -target spirv -o shader/terrainFrag.spv

slangc shader/water.slang -entry vertMain -stage vertex -target spirv -o shader/waterVert.spv 
slangc shader/water.slang -entry fragMain -stage fragment -target spirv -o shader/waterFrag.spv


rmdir /s /q out
