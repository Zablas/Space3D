const std = @import("std");
const rl = @import("raylib");
const settings = @import("settings.zig");
const models = @import("models.zig");

pub const Game = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    models: std.StringHashMap(rl.Model),
    sounds: std.StringHashMap(rl.Sound),
    music: std.StringHashMap(rl.Music),
    textures: std.ArrayList(rl.Texture),
    dark_texture: rl.Texture = undefined,
    light_texture: rl.Texture = undefined,
    font: rl.Font = undefined,
    camera: rl.Camera3D,
    floor: models.Floor = undefined,
    player: models.Player = undefined,

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
            .camera = camera,
        };

        try game.importAssets();

        game.floor = try models.Floor.init(game.dark_texture);
        game.player = models.Player.init(game.models.get("player").?, Game.shoot_laser);

        return game;
    }

    pub fn deinit(self: *Self) void {
        self.models.deinit();
        self.sounds.deinit();
        self.music.deinit();
        self.textures.deinit();

        rl.unloadTexture(self.dark_texture);
        rl.unloadTexture(self.light_texture);
        rl.unloadFont(self.font);
    }

    pub fn run(self: *Self) void {
        while (!rl.windowShouldClose()) {
            self.update();
            self.draw();
        }
    }

    fn update(_: *Self) void {
        _ = rl.getFrameTime();
    }

    fn shoot_laser() !void {}

    fn draw(self: Self) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(settings.bg_color);

        rl.beginMode3D(self.camera);
        defer rl.endMode3D();

        self.floor.base.draw();
        self.player.base.draw();
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
