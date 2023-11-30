const std = @import("std");

const data  = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.tokenizeAny(u8, &data, "\n");

    for(lines) |line| {
        _ = line;

    }
}
