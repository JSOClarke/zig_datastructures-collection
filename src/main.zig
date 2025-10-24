const std = @import("std");

pub const Stack = struct {
    size: usize,
    capacity: usize,
    items: []u64,
    allocator: std.mem.Allocator,
    // Add a value onto the stack FIFO

    pub fn init(size: usize, allocator: std.mem.Allocator) !Stack {
        const items = try allocator.alloc(u64, size);
        return Stack{ .size = 0, .capacity = size, .items = items, .allocator = allocator };
    }
    // Free the allocated space
    pub fn deinit(self: *Stack) void {
        self.allocator.free(self.items);
    }

    pub fn Push(self: *Stack, item: u64) !void {
        if (self.capacity == self.size) {
            self.capacity = self.capacity * 2;
            self.items = try self.allocator.realloc(self.items, self.capacity);
        }
        if (self.size == 0) {
            self.items[0] = item;
        } else {
            self.items[self.size] = item;
        }
        self.size += 1;
    }
    // Removes the head or the most recently added item from the stack FIFO
    pub fn Pop(self: *Stack) !u64 {
        if (self.size == 0) {
            return error.EmptyStack;
        }
        const popped_value = self.items[self.size - 1];
        self.items[self.size - 1] = undefined;
        self.size -= 1;
        return popped_value;
    }

    pub fn TraverseStack(self: Stack) void {
        for (0..self.size) |i| {
            std.debug.print("Element {} : {}", .{ i, self.items[i] });
        }
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const N = 1_000_000;

    // Initialize ArrayList with capacity N
    var list = try std.ArrayList(u64).initCapacity(allocator, N);
    defer list.deinit(allocator);

    // --- Push benchmark ---
    const startPush = std.time.nanoTimestamp();
    for (0..N) |i| {
        try list.append(allocator, @intCast(i));
    }
    const mid = std.time.nanoTimestamp();

    // --- Pop benchmark ---
    var sum: u64 = 0; // make result observable
    while (list.items.len > 0) {
        const val = list.pop();
        sum += val orelse 0; // pop() returns ?T, so handle None
    }
    const end = std.time.nanoTimestamp();

    std.debug.print("ArrayList benchmark: Push: {} ns, Pop: {} ns, sum: {}\n", .{ mid - startPush, end - mid, sum });
}
