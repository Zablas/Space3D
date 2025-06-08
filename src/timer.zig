const rl = @import("raylib");

pub const Timer = struct {
    duration: f64,
    repeat: bool,
    func: ?*const fn () anyerror!void,
    start_time: f64 = 0,
    active: bool = false,

    pub fn init(duration: f64, repeat: bool, autostart: bool, func: ?*const fn () anyerror!void) Timer {
        var timer = Timer{
            .duration = duration,
            .repeat = repeat,
            .func = func,
        };

        if (autostart) {
            timer.activate();
        }

        return timer;
    }

    pub fn activate(self: *Timer) void {
        self.active = true;
        self.start_time = rl.getTime();
    }

    pub fn deactivate(self: *Timer) void {
        self.active = false;
        self.start_time = 0;
        if (self.repeat) {
            self.activate();
        }
    }

    pub fn update(self: *Timer) void {
        if (self.active) {
            if (rl.getTime() - self.start_time >= self.duration) {
                if (self.func != null and self.start_time > 0) {
                    self.func.?() catch {};
                }
                self.deactivate();
            }
        }
    }
};
