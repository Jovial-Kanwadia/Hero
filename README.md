# Handmade Hero (Cross-Platform)

This project follows the [Handmade Hero](https://handmadehero.org/) architecture, implementing custom platform layers for Windows (Win32), macOS (Cocoa), and Linux (SDL2) to maintain a highly optimized, cross-platform codebase.

---

# Prerequisites

Before building the project, ensure you have the necessary compiler and platform libraries installed for your operating system.

## Windows

- **Visual Studio 2022** (Community edition is free)  
- Make sure to select the **Desktop development with C++** workload during installation.

> Note: The MSVC compiler (`cl.exe`) is included automatically with this workload.

Download:  
https://visualstudio.microsoft.com/

---

## macOS

Install **Xcode Command Line Tools** (includes `clang++` and the Cocoa framework).

```bash
xcode-select --install
```

---

## Linux (SDL2)

You need a **C++ compiler** and **SDL2 development libraries**.

### Arch Linux

```bash
sudo pacman -S base-devel sdl2
```

### Ubuntu / Debian

```bash
sudo apt install build-essential libsdl2-dev
```

### Fedora / RHEL

```bash
sudo dnf install gcc-c++ SDL2-devel
```

---

# Build & Run Instructions

## Windows

1. Open **x64 Native Tools Command Prompt for VS**.
2. Navigate to the root directory of this project.

Run the build script:

```cmd
build.bat
```

Run the compiled executable:

```cmd
build\handmade.exe
```

---

## macOS and Linux

1. Open a terminal and navigate to the project root.

Make the build script executable (only required once):

```bash
chmod +x build.sh
```

Run the build script:

```bash
./build.sh
```

Run the compiled executable:

```bash
./build/handmade
```

---

# Project Structure

```
code/
    win32_handmade.cpp
    osx_main.mm
    linux_handmade.cpp

build/
    (generated binaries and intermediate files)

build.bat
build.sh
```

- **code/** – Platform layer source files  
- **build/** – Generated binaries and temporary files  
- **build.bat / build.sh** – Automated build scripts for Windows and Unix-like systems

---

# Notes

- The Linux platform layer uses **SDL2** instead of raw **X11/OpenGL** for windowing and input.
- The project structure mirrors the architecture used in Handmade Hero to keep the **game code platform-independent**.

---
