#include <Foundation/Foundation.h>
#include <cstdio>
#include <mach/processor.h>
#include <objc/objc.h>
#include <stdio.h>
#include <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <sys/mman.h>
#import <unistd.h>  

#define internal static
#define local_persist static
#define global_variable static

typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

typedef int8_t int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

// 1. Define our global backbuffer structure
struct mac_offscreen_buffer {
    void *Memory;
    int Width;
    int Height;
    int Pitch;
    int BytesPerPixel;
};

global_variable bool GlobalRunning = false;
global_variable mac_offscreen_buffer GlobalBackbuffer;
global_variable int GlobalXOffset = 0; // Added
global_variable int GlobalYOffset = 0; // Added

// 2. The Mac equivalent of Win32ResizeDIBSection
/*
buffer uses 32-bit color
1 byte = 8 bits
4 bytes = 32 bits
So each pixel occupies:
Blue   = 1 byte
Green  = 1 byte
Red    = 1 byte
Alpha / unused = 1 byte
Memory layout (little-endian):
| Blue | Green | Red | Alpha |
BBBBBBBB GGGGGGGG RRRRRRRR AAAAAAAA
*/
internal void MacResizeDIBSection(mac_offscreen_buffer *Buffer, int Width, int Height) {
    // If we already have memory, free it before reallocating
    if (Buffer->Memory) {
        int TotalSize = Buffer->Width * Buffer->Height * Buffer->BytesPerPixel;
        munmap(Buffer->Memory, TotalSize);
    }

    Buffer->Width = Width;
    Buffer->Height = Height;
    Buffer->BytesPerPixel = 4;
    Buffer->Pitch = Width * Buffer->BytesPerPixel;

    int BitmapMemorySize = Buffer->Pitch * Buffer->Height;
    
    // mmap is our VirtualAlloc. 
    // PROT_READ | PROT_WRITE means we can read and write to it.
    // MAP_PRIVATE | MAP_ANON means it's just RAM, not backed by a physical file.
    Buffer->Memory = mmap(0, BitmapMemorySize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
/*
Example - Window Width: 1280 pixels, Window Height: 720 pixels
Each pixel: 4 bytes
Buffer->Pitch = Width * Buffer->BytesPerPixel;
Pitch = 1280 * 4 = 5120 bytes
BitmapMemorySize = Buffer->Pitch * Buffer->Height;
BitmapMemorySize = 5120 * 720 = 3,686,400 bytes ~ 3.5 MB
Memory
 ├── Row 0 (5120 bytes)
 ├── Row 1 (5120 bytes)
 ├── Row 2
 ├── Row 3
 └── ...
*/
}

// 3. The Mac equivalent of Win32UpdateWindow (StretchDIBits)
internal void MacUpdateWindow(mac_offscreen_buffer *Buffer, CGContextRef Context, int WindowWidth, int WindowHeight) {
    // Tell Core Graphics how our raw memory is formatted
    CGColorSpaceRef ColorSpace = CGColorSpaceCreateDeviceRGB();
    
    // kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst is the Mac way of saying 0x00RRGGBB
    CGContextRef BitmapContext = CGBitmapContextCreate(
        Buffer->Memory, Buffer->Width, Buffer->Height, 8, Buffer->Pitch, 
        ColorSpace, (uint32)kCGBitmapByteOrder32Little | (uint32)kCGImageAlphaNoneSkipFirst);

    // Create an image out of it and blast it to the view
    CGImageRef Image = CGBitmapContextCreateImage(BitmapContext);
    CGContextDrawImage(Context, CGRectMake(0, 0, WindowWidth, WindowHeight), Image);

    // Clean up Apple's objects
    CGImageRelease(Image);
    CGContextRelease(BitmapContext);
    CGColorSpaceRelease(ColorSpace);
}

// 4. Game Logic: Rendering the weird gradient
internal void RenderWeirdGradient(mac_offscreen_buffer *Buffer, int XOffset, int YOffset) {
    uint8 *Row = (uint8 *)Buffer->Memory;

    for (int Y = 0; Y < Buffer->Height; ++Y) {
        uint32 *Pixel = (uint32 *)Row;
        
        for (int X = 0; X < Buffer->Width; ++X) {
            uint8 Blue = (X + XOffset);
            uint8 Green = (Y + YOffset);
            uint8 Red = (Y + YOffset);

            // On Apple Silicon / Intel Macs (Little Endian), the layout is BB GG RR xx
            *Pixel++ = (Red << 16) | (Green << 8) | Blue;
        }
        Row += Buffer->Pitch;
    }
/*
   for (int Y = 0; Y < Buffer->Height; ++Y) {
      uint8 *pixel = (uint8 *)Row;

      for (int X = 0; X < Buffer->Width; ++X) {
        // Pixel in memory: BB GG RR xx 
        // In Register: 0x xx RR GG BB (Little Endian Architecture)
        *pixel = (uint8)X;
        ++pixel;

        *pixel = (uint8)Y;
        ++pixel;

        *pixel = (uint8)Y;
        ++pixel;

        *pixel = 0;
        ++pixel;
      }
      Row += Buffer->Pitch;
    }
*/
/*
Buffer->Memory is void*
void* cannot be used for pointer arithmetic.

*/
}


// CUSTOM VIEW: This is where the actual drawing to the screen happens
@interface HandmadeView : NSView
@end

@implementation HandmadeView
- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef Context = (CGContextRef)[[NSGraphicsContext currentContext] CGContext];
    MacUpdateWindow(&GlobalBackbuffer, Context, self.bounds.size.width, self.bounds.size.height);
  }
@end

// WINDOW DELEGATE: Handles window-specific events
@interface HandmadeWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation HandmadeWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    printf("WM_CLOSE: Window is closing. Terminating App.\n");
    GlobalRunning = false;
}

- (void)windowDidResize:(NSNotification *)notification {
    printf("WM_SIZE: Window Resized\n");
    NSWindow *window = [notification object];
    NSRect clientRect = [[window contentView] bounds];

    // 1. Resize our buffer
    MacResizeDIBSection(&GlobalBackbuffer, clientRect.size.width, clientRect.size.height);

    // 2. MANUALLY RENDER A FRAME!
    // Since the main loop is paused, we must fill the new mmap zeroes with our gradient.
    GlobalXOffset += 1;
    GlobalYOffset += 2;

    RenderWeirdGradient(&GlobalBackbuffer, GlobalXOffset, GlobalYOffset);

    // 3. Force the view to redraw immediately
    [[window contentView] setNeedsDisplay:YES];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    printf("WM_ACTIVATE: Window is now active\n");
}
@end

// APP DELEGATE: Handles application lifecycle events
@interface HandmadeAppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSWindow *window;
@end

@implementation HandmadeAppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    printf("App Launched. Creating Window...\n");
    
    // Create the Window Delegate
    HandmadeWindowDelegate *windowDelegate = [[HandmadeWindowDelegate alloc] init];

    // Create the Window
    NSRect windowRect = NSMakeRect(0, 0, 1280, 720);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:windowRect 
                                          styleMask:NSWindowStyleMaskTitled | 
                                                    NSWindowStyleMaskClosable |
                                                    NSWindowStyleMaskResizable |
                                                    NSWindowStyleMaskMiniaturizable
                                          backing:NSBackingStoreBuffered
                                          defer:NO];

    // Configure the window
    [window setTitle:@"Handmade Hero"];
    // Attach our custom rendering view to the window
    HandmadeView *view = [[HandmadeView alloc] initWithFrame:windowRect];
    [window setContentView:view];

    // Connect delegate: window sends events → windowDelegate methods
    [window setDelegate:windowDelegate];

    // Store window reference (prevents ARC from deallocating it)
    self.window = window;

    // Make window visible and bring to front
    [window makeKeyAndOrderFront:nil];

    // Initial buffer allocation
    MacResizeDIBSection(&GlobalBackbuffer, 1280, 720);
}
- (void)applicationWillTerminate:(NSNotification *)notification {
    printf("Handmade Hero is Terminating!\n");
    GlobalRunning = false; 
}
@end


int main(int argc, const char *argv[]) {
    @autoreleasepool {
      // Create the NSApplication Instance
      NSApplication *app = [NSApplication sharedApplication];

      // Set Activation policy. This allows NSApp to receive "app-level events" properly.
      [app setActivationPolicy:NSApplicationActivationPolicyRegular];

      // Create app delegate (handles app-level events)
      HandmadeAppDelegate *appDelegate = [[HandmadeAppDelegate alloc] init];

      // Connect delegate: app sends events → appDelegate methods
      [app setDelegate:appDelegate];

      // CRITICAL: Finish launching manually (since we skip [app run])
      [app finishLaunching];

      GlobalRunning = true;

      // Start the Custom Event loop.
      while(GlobalRunning){
        @autoreleasepool {
          NSEvent *event;
          while((event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                                      untilDate:[NSDate dateWithTimeIntervalSinceNow:0.01] 
                                                      inMode:NSDefaultRunLoopMode 
                                                      dequeue:YES])) {
                [NSApp sendEvent:event];
          }
          // Game Logic
          // 1. Render our game to the memory buffer
          RenderWeirdGradient(&GlobalBackbuffer, GlobalXOffset, GlobalYOffset);

          // 2. Tell macOS that our view needs to be redrawn using this frame
          NSWindow *window = [appDelegate window];
          [[window contentView] setNeedsDisplay:YES];
          
          GlobalXOffset += 1;
          GlobalYOffset += 2;
        }
        // Frame pacing: sleep to avoid 100% CPU, target ~60fps
        [NSThread sleepForTimeInterval:0.016]; // 16.67ms ≈ 60 FPS
      }
    }
    return 0;
}
