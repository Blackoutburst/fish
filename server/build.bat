@echo off
set NAME=FishServer
set SRC=out/src/*.cc
set INCLUDE=-Iout\include

set I_UHC="%USERPROFILE%\.local\include"
set L_UHC="%USERPROFILE%\.local\lib"
set UHC=-I"%I_UHC%" -L"%L_UHC%" -luhc

set F_ERROR=-Wall -Wextra -Wpedantic
set F_DEBUG=-g3 -fno-omit-frame-pointer

unholyc -I%I_UHC% ./ out/

echo CLANG:
clang++ -o %NAME% %SRC% %INCLUDE% %UHC% %F_ERROR% %F_DEBUG% -lws2_32
set CLANG_EXIT=%ERRORLEVEL%

if %CLANG_EXIT% neq 0 (
    echo FAILED
) else (
    echo OK
)

rmdir /s /q out
