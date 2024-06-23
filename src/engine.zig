const std = @import("std");
pub const renderer = @import("renderer/renderer.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allog = gpa.allocator();

//main engine struct
pub const Engine = struct {
    // renderer interface
    renderer: renderer.Renderer,
    // hasmpapp with ocmponetnnet
    component_map: std.AutoHashMap(u8, *std.ArrayList(type)),

    allocator: std.mem.Allocator,

    /// init hashmap
    pub fn init(self: *Engine) !void {
        _ = self;
    }

    /// kill hasmapp does not deinit arrays
    pub fn deinit(self: *Engine) void {
        self.component_map.deinit();
    }

    pub fn registerComponent(self: *Engine, comptime name: u8, componetn_type: anytype) !void {
        const t = @TypeOf(componetn_type);
        var val = std.ArrayList(t).init(allog);
        try self.component_map.put(name, &val);
    }
};
