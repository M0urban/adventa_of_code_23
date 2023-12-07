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
        pub fn lessThan(context: void, lhs: Strength, rhs: Strength) bool {
            return std.sort.asc(@typeInfo(Value).Enum.tag_type)(context, @intFromEnum(lhs), @intFromEnum(rhs));
        }
    };

    pub const Value = enum(u8) {
        N2 = 0,
        N3,
        N4,
        N5,
        N6,
        N7,
        N8,
        N9,
        T,
        J,
        Q,
        K,
        A,

        pub fn parseFromChar(chr: u8) std.fmt.ParseIntError!Value {
            inline for (@typeInfo(Value).Enum.fields) |field| {
                if (field.name.len == 2) {
                    if (field.name[1] == chr) {
                        return field;
                    }
                } else if (field.name[0] == chr) {
                    return field;
                } else {
                    return std.fmt.ParseIntError.InvalidCharacter;
                }
            }
        }
    };

    const Self = @This();
    stren: Strength,
    cards: [5]Value,
    bid: usize,

    pub fn parseLine(line: []const u8) Self {
        var hand = std.mem.trimRight(u8, line, " ");
        var bid = std.mem.trimLeft(u8, line, " ");
        var cards: [5]Value = undefined;
        for (hand, 0..) |card, idx| {
            cards[idx] = Value.parseFromChar(card) catch unreachable;
        }

        const parsed = std.fmt.parseInt(usize, bid, 10) catch unreachable;
        return Self{
            .stren = Strength.FiveOfAKind,
            .cards = cards,
            .bid = parsed,
        };
    }
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
