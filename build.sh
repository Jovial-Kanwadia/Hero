#!/bin/bash

# 1. Get the exact path to your 'handmade' folder
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 2. Go into the build folder (create if missing)
mkdir -p "$PROJECT_DIR/build"
pushd "$PROJECT_DIR/build" > /dev/null

FLAGS="-g -O0 -Wall -std=c++20 -fno-exceptions -fno-rtti"

# 3. Compile based on the OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    clang++ $FLAGS \
        -framework Cocoa \
        "$PROJECT_DIR/code/osx_main.mm" \
        -o handmade
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    g++ $FLAGS \
        "$PROJECT_DIR/code/linux_handmade.cpp" \
        -o handmade \
        -lSDL2
fi

# 4. Return to where we started
popd > /dev/null
