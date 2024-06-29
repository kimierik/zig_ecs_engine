const std = @import("std");
const Component = @import("component.zig").Component;

pub const engineError = error{
    NoComponentOfType,
    IteratorOutOfBounds,
};

// iterator type for components
pub fn ComponentIterator(T: type) type {
    return struct {
        const Self = @This();
        components: *std.ArrayList(*Component),
        index: u8,

        pub fn next(self: *Self) engineError!*T {
            if (self.index >= self.components.*.items.len) {
                return engineError.IteratorOutOfBounds;
            }
            const i = self.components.*.items[self.index];
            self.index += 1;
            const ret: *T = @fieldParentPtr("component", i);
            return ret;
        }
    };
}
