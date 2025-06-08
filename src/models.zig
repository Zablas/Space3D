const rl = @import("raylib");
const settings = @import("settings.zig");
const FatPointer = @import("fat_pointer.zig").FatPointer;
const Game = @import("game.zig").Game;

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

    pub fn update(self: *Self, delta_time: f32) void {
        self.move(delta_time);
    }

    fn move(self: *Self, delta_time: f32) void {
        self.position.x += self.direction.x * self.speed * delta_time;
        self.position.y += self.direction.y * self.speed * delta_time;
        self.position.z += self.direction.z * self.speed * delta_time;
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
    shoot_laser_func: FatPointer(Game, fn (*Game, rl.Vector3) anyerror!void) = undefined,
    angle: f32 = 0,

    pub fn init(model: rl.Model) Self {
        return .{
            .base = Model.init(model, rl.Vector3.zero(), settings.player_speed, rl.Vector3.zero()),
        };
    }

    pub fn input(self: *Self) !void {
        const delta = @as(i32, @intCast(@intFromBool(rl.isKeyDown(.right)))) - @as(i32, @intCast(@intFromBool(rl.isKeyDown(.left))));
        self.base.direction.x = @floatFromInt(delta);

        if (rl.isKeyPressed(.space)) {
            try self.shoot_laser_func.invoke(.{self.base.position.add(rl.Vector3.init(0, 0, -1))});
        }
    }

    pub fn update(self: *Self, delta_time: f32) !void {
        try self.input();
        self.base.update(delta_time);
        self.angle -= self.base.direction.x * 10 * delta_time;
        self.base.position.y += @floatCast(@sin(rl.getTime() * 5) * delta_time * 0.1);

        self.base.position.x = @max(-6, @min(self.base.position.x, 7));
        self.angle = @max(-15, @min(self.angle, 15));
    }

    pub fn draw(self: Self) void {
        rl.drawModelEx(self.base.model, self.base.position, rl.Vector3.init(0, 0, 1), self.angle, rl.Vector3.one(), .white);
    }
};

pub const Laser = struct {
    const Self = @This();

    base: Model,

    pub fn init(model: rl.Model, position: rl.Vector3, texture: rl.Texture) Self {
        const material: *rl.Material = @ptrCast(&model.materials[0]);
        rl.setMaterialTexture(material, .albedo, texture);

        return .{
            .base = Model.init(model, position, settings.laser_speed, rl.Vector3.init(0, 0, -1)),
        };
    }
};
