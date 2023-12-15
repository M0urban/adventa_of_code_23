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
    std.debug.print("\npart 1: {}", .{part1(buffer.items)});
    std.debug.print("\npart 2: {}", .{part2(buffer.items, alloc)});
}

fn hash(init: u8, input: []const u8) u8 {
    var state: u16 = init;

    for (input) |chr| {
        state += chr;
        state *= 17;
        state %= 256;
    }
    //truncating should be lossless here since state is result of mod 256
    //and therefore in u8 range
    return @truncate(state);
}

fn part1(input: []const u8) usize {
    var score: usize = 0;

    const no_lf = std.mem.trimRight(u8, input, "\r\n");
    var instructions = std.mem.splitScalar(u8, no_lf, ',');
    while (instructions.next()) |ins| {
        score += hash(0, ins);
    }
    return score;
}

test "p1" {
    const input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
    const expected: usize = 1320;
    const actual: usize = part1(input);
    try std.testing.expectEqual(expected, actual);
}

