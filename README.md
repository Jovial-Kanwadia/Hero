## Build instructions

### Prerequisites

**macOS**
**Xcode Command Line Tools** (includes `clang++` and the Cocoa framework)
```
xcode-select --install
```
**Linux**
**GCC or Clang** and **X11/OpenGL dev libraries**

- Ubuntu/Debian:
```
sudo apt install g++ libx11-dev libgl-dev
```
- Fedora/RHEL:
```
sudo dnf install gcc-c++ libX11-devel mesa-libGL-devel
```
- Arch Linux:
```
sudo pacman -S gcc libx11 mesa
```

### Windows
- **Visual Studio 2022** (any edition — Community is free) with the **"Desktop development with C++"** workload selected during installation
- Download: https://visualstudio.microsoft.com/
- The MSVC compiler (`cl.exe`) is included automatically



### Linux and macOS
First, make the script executable (only need to do this once)
```
chmod +x build.sh
```
Then run it from the project root
```
./build.sh
```
Run the output binary
```
./build/handmade
```

### Windows
Open "Developer Command Prompt for VS" and in the root directory run
```
build.bat
```
Run the output binary
```
build/handmade.exe
```