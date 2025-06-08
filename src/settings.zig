const rl = @import("raylib");

pub const window_width = 1920;
pub const window_height = 1080;
pub const bg_color = rl.Color.black;
pub const player_speed = 7;
pub const meteor_speed_range = [_]u8{ 3, 4 };
pub const timer_duration = 0.4;
pub const font_size = 60;
pub const font_padding = 60;
