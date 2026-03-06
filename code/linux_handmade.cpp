#include <SDL2/SDL.h>
#include <stdint.h>
#include <stdio.h>

// Handmade Hero style macros for variable intent
#define internal static
#define local_persist static
#define global_variable static

// Handmade Hero style fixed-width types
typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

typedef int8_t int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

// Global state to keep the main loop running
global_variable bool GlobalRunning;

int main(int argc, char *argv[])
{
    // 1. Initialize SDL (Equivalent to checking Windows version/setup)
    // We only need the Video subsystem for now (which includes events)
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
        printf("SDL_Init Error: %s\n", SDL_GetError());
        return 1;
    }

    // 2. Create the Window (Equivalent to RegisterClassA + CreateWindowExA)
    SDL_Window *Window = SDL_CreateWindow(
        "Handmade Hero",           // Window title
        SDL_WINDOWPOS_UNDEFINED,   // X position (OS decides)
        SDL_WINDOWPOS_UNDEFINED,   // Y position (OS decides)
        1280,                      // Width
        720,                       // Height
        SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE // Flags
    );

    if (Window)
    {
        // 3. Create a Renderer (Needed in SDL to push pixels to the window)
        SDL_Renderer *Renderer = SDL_CreateRenderer(Window, -1, 0);
        
        if (Renderer)
        {
            GlobalRunning = true;

            // 4. The Main Game Loop
            while (GlobalRunning)
            {
                SDL_Event Event;

                // 5. The Message Loop (Equivalent to PeekMessage / DispatchMessage)
                while (SDL_PollEvent(&Event))
                {
                    switch (Event.type)
                    {
                        case SDL_QUIT:
                        {
                            // Triggered when the user clicks the 'X' or forcefully closes the window
                            GlobalRunning = false;
                        } break;

                        case SDL_KEYDOWN:
                        case SDL_KEYUP:
                        {
                            // We will handle keyboard input here later
                        } break;

                        case SDL_WINDOWEVENT:
                        {
                            // Handle window resizing, etc.
                        } break;
                    }
                }

                // --- GAME UPDATE AND RENDER GOES HERE ---

                // For now, let's just clear the screen to a visible color (Magenta)
                // so we know the window is actively rendering.
                SDL_SetRenderDrawColor(Renderer, 255, 0, 255, 255);
                SDL_RenderClear(Renderer);

                // Flip the buffer to the screen (Equivalent to StretchDIBits/SwapBuffers)
                SDL_RenderPresent(Renderer);
            }
        }
        else
        {
            printf("SDL_CreateRenderer Error: %s\n", SDL_GetError());
        }
    }
    else
    {
        printf("SDL_CreateWindow Error: %s\n", SDL_GetError());
    }

    // Clean up and exit cleanly
    SDL_Quit();
    return 0;
}
