const rl = @import("raylib");
const settings = @import("settings.zig");

pub const Model = struct {
    const Self = @This();

    model: rl.Model,
    position: rl.Vector3,
    speed: f32,
    direction: rl.Vector3,

    pub fn init(model: rl.Model, position: rl.Vector3, speed: f32, direction: rl.Vector3) Self {
        return .{
            .model = model,
            .position = position,
            .speed = speed,
            .direction = direction,
        };
    }

    pub fn draw(self: Self) void {
        rl.drawModel(self.model, self.position, 1, .white);
    }

    pub fn update(self: *Self, deltaTime: f32) void {
        self.move(deltaTime);
    }

    fn move(self: *Self, deltaTime: f32) void {
        self.position.x += self.direction.x * self.speed * deltaTime;
        self.position.y += self.direction.y * self.speed * deltaTime;
        self.position.z += self.direction.z * self.speed * deltaTime;
    }
};

pub const Floor = struct {
    const Self = @This();

    base: Model,

    pub fn init(texture: rl.Texture) !Self {
        const model = try rl.loadModelFromMesh(rl.genMeshCube(32, 1, 32));

        const material: *rl.Material = @ptrCast(&model.materials[0]);
        rl.setMaterialTexture(material, .albedo, texture);

        return .{
            .base = Model.init(model, rl.Vector3.init(6.5, -2, -8), 0, rl.Vector3.zero()),
        };
    }
};

pub const Player = struct {
    const Self = @This();

    base: Model,
    shoot_laser_func: *const fn () anyerror!void,

    pub fn init(model: rl.Model, shoot_laser_func: *const fn () anyerror!void) Self {
        return .{
            .base = Model.init(model, rl.Vector3.zero(), settings.player_speed, rl.Vector3.zero()),
            .shoot_laser_func = shoot_laser_func,
        };
    }

    pub fn input(self: *Self) !void {
        const delta = @as(i32, @intCast(@intFromBool(rl.isKeyDown(.right)))) - @as(i32, @intCast(@intFromBool(rl.isKeyDown(.left))));
        self.base.direction.x = @floatFromInt(delta);

        if (rl.isKeyPressed(.space)) {
            try self.shoot_laser_func();
        }
    }

    pub fn update(self: *Self, delta_time: f32) !void {
        try self.input();
        self.base.update(delta_time);
    }
};
