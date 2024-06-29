const std = @import("std");

const engine = @import("engine");

const Renderer = engine.renderer.Renderer;
const Drawable = engine.renderer.Drawable;
const Component = engine.Component;

const renderimpl = struct {
    fn draw(rendr: *renderimpl, obj: Shape) anyerror!void {
        _ = rendr; // autofix
        std.debug.print("\ninship is of len {d}\n", .{obj.data.verts.items.len});
        // here do drawing calls for the whattever thing you want to render
    }
};

const Shape = struct {
    const Self = @This();

    testing: *const [3]u8 = "mem",

    data: innershp,

    pub const innershp = struct {
        verts: std.ArrayList([2]u32),
        indices: std.ArrayList(u32),
    };

    pub fn make(verts: std.ArrayList([2]u32), inds: std.ArrayList(u32)) Shape {
        const t = Shape{
            .data = .{
                .verts = verts,
                .indices = inds,
            },
        };

        return t;
    }
};

const exampleComponent = struct {
    component: Component = .{ .vtable = &VTable },
    testing: *const [3]u8 = "mem",
    const VTable: Component.VTable = .{};
};

fn testSystem() !void {
    var a = try engine.getComponentIterator(exampleComponent);
    const b = try a.next();
    // proves we get the example component type
    std.debug.print("gobers {s}\n", .{b.testing});
}

pub fn main() !void {
    var rndrimpl = renderimpl{};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alocator = gpa.allocator();
    defer _ = gpa.deinit();

    var verts = std.ArrayList([2]u32).init(alocator);
    defer verts.deinit();
    try verts.append(.{ 20, 50 });
    try verts.append(.{ 50, 720 });
    try verts.append(.{ 550, 681 });

    var inds = std.ArrayList(u32).init(alocator);
    defer inds.deinit();
    try inds.append(0);
    try inds.append(1);
    try inds.append(2);

    const shp = Shape.make(verts, inds);
    var mcomp: exampleComponent = .{};

    engine.init();
    defer engine.deinit();

    try engine.registerComponent(exampleComponent);
    try engine.addToComponentList(exampleComponent, &mcomp.component);

    try engine.addSystem(testSystem);

    try engine.execSystems();

    try rndrimpl.draw(shp);
}
