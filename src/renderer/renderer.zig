//
// a thing that can be drawn
pub const Drawable = struct {
    pub const Vtable = struct {
        data: *const fn (*Drawable) *anyopaque,
    };
    vtable: *const Vtable,
    // as mutch as i would want this to be const. it seems to destroy pointer conversions at some point
    pub fn data(self: *Drawable) *anyopaque {
        return self.vtable.data(self);
    }
};

// a swappable renderer
pub const Renderer = struct {
    pub const Vtable = struct {
        context: *anyopaque,
        draw: *const fn (*Renderer, obj: *Drawable) anyerror!void,
        init_window: *const fn (*Renderer) anyerror!void,
    };
    vtable: *const Vtable,

    // draw fn for object
    pub fn draw(self: *Renderer, obj: *Drawable) anyerror!void {
        try self.vtable.draw(self, obj);
    }

    pub fn init_window(self: *Renderer) anyerror!void {
        try self.vtable.init_window(self);
    }
};
