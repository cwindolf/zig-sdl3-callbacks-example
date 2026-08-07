const std = @import("std");
const sdl = @import("sdl3");

const Io = std.Io;

var window: ?*sdl.SDL_Window = null;
var renderer: ?*sdl.SDL_Renderer = null;

// pub const main = sdl.main;
pub extern fn main(argc: c_int, argv: [*c][*c]u8) c_int;

// pub fn main(init: std.process.Init) void {
//     const arena = init.arena.allocator();
//     const args = init.minimal.args.toSlice(arena) catch |err| {
//         std.debug.panic("{s}", .{@errorName(err)});
//     };
//     const argc: c_int = @intCast(args.len);
//     const argv: [*c][*c]u8 = @ptrCast(@constCast(&args.ptr));
//     const ret = sdl.SDL_RunApp(argc, argv, my_runapp_callback, null);
//     if (ret != 0) {
//         std.debug.panic("{s}", .{sdl.SDL_GetError()});
//     }
// }

// fn my_runapp_callback(argc: c_int, argv: ?[*:null]?[*:0]u8) callconv(.c) c_int {
//     const c_argv: [*c][*c]u8 = @ptrCast(argv);
//     const ret = sdl.SDL_EnterAppMainCallbacks(argc, c_argv, appInit, appIterate, appEvent, appQuit);
//     if (ret != 0) {
//         std.debug.panic("{s}", .{sdl.SDL_GetError()});
//     }
//     return 0;
// }

// This function runs once at startup.
export fn SDL_AppInit(appstate: ?*?*anyopaque, argc: c_int, argv: ?[*:null]?[*:0]u8) sdl.SDL_AppResult {
    _ = appstate;
    _ = argc;
    _ = argv;

    sdl.SDL_Log("Init!");
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        sdl.SDL_Log("Couldn't create window/renderer: %s", sdl.SDL_GetError());
        return sdl.SDL_APP_FAILURE;
    }

    if (!sdl.SDL_CreateWindowAndRenderer(
        "gram",
        960,
        540,
        sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_HIGH_PIXEL_DENSITY,
        &window,
        &renderer,
    )) {
        sdl.SDL_Log("Couldn't create window/renderer: %s", sdl.SDL_GetError());
        return sdl.SDL_APP_FAILURE;
    }

    std.debug.print("zig: video driver: {s}\n", .{sdl.SDL_GetCurrentVideoDriver() orelse @as([*c]const u8, "null")});
    std.debug.print("zig: render driver: {s}\n", .{sdl.SDL_GetRendererName(renderer) orelse @as([*c]const u8, "null")});
    sdl.SDL_Log("sdl: video driver: %s", sdl.SDL_GetCurrentVideoDriver());
    sdl.SDL_Log("render driver: %s", sdl.SDL_GetRendererName(renderer));

    _ = sdl.SDL_SetAppMetadata("example", "0.0.0", "net.example.example");

    return sdl.SDL_APP_CONTINUE;
}

// This function runs when a new event (mouse input, keypresses, etc) occurs.
export fn SDL_AppEvent(appstate: ?*anyopaque, event: ?*sdl.SDL_Event) sdl.SDL_AppResult {
    _ = appstate;
    if (event.?.type == sdl.SDL_EVENT_QUIT) {
        return sdl.SDL_APP_SUCCESS;
    }
    return sdl.SDL_APP_CONTINUE;
}

// This function runs once per frame, and is the heart of the program.
export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) sdl.SDL_AppResult {
    _ = appstate;

    // Update the background color
    const now = @as(f64, @floatFromInt(sdl.SDL_GetTicks())) / 1000.0;
    const r: f32 = @floatCast(0.5 + 0.5 * @sin(now));
    const g: f32 = @floatCast(0.5 + 0.5 * @sin(now + std.math.pi * 2 / 3.0));
    const b: f32 = @floatCast(0.5 + 0.5 * @sin(now + std.math.pi * 4 / 3.0));

    if (!sdl.SDL_SetRenderDrawColorFloat(renderer, r, g, b, sdl.SDL_ALPHA_OPAQUE_FLOAT)) {
        std.debug.panic("{s}", .{sdl.SDL_GetError()});
    }
    if (!sdl.SDL_RenderClear(renderer)) {
        std.debug.panic("{s}", .{sdl.SDL_GetError()});
    }
    if (!sdl.SDL_RenderPresent(renderer)) {
        std.debug.panic("{s}", .{sdl.SDL_GetError()});
    }

    return sdl.SDL_APP_CONTINUE;
}

// This function runs once at shutdown.
export fn SDL_AppQuit(appstate: ?*anyopaque, result: sdl.SDL_AppResult) callconv(.c) void {
    _ = appstate;
    _ = result;
    // SDL will clean up the window/renderer for us.
}
