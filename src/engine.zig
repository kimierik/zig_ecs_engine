const std = @import("std");
pub const renderer = @import("renderer/renderer.zig");
pub const Component = @import("engine/component.zig").Component;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allog = gpa.allocator();

//main engine struct
pub const Engine = struct {
    // renderer interface
    renderer: renderer.Renderer,
    // hasmpapp with ocmponetnnet
    component_map: std.AutoHashMap(u8, *std.ArrayList(*Component)),

    allocator: std.mem.Allocator,

    /// init hashmap
    pub fn init(self: *Engine) !void {
        _ = self;
    }

    /// kill hasmapp does not deinit arrays
    pub fn deinit(self: *Engine) void {
        self.component_map.deinit();
    }

    /// register a component so that the engine knows that the struct is a component
    pub fn registerComponent(self: *Engine, comptime name: u8, component: Component) !void {
        _ = component; // autofix
        const a = try allog.create(std.ArrayList(*Component));
        a.* = std.ArrayList(*Component).init(allog);
        try self.component_map.put(name, a); // this is stack pointer so it borke i think.
        // even i ned to put it on the heap
        // but if i do i dont know how to initialise it with init
    }
    pub fn addToComponentList(self: *Engine, comptime name: u8, component: *Component) !void {
        std.debug.print("adds to list\n", .{});
        try self.component_map.getPtr(name).?.*.append(component);
    }
};
