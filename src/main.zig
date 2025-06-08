const std = @import("std");
const rl = @import("raylib");
const settings = @import("settings.zig");
const FatPointer = @import("fat_pointer.zig").FatPointer;
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
    game.player.shoot_laser_func = FatPointer(Game, fn (*Game, rl.Vector3) anyerror!void){
        .state = &game,
        .method = Game.shoot_laser,
    };
    defer game.deinit();

    try game.run();
}
