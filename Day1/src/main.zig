const std = @import("std");

pub fn main() !void {
    std.debug.print("part1: {}", .{part1(@embedFile("./input.txt"))});
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

        _ = line;

    }
}
