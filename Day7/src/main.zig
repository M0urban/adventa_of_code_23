const std = @import("std");

pub fn main() !void {
    //prepare general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    //open file
    var file = try std.fs.cwd().openFile("src/input.txt", .{});
    defer file.close();
    //prepare buffer for file-io
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();
    //prepare buffered reader
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();
    //Read whole file int  arraylist
    try reader.readAllArrayList(&buffer, std.math.maxInt(usize));

    //run parts
    std.debug.print("\npart 1: {}", .{part1(buffer.items, allocator)});
    std.debug.print("\npart 2: {}", .{part2(buffer.items)});
}

const Hand = struct {
    pub const Strength = enum(u8) {
        HighCard = 0,
        Pair,
        TwoPair,
        ThreeOfAKind,
        FullHouse,
        FourOfAKind,
        FiveOfAKind,

        pub fn order(rhs: Strength, lhs: Strength) std.math.Order {
            return std.math.order(rhs, lhs);
        }
    };

    pub const Value = enum(u8){
        A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, 2
    };
    stren: Strength,
    cards: [5]u8,
};
fn part1(input: []u8, alloc: std.mem.Allocator) usize {
    _ = alloc;
    _ = input;
    const score: usize = 0;

    return score;
}

fn part2(input: []u8) usize {
    _ = input;
    const score: usize = 0;

    return score;
}
