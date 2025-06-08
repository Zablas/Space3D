const rl = @import("raylib");

pub const window_width = 1920;
pub const window_height = 1080;
pub const bg_color = rl.Color.black;
pub const player_speed = 7;
pub const meteor_speed_range = [_]f32{ 3, 4 };
pub const meteor_timer_duration = 0.4;
pub const font_size = 60;
pub const font_padding = 60;
pub const laser_speed = 9;
