@echo off
setlocal

set ProjectDir=%~dp0
set BuildDir=%ProjectDir%build

if not exist "%BuildDir%" mkdir "%BuildDir%"
pushd "%BuildDir%"

:: Make sure MSVC is on the PATH - run this from a Developer Command Prompt
:: or call vcvarsall.bat here if you want to support a plain cmd.exe:
:: call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

cl /nologo /Zi /Od /W4 /std:c++20 /Gm- /EHa- ^
    "%ProjectDir%code\win32_handmade.cpp" ^
    /link /incremental:no /opt:ref ^
    user32.lib gdi32.lib winmm.lib ^
    /out:handmade.exe

popd
endlocal