const std = @import("std");
const Stack = @import("main.zig").Stack;

test "Pushing to the stack increases the size" {
    const allocator = std.heap.page_allocator;
    var stack = try Stack.init(3, allocator);
    defer stack.deinit();
    try stack.Push(10);
    const size = stack.size;
    try std.testing.expect(size == 1);
}

test "Multiple Pushes to the stack" {
    const allocator = std.heap.page_allocator;
    var stack = try Stack.init(3, allocator);
    defer stack.deinit();
    try stack.Push(10);
    try stack.Push(20);

    try stack.Push(30);

    try stack.Push(40);
    try stack.Push(50);
    try stack.Push(60);
    try stack.Push(70);
    try stack.Push(80);

    // const size = stack.size;
    // try std.testing.expect(size == 1);
    // try std.testing.expect(false);
    std.debug.print("current capacity,{d}\n", .{stack.capacity});
}

test "Popping errors when used on an empty stack (size == 0)" {
    const allocator = std.heap.page_allocator;
    var stack = try Stack.init(3, allocator);
    defer stack.deinit();

    try std.testing.expectError(error.EmptyStack, stack.Pop());
}

test "Popping a populated stack decreases the stack size" {
    const allocator = std.heap.page_allocator;
    var stack = try Stack.init(3, allocator);
    defer stack.deinit();

    try stack.Push(10);
    try stack.Pop();

    try std.testing.expect(stack.size == 0);
}

test "benchmark Stack push/pop - heap page allocator" {
    const allocator = std.heap.page_allocator;
    var stack = try Stack.init(3, allocator);
    defer stack.deinit();

    const start = std.time.nanoTimestamp();
    for (0..5_000_000) |i| {
        // const p_val: u8 = @intCast(i);
        try stack.Push(@intCast(i));
    }
    const mid = std.time.nanoTimestamp();
    for (0..5_000_000) |_| {
        _ = try stack.Pop();
    }
    const end = std.time.nanoTimestamp();

    std.debug.print("Push: {} ns, Pop: {} ns\n", .{ mid - start, end - mid });
}

test "benchmark Stack push/pop - testing allocator" {
    const allocator = std.testing.allocator;
    var stack = try Stack.init(1_000_000, allocator);
    defer stack.deinit();

    const start = std.time.nanoTimestamp();
    for (0..5_000_000) |i| {
        // const p_val: u8 = @intCast(i);
        try stack.Push(@intCast(i));
    }
    const mid = std.time.nanoTimestamp();
    for (0..5_000_000) |_| {
        try stack.Pop();
    }
    const end = std.time.nanoTimestamp();

    std.debug.print("Push: {} ns, Pop: {} ns\n", .{ mid - start, end - mid });
}
