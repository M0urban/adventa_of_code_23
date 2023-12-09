const std = @import("std");
const builtin = @import("builtin");

pub fn main() !void {
    //prepare general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    //open file
    var file = try std.fs.cwd().openFile("src/input.txt", .{});
    defer file.close();
    //prepare buffer for file-io
    var buffer = std.ArrayList(u8).init(alloc);
    defer buffer.deinit();
    //prepare buffered reader
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();
    //Read whole file int  arraylist
    try reader.readAllArrayList(&buffer, std.math.maxInt(usize));

    //run parts
    std.debug.print("\npart 1: {}", .{part1(buffer.items, alloc)});
    std.debug.print("\npart 2: {}", .{part2(buffer.items, alloc)});
}

fn part1(input: []const u8, alloc: std.mem.Allocator) isize {
    var score: isize = 0;
    var list = std.ArrayList(isize).init(alloc);
    defer list.deinit();
    var lines = std.mem.splitAny(u8, input, "\r\n");

    inner: while (lines.next()) |line| {
        if (line.len == 0) {
            continue :inner;
        }
        list.clearRetainingCapacity();
        var numbers = std.mem.splitScalar(u8, line, ' ');
        outer: while (numbers.next()) |number| {
            //ignore empty slices
            if (number.len == 0) {
                continue :outer;
            }
            const parsed = std.fmt.parseInt(isize, number, 10) catch {
                std.debug.print(" |||{any}||| ", .{number});
                unreachable;
            };
            list.append(parsed) catch unreachable;
        }
        const len = list.items.len;
        const max_len = (len * len + len) / 2;
        if (list.capacity < max_len) {
            list.ensureTotalCapacity(max_len) catch unreachable;
        }
        const result = getPrediction(&list, 0, len);
        if (builtin.is_test) {
            std.debug.print("\n\ncurrent len: {d}", .{len});
        }
        if (builtin.is_test) {
            std.debug.print("\n\ncurrent score: {d}", .{result});
        }
        score += result;
    }

    return score;
}

//return value is .{current_accumulated_score, current extrapolated}
fn getPrediction(buffer: *std.ArrayList(isize), start_2b_diffed: usize, num_2b_diffed: usize) isize {
    var dupplets = std.mem.window(isize, buffer.items[start_2b_diffed .. start_2b_diffed + num_2b_diffed], 2, 1);
    var all_zero = true;
    const left_most = buffer.items[start_2b_diffed + num_2b_diffed - 1];
    while (dupplets.next()) |dupplet| {
        const diff = dupplet[1] - dupplet[0];
        if (diff != 0) {
            all_zero = false;
        }
        if (builtin.is_test) {
            std.debug.print("\ncurrent diff and zero: {d} : {any}", .{ diff, all_zero });
        }
        buffer.append(diff) catch unreachable;
    }
    if (builtin.is_test) {
        std.debug.print("\n\nlist={any}", .{buffer.items});
    }

    if (all_zero) {
        return left_most;
    } else {
        const ret = getPrediction(buffer, start_2b_diffed + num_2b_diffed, num_2b_diffed - 1);
        if (builtin.is_test) {
            std.debug.print("\ncurrent last and ret: {d} : {d}", .{ left_most, ret });
        }
        return left_most + ret;
    }
}

test "p1" {
    const input =
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const expect: isize = 114;
    const actual: isize = part1(input, alloc);
    try std.testing.expectEqual(expect, actual);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) isize {
    var score: isize = 0;
    var list = std.ArrayList(isize).init(alloc);
    list.deinit();
    var lines = std.mem.splitAny(u8, input, "\r\n");

    inner: while (lines.next()) |line| {
        if (line.len == 0) {
            continue :inner;
        }
        list.clearRetainingCapacity();
        var numbers = std.mem.splitScalar(u8, line, ' ');
        outer: while (numbers.next()) |number| {
            //ignore empty slices
            if (number.len == 0) {
                continue :outer;
            }
            const parsed = std.fmt.parseInt(isize, number, 10) catch {
                std.debug.print(" |||{any}||| ", .{number});
                unreachable;
            };
            list.append(parsed) catch unreachable;
        }
        const len = list.items.len;
        const max_len = (len * len + len) / 2;
        if (list.capacity < max_len) {
            list.ensureTotalCapacity(max_len) catch unreachable;
        }
        const result = getPrediction2(&list, 0, len);
        if (builtin.is_test) {
            std.debug.print("\n\ncurrent len: {d}", .{len});
        }
        if (builtin.is_test) {
            std.debug.print("\n\ncurrent score: {d}", .{result});
        }
        score += result;
    }

    return score;
}

fn getPrediction2(buffer: *std.ArrayList(isize), start_2b_diffed: usize, num_2b_diffed: usize) isize {
    var dupplets = std.mem.window(isize, buffer.items[start_2b_diffed .. start_2b_diffed + num_2b_diffed], 2, 1);
    var all_zero = true;
    const left_most = buffer.items[start_2b_diffed];
    if (builtin.is_test) {
        std.debug.print("\n\nleft most={d}", .{left_most});
    }
    while (dupplets.next()) |dupplet| {
        const diff = dupplet[1] - dupplet[0];
        if (diff != 0) {
            all_zero = false;
        }
        if (builtin.is_test) {
            std.debug.print("\ncurrent diff and zero: {d} : {any}", .{ diff, all_zero });
        }
        buffer.append(diff) catch unreachable;
    }
    // if (builtin.is_test) {
    //     std.debug.print("\n\nlist={any}", .{buffer.items});
    // }

    if (all_zero) {
        return left_most;
    } else {
        const ret = getPrediction2(buffer, start_2b_diffed + num_2b_diffed, num_2b_diffed - 1);
        if (builtin.is_test) {
            std.debug.print("\ncurrent last and ret: {d} : {d}", .{ left_most, ret });
        }
        return left_most - ret;
    }
}

test "p2" {
    const input =
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const expect: isize = 2;
    const actual: isize = part2(input, alloc);
    try std.testing.expectEqual(expect, actual);
}
