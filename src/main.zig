const std = @import("std");
const rl = @import("raylib");
const settings = @import("settings.zig");
const Game = @import("game.zig").Game;

pub fn main() !void {
    rl.initWindow(settings.window_width, settings.window_height, "Space shooter");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var game = try Game.init(allocator);
    defer game.deinit();

    try game.run();
}
