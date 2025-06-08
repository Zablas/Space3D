const std = @import("std");

pub fn FatPointer(comptime T: type, comptime Fn: type) type {
    return struct {
        const Self = @This();

        state: *T,
        method: *const Fn,

        pub fn invoke(self: Self, arguments: anytype) !void {
            try @call(.auto, self.method, .{self.state} ++ arguments);
        }
    };
}
