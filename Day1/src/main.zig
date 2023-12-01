const std = @import("std");

pub fn main() !void {
    const file = @embedFile("./input.txt");
    std.debug.print("part1: {}", .{part1(file)});
    std.debug.print("part2: {}", .{part2(file)});
}

fn part1(input: []const u8) usize {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var sum: usize = 0;

    while (lines.next()) |line| {
        var first: usize = 0;
        var last: usize = 0;
        var i: usize = 0;
        inner: while (i < line.len) : (i += 1) {
            if (std.ascii.isDigit(line[i])) {
                first = line[i] - '0';

                break :inner;
            }
        }
        for (line) |chr| {
            if (std.ascii.isDigit(chr)) {
                last = chr - '0';
            }
        }
        sum += first * 10 + last;
    }
    return sum;
}

fn part2(input: []const u8) usize {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var sum: usize = 0;
    //variables for keeping track of start of character sequence
    while (lines.next()) |line| {
        var i: usize = 0;
        var first: ?usize = null;
        var last: usize = 0;
        while (i < line.len) : (i += 1) {
            const chr = line[i];
            if (std.ascii.isDigit(chr)) {
                if (first == null) {
                    first = chr - '0';
                }
                last = chr - '0';
            } else if (std.ascii.isAlphabetic(chr) and line.len - i >= 3) {
                const number: ?usize = switch (chr) {
                    'o' => blk: {
                        if (std.mem.order(u8, line[i .. i + 3], &[_]u8{ 'o', 'n', 'e' }) == std.math.Order.eq) {
                            break :blk 1;
                        }
                        break :blk null;
                    },
                    't' => blk: {
                        if (std.mem.order(u8, line[i .. i + 3], &[_]u8{ 't', 'w', 'o' }) == std.math.Order.eq) {
                            break :blk 2;
                        } else if (line.len - i >= 5) {
                            if (std.mem.order(u8, line[i .. i + 5], &[_]u8{ 't', 'h', 'r', 'e', 'e' }) == std.math.Order.eq) {
                                break :blk 3;
                            }
                        }
                        break :blk null;
                    },
                    'f' => blk: {
                        if (line.len - i >= 4) {
                            if (std.mem.order(u8, line[i .. i + 4], &[_]u8{ 'f', 'o', 'u', 'r' }) == std.math.Order.eq) {
                                break :blk 4;
                            } else if (std.mem.order(u8, line[i .. i + 4], &[_]u8{ 'f', 'i', 'v', 'e' }) == std.math.Order.eq) {
                                break :blk 5;
                            }
                        }
                        break :blk null;
                    },
                    's' => blk: {
                        if (std.mem.order(u8, line[i .. i + 3], &[_]u8{ 's', 'i', 'x' }) == std.math.Order.eq) {
                            break :blk 6;
                        } else if (line.len - i >= 5 and std.mem.order(u8, line[i .. i + 5], &[_]u8{ 's', 'e', 'v', 'e', 'n' }) == std.math.Order.eq) {
                            break :blk 7;
                        }
                        break :blk null;
                    },
                    'e' => blk: {
                        if (line.len - i >= 5 and std.mem.order(u8, line[i .. i + 5], &[_]u8{ 'e', 'i', 'g', 'h', 't' }) == std.math.Order.eq) {
                            break :blk 8;
                        }
                        break :blk null;
                    },
                    'n' => blk: {
                        if (line.len - i >= 4 and std.mem.order(u8, line[i .. i + 4], &[_]u8{ 'n', 'i', 'n', 'e' }) == std.math.Order.eq) {
                            break :blk 9;
                        }
                        break :blk null;
                    },
                    else => blk: {
                        break :blk null;
                    },
                };
                if (number) |num| {
                    if (first == null) {
                        first = num;
                    }
                    last = num;
                }
            }
        }
        std.debug.print("\n{any}{any}", .{ first, last });
        sum += first.? * 10 + last;
    }
    return sum;
}

test "part2 " {
    const input = "two1nine\neightwothreed\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen";
    const result = part2(input);
    std.debug.print("part2: {}", .{result});
    try std.testing.expect(result == 281);
}
