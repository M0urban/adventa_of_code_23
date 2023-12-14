const std = @import("std");

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

fn part1(input: []const u8, alloc: std.mem.Allocator) usize {
    _ = alloc;
    var score: usize = 0;

    const line_len_lf = std.mem.indexOfScalar(u8, input, '\n') + 1;
    std.debug.assert(input.len % line_len_lf == line_len_lf - 1);
    const line_len = line_len_lf - 1;
    _ = line_len;
    const line_ammount = (input.len / line_len_lf) + 1;
    _ = line_ammount;

    return score;
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    _ = input;
    _ = alloc;
    score += 0;

    return score;
}
