const std = @import("std");
const builtin = @import("builtin");

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

test "parser test" {
    const charlist = "23456789TJQKA";
    inline for (@typeInfo(Hand.Value).Enum.fields) |field| {
        std.debug.print("\n fieldname: {s}", .{field.name});
    }
    for (charlist) |chr| {
        std.debug.print("\n{c}\n", .{chr});
        _ = try Hand.Value.parseFromChar(chr);
    }
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
            return std.math.order(@intFromEnum(rhs), @intFromEnum(lhs));
        }
        pub fn lessThan(context: void, lhs: Strength, rhs: Strength) bool {
            return std.sort.asc(@typeInfo(Value).Enum.tag_type)(context, @intFromEnum(lhs), @intFromEnum(rhs));
        }

        pub fn format(
            self: Strength,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;
            comptime var longest: usize = 0;
            inline for (@typeInfo(Strength).Enum.fields) |variant| {
                longest = if (variant.name.len > longest) variant.name.len else longest;
            }
            var buffer: [longest]u8 = [_]u8{' '} ** longest;
            inline for (@typeInfo(Strength).Enum.fields) |variant| {
                if (self == std.meta.stringToEnum(Strength, variant.name)) {
                    @memcpy(buffer[0..variant.name.len], variant.name);
                }
            }
            try writer.print("{s}", .{buffer});
        }

        pub fn getStrength(cards: *[5]Value) Strength {
            var copy: [5]Value = undefined;
            @memcpy(&copy, cards);
            std.mem.sort(Value, &copy, {}, Value.lessThan);
            switch (std.mem.count(Value, &copy, copy[0..1])) {
                5 => {
                    return Strength.FiveOfAKind;
                },
                4 => {
                    return Strength.FourOfAKind;
                },
                3 => {
                    if (std.mem.count(Value, &copy, copy[3..4]) == 2) {
                        return Strength.FullHouse;
                    } else {
                        return Strength.ThreeOfAKind;
                    }
                },
                2 => {
                    switch (std.mem.count(Value, &copy, copy[3..4])) {
                        3 => {
                            return Strength.FullHouse;
                        },
                        2 => {
                            return Strength.TwoPair;
                        },
                        else => {
                            return Strength.Pair;
                        },
                    }
                },
                1 => {
                    switch (std.mem.count(Value, &copy, copy[2..3])) {
                        4 => {
                            return Strength.FourOfAKind;
                        },
                        3 => {
                            return Strength.ThreeOfAKind;
                        },
                        2 => {
                            if (std.mem.count(Value, &copy, copy[3..4]) == 2) {
                                return Strength.TwoPair;
                            } else {
                                return Strength.Pair;
                            }
                        },
                        else => {
                            if (std.mem.count(Value, &copy, copy[3..4]) == 2) {
                                return Strength.Pair;
                            } else {
                                return Strength.HighCard;
                            }
                        },
                    }
                },
                else => {
                    unreachable;
                },
            }
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
                        return std.meta.stringToEnum(Value, field.name).?;
                    }
                } else if (field.name[0] == chr) {
                    return std.meta.stringToEnum(Value, field.name).?;
                }
            }
            return std.fmt.ParseIntError.InvalidCharacter;
        }
        pub fn format(
            self: Value,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;
            inline for (@typeInfo(Value).Enum.fields) |variant| {
                if (self == std.meta.stringToEnum(Value, variant.name)) {
                    if (variant.name.len == 2) {
                        try writer.print("{c}", .{variant.name[1]});
                    } else {
                        try writer.print("{c}", .{variant.name[0]});
                    }
                }
            }
        }

        fn lessThan(context: void, lhs: Value, rhs: Value) bool {
            return std.sort.desc(@typeInfo(Value).Enum.tag_type)(context, @intFromEnum(lhs), @intFromEnum(rhs));
        }
    };

    const Self = @This();
    stren: Strength,
    cards: [5]Value,
    bid: usize,

    pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("{}  |  {}{}{}{}{}  |  {d}", .{ self.stren, self.cards[0], self.cards[1], self.cards[2], self.cards[3], self.cards[4], self.bid });
    }

    pub fn parseLine(line: []const u8) Self {
        const space_idx = std.mem.indexOfScalar(u8, line, ' ').?;
        var cards: [5]Value = undefined;
        for (line[0..space_idx], 0..) |card, idx| {
            cards[idx] = Value.parseFromChar(card) catch {
                std.debug.print("\n|{c}|\n", .{card});
                unreachable;
            };
        }
        const stren = Strength.getStrength(&cards);

        const parsed = std.fmt.parseInt(usize, line[space_idx + 1 ..], 10) catch unreachable;
        return Self{
            .stren = stren,
            .cards = cards,
            .bid = parsed,
        };
    }

    pub fn lessThan(context: void, rhs: Self, lhs: Self) bool {
        switch (rhs.stren.order(lhs.stren)) {
            std.math.Order.lt => {
                return true;
            },
            std.math.Order.gt => {
                return false;
            },
            std.math.Order.eq => {
                var i: usize = 0;
                while (i < 5) : (i += 1) {
                    if (rhs.cards[i] != lhs.cards[i]) {
                        return Value.lessThan(context, lhs.cards[i], rhs.cards[i]);
                    }
                }
            },
        }
        unreachable;
    }
};
fn part1(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    var scores = std.ArrayList(Hand).init(alloc);
    var lines = std.mem.splitAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        scores.append(Hand.parseLine(line)) catch unreachable;
    }
    std.mem.sort(Hand, scores.items, {}, Hand.lessThan);
    for (scores.items, 1..) |hand, idx| {
        if (builtin.is_test) {
            std.debug.print("\nrank: {d}, bid: {d}", .{ idx, hand.bid });
        }
        std.debug.print("\nhand: {}", .{hand});
        score += hand.bid * idx;
    }
    return score;
}

test "p1" {
    const input =
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const expect: usize = 6440;
    const actual = part1(input, allocator);
    try std.testing.expectEqual(expect, actual);
}

fn part2(input: []u8) usize {
    _ = input;
    const score: usize = 0;

    return score;
}
