const std = @import("std");

const engine = @import("engine");

const Renderer = engine.renderer.Renderer;
const Drawable = engine.renderer.Drawable;
const Component = engine.Component;

const renderimpl = struct {
    renderer: Renderer = .{ .vtable = &vtable },

    const vtable: Renderer.Vtable = .{
        .init_window = init_window,
        .draw = draw,
        .context = undefined,
    };

    fn init_window(rendr: *Renderer) anyerror!void {
        _ = rendr;
    }

    fn draw(rendr: *Renderer, obj: *engine.renderer.Drawable) anyerror!void {
        const self: *renderimpl = @fieldParentPtr("renderer", rendr);
        const a = obj.data();
        const inshp: *shape.innershp = @ptrCast(@alignCast(a));
        std.debug.print("\ninship is of len {d}\n", .{inshp.verts.items.len});
        // here do drawing calls for the whattever thing you want to render

        _ = self;
    }
};

const shape = struct {
    const Self = @This();

    drawable: Drawable = .{ .vtable = &vtable },

    // test to see if the pointer to this object is valid by printing this
    testing: *const [3]u8 = "mem",

    data: innershp,

    fn getData(drawable: *Drawable) *anyopaque {
        const self: *shape = @fieldParentPtr("drawable", drawable);

        const ptr: *anyopaque = @ptrCast(@constCast(&self.data));
        return ptr;
    }

    var vtable: Drawable.Vtable = .{
        .data = getData,
    };

    pub const innershp = struct {
        verts: std.ArrayList([2]u32),
        indices: std.ArrayList(u32),
    };

    pub fn make(verts: std.ArrayList([2]u32), inds: std.ArrayList(u32)) shape {
        const t = shape{
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

fn testSystem(eng: *engine.Engine) void {
    // can we turn this into an iterator of sorts so we could do a cleaner forloop
    // we can abstract some of this looping logic
    // or if we do a register system fn that accepts the component and the engine itself calls it in loop
    // gotta thing ab how we want systems to work in general
    const a = eng.component_map.getPtr(5);
    if (a) |b| {
        if (b.*.items.len > 0) {
            for (0..b.*.items.len) |i| {
                // this is fucking something idk if this is even supposed to work
                const self: *exampleComponent = @fieldParentPtr("component", b.*.items[i]);
                std.debug.print("gobs {s}\n", .{self.testing});
            }
        }
    }
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

    var shp = shape.make(verts, inds);
    var mcomp: exampleComponent = .{};

    var eng: engine.Engine = .{
        .renderer = rndrimpl.renderer,
        .allocator = alocator,
        .component_map = std.AutoHashMap(u8, *std.ArrayList(*Component)).init(alocator),
    };
    defer eng.deinit();
    try eng.registerComponent(5, mcomp.component);
    try eng.addToComponentList(5, &mcomp.component);

    testSystem(&eng);

    // register this drawable somewhere
    // some place where we call the draw calls of the objects
    try rndrimpl.renderer.draw(&shp.drawable);
}
