const std = @import("std");
pub const Component = @import("engine/component.zig").Component;
pub const ComponentIterator = @import("engine/types.zig").ComponentIterator;
pub const engineError = @import("engine/types.zig").engineError;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allog = gpa.allocator();

// global engine instance
var engine: Engine = undefined;
// TODO :
// add tests

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

pub fn getComponentIterator(T: type) engineError!ComponentIterator(T) {
    const comps = engine.component_map.get(@typeName(T));
    if (comps) |v| {
        const a = ComponentIterator(T){
            .components = v,
            .index = 0,
        };

        return a;
    }
    return engineError.NoComponentOfType;
}

//------------------------------ systems ------------------------------
// systems are just a function in a list that get executed in order
// systems should not be added or removed durring game execution

/// adds  a system to the engine
pub fn addSystem(system: *const fn () anyerror!void) !void {
    try engine.system_list.append(system);
}

/// executes all systems in order
pub fn execSystems() !void {
    for (engine.system_list.items) |system| {
        try system();
    }
}

//------------------------------ engine ------------------------------

//main engine struct
const Engine = struct {
    // renderer interface
    // hasmpapp with ocmponetnnet
    component_map: std.StringHashMap(*std.ArrayList(*Component)),
    system_list: std.ArrayList(*const fn () anyerror!void),

    allocator: std.mem.Allocator,
};

/// make engine
pub fn init() void {
    engine = .{
        .allocator = allog,
        .component_map = std.StringHashMap(*std.ArrayList(*Component)).init(allog),
        .system_list = std.ArrayList(*const fn () anyerror!void).init(allog),
    };
}

/// deinit engine
pub fn deinit() void {
    engine.component_map.deinit();
}

/// get engine struct instance. this is for debugging and not to be used
pub fn getInstance() *Engine {
    return &engine;
}
