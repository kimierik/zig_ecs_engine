const std = @import("std");
const Entity = @import("../engine/entity.zig").Entity;
// self balancing binary tree
// this needs testing aswell

/// node for entitytree
const Node = struct {
    val: Entity,

    left: *Node,
    rigth: *Node,
};

/// Balanced btree for entities
pub const EntityTree = struct {
    root: *Node,
    allocaotr: std.mem.Allocator,

    // deinit
    fn deinit() void {
        // recursively go through all nodes and kill them
    }

    /// creates and adds an entity to the tree
    fn add(id: u32) !void {
        _ = id; // autofix
    }

    /// finds and returns entity from the tree
    fn find(id: u32) *Entity {
        _ = id; // autofix
    }

    /// removesd entity from tree
    fn remove(id: u32) void {
        _ = id; // autofix
    }
};
