const std = @import("std");
pub const Component = @import("engine/component.zig").Component;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allog = gpa.allocator();

// global engine instance
var engine: Engine = undefined;

/// make engine
pub fn init() void {
    engine = .{
        .allocator = allog,
        .component_map = std.StringHashMap(*std.ArrayList(*Component)).init(allog),
        .system_list = std.ArrayList(*const fn () void).init(allog),
    };
}

/// deinit engine
pub fn deinit() void {
    engine.component_map.deinit();
}

/// get engine struct instance. this is for debugging and not to be used
pub fn genInstance() *Engine {
    return &engine;
}

//------------------------------ components ------------------------------

/// tells engine this struct is a component
pub fn registerComponent(comptime name: type) !void {
    const a = try allog.create(std.ArrayList(*Component));
    a.* = std.ArrayList(*Component).init(allog);
    try engine.component_map.put(@typeName(name), a); // this is stack pointer so it borke i think.
    // even i ned to put it on the heap
    // but if i do i dont know how to initialise it with init
}

// adds a component instance to engine
pub fn addToComponentList(name: type, component: *Component) !void {
    std.debug.print("adds to list\n", .{});
    try engine.component_map.getPtr(@typeName(name)).?.*.append(component);
}

//------------------------------ systems ------------------------------

/// adds  a system to the engine
pub fn addSystem(system: *const fn () void) !void {
    try engine.system_list.append(system);
}

/// executes all systems in order
pub fn execSystems() void {
    for (engine.system_list.items) |system| {
        system();
    }
}

//main engine struct
const Engine = struct {
    // renderer interface
    // hasmpapp with ocmponetnnet
    component_map: std.StringHashMap(*std.ArrayList(*Component)),
    system_list: std.ArrayList(*const fn () void),

    allocator: std.mem.Allocator,
};
