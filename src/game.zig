const std = @import("std");
const rl = @import("raylib");
const settings = @import("settings.zig");
const models = @import("models.zig");
const Timer = @import("timer.zig").Timer;

pub const Game = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    models: std.StringHashMap(rl.Model),
    sounds: std.StringHashMap(rl.Sound),
    music: std.StringHashMap(rl.Music),
    textures: std.ArrayList(rl.Texture),
    lasers: std.ArrayList(models.Laser),
    meteors: std.ArrayList(models.Meteor),
    dark_texture: rl.Texture = undefined,
    light_texture: rl.Texture = undefined,
    font: rl.Font = undefined,
    camera: rl.Camera3D,
    floor: models.Floor = undefined,
    player: models.Player = undefined,
    meteor_timer: Timer = undefined,

    pub fn init(allocator: std.mem.Allocator) !Self {
        const camera = rl.Camera3D{
            .position = rl.Vector3.init(-4, 8, 6),
            .target = rl.Vector3.init(0, 0, -1),
            .up = rl.Vector3.init(0, 1, 0),
            .fovy = 45,
            .projection = .perspective,
        };

        var game = Game{
            .allocator = allocator,
            .models = std.StringHashMap(rl.Model).init(allocator),
            .sounds = std.StringHashMap(rl.Sound).init(allocator),
            .music = std.StringHashMap(rl.Music).init(allocator),
            .textures = std.ArrayList(rl.Texture).init(allocator),
            .lasers = std.ArrayList(models.Laser).init(allocator),
            .meteors = std.ArrayList(models.Meteor).init(allocator),
            .camera = camera,
        };

        try game.importAssets();

        game.floor = try models.Floor.init(game.dark_texture);
        game.player = models.Player.init(game.models.get("player").?);

        return game;
    }

    pub fn deinit(self: *Self) void {
        self.models.deinit();
        self.sounds.deinit();
        self.music.deinit();
        self.textures.deinit();
        self.lasers.deinit();
        self.meteors.deinit();

        rl.unloadTexture(self.dark_texture);
        rl.unloadTexture(self.light_texture);
        rl.unloadFont(self.font);
    }

    pub fn run(self: *Self) !void {
        while (!rl.windowShouldClose()) {
            try self.update();
            self.draw();
        }
    }

    fn update(self: *Self) !void {
        const delta_time = rl.getFrameTime();
        self.meteor_timer.update();
        try self.player.update(delta_time);

        for (self.lasers.items) |*laser| {
            laser.base.update(delta_time);
        }

        for (self.meteors.items) |*meteor| {
            meteor.update(delta_time);
        }
    }

    pub fn shootLaser(self: *Self, position: rl.Vector3) !void {
        try self.lasers.append(models.Laser.init(self.models.get("laser").?, position, self.light_texture));
    }

    pub fn createMeteor(self: *Self) !void {
        var prng = std.Random.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        const rand = prng.random();

        try self.meteors.append(try models.Meteor.init(self.textures.items[rand.intRangeAtMost(usize, 0, self.textures.items.len - 1)]));
    }

    fn draw(self: Self) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(settings.bg_color);

        rl.beginMode3D(self.camera);
        defer rl.endMode3D();

        self.floor.base.draw();
        self.drawShadows();
        self.player.draw();

        for (self.lasers.items) |laser| {
            laser.base.draw();
        }

        for (self.meteors.items) |meteor| {
            meteor.base.draw();
        }
    }

    fn drawShadows(self: Self) void {
        const player_radius = 0.5 + self.player.base.position.y;

        rl.drawCylinder(
            rl.Vector3.init(self.player.base.position.x, -1.5, self.player.base.position.z),
            player_radius,
            player_radius,
            0.1,
            20,
            rl.Color.init(0, 0, 0, 50),
        );

        for (self.meteors.items) |meteor| {
            rl.drawCylinder(
                rl.Vector3.init(meteor.base.position.x, -1.5, meteor.base.position.z),
                meteor.radius * 0.8,
                meteor.radius * 0.8,
                0.1,
                20,
                rl.Color.init(0, 0, 0, 50),
            );
        }
    }

    fn importAssets(self: *Self) !void {
        try self.models.put("player", try rl.loadModel("assets/models/ship.glb"));
        try self.models.put("laser", try rl.loadModel("assets/models/laser.glb"));

        try self.sounds.put("laser", try rl.loadSound("assets/audio/laser.wav"));
        try self.sounds.put("explosion", try rl.loadSound("assets/audio/explosion.wav"));

        try self.music.put("music", try rl.loadMusicStream("assets/audio/music.wav"));

        try self.textures.append(try rl.loadTexture("assets/textures/red.png"));
        try self.textures.append(try rl.loadTexture("assets/textures/green.png"));
        try self.textures.append(try rl.loadTexture("assets/textures/orange.png"));
        try self.textures.append(try rl.loadTexture("assets/textures/purple.png"));

        self.dark_texture = try rl.loadTexture("assets/textures/dark.png");
        self.light_texture = try rl.loadTexture("assets/textures/light.png");
        self.font = try rl.loadFontEx("assets/font/Stormfaze.otf", settings.font_size, null);
    }
};
