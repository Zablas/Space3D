const rl = @import("raylib");
const FatPointer = @import("fat_pointer.zig").FatPointer;
const Game = @import("game.zig").Game;

pub fn Timer(comptime T: type, comptime Fn: type) type {
    return struct {
        const Self = @This();

        duration: f64,
        repeat: bool,
        func: ?FatPointer(T, Fn),
        start_time: f64 = 0,
        active: bool = false,

        pub fn init(duration: f64, repeat: bool, autostart: bool, func: ?FatPointer(T, Fn)) Self {
            var timer = Self{
                .duration = duration,
                .repeat = repeat,
                .func = func,
            };

            if (autostart) {
                timer.activate();
            }

            return timer;
        }

        pub fn activate(self: *Self) void {
            self.active = true;
            self.start_time = rl.getTime();
        }

        pub fn deactivate(self: *Self) void {
            self.active = false;
            self.start_time = 0;
            if (self.repeat) {
                self.activate();
            }
        }

        pub fn update(self: *Self) void {
            if (self.active) {
                if (rl.getTime() - self.start_time >= self.duration) {
                    if (self.func != null and self.start_time > 0) {
                        self.func.?.invoke(.{}) catch {};
                    }
                    self.deactivate();
                }
            }
        }
    };
}
