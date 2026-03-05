#include <Foundation/Foundation.h>
#include <stdio.h>
#include <AppKit/AppKit.h>

// The window delegate
@interface HandmadeWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation HandmadeWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    printf("WM_CLOSE: Window is closing. Terminating App.\n");
    [NSApp terminate:self]; // Kill the loop
}

- (void)windowDidResize:(NSNotification *)notification {
    printf("WM_SIZE: Window Resized\n");
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    printf("WM_ACTIVATE: Window is now active\n");
}
@end

// The app delegate
@interface HandmadeAppDelegate : NSObject <NSApplicationDelegate>
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
    [window setBackgroundColor:[NSColor blackColor]];

    // We tell the window: "Send your events to this object."
    // We must keep a reference to it, or it will be deleted (ARC).
    // In a real app, we'd store this in a struct, but for now we essentially leak it or rely on the window retaining it.
    [window setDelegate:windowDelegate];

    [window makeKeyAndOrderFront:nil];
}
- (void)applicationWillTerminate:(NSNotification *)notification {
    printf("Handmade Hero is Terminating!\n");
}
@end

int main(int argc, const char *argv[]) {
  // Create the NSApplication Instance
  NSApplication *app = [NSApplication sharedApplication];

  // Set Activation policy. This allows NSApp to receive "app-level events" properly.
  [app setActivationPolicy:NSApplicationActivationPolicyRegular];

  // Create and Assign the Delegate.
  HandmadeAppDelegate *appDelegate = [[HandmadeAppDelegate alloc] init];
  [app setDelegate:appDelegate];

  // Start the Event loop.
  [app run];

  return 0;
}
