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
    std.debug.print("\npart 2: {}", .{part2(buffer.items, allocator)});
}

const Paths = struct {
    const Self = @This();
    left: [3]u8,
    right: [3]u8,
};

const Direction = enum {
    L,
    R,

    fn parseFormChar(chr: u8) ?Direction {
        inline for (@typeInfo(Direction).Enum.fields) |field| {
            if (field.name.len != 1) {
                @compileError("Variant names with more than letter are not allowed");
            }
            if (field.name[0] == chr) {
                return std.meta.stringToEnum(Direction, field.name).?;
            }
        }
        return null;
    }
};

fn part1(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    var directions = std.ArrayList(Direction).init(alloc);
    defer directions.deinit();
    var paths = std.AutoArrayHashMap([3]u8, Paths).init(alloc);
    defer paths.deinit();

    var directions_paths = std.mem.splitSequence(u8, input, "\n\n");
    const directions_unparsed = directions_paths.next().?;
    const paths_unparsed = directions_paths.next().?;

    //first parse direction list
    for (directions_unparsed) |direction| {
        directions.append(Direction.parseFormChar(direction).?) catch unreachable;
    }

    //next parse directions
    var lines = std.mem.splitAny(u8, paths_unparsed, "\n");
    while (lines.next()) |line| {
        if (line.len != 0) {
            var cur: [3]u8 = undefined;
            @memcpy(&cur, line[0..3]);
            var left: [3]u8 = undefined;
            var right: [3]u8 = undefined;
            @memcpy(&left, line[7..10]);
            @memcpy(&right, line[12..15]);
            const left_right = Paths{
                .left = left,
                .right = right,
            };
            paths.put(cur, left_right) catch unreachable;
        }
    }
    std.debug.print("\n\n contains ZZZ", .{});
    //set curent position to first key
    var cur_pos: [3]u8 = [_]u8{ 'A', 'A', 'A' };
    std.debug.print("\n\n starting point is: {s}", .{cur_pos});
    var i: usize = 0;
    loop: while (true) {
        const left_right: Paths = paths.get(cur_pos).?;
        cur_pos = if (directions.items[i] == Direction.L) left_right.left else left_right.right;
        // std.debug.print("\n\n next path is: {s}", .{&cur_pos});
        score += 1;
        if (cur_pos[0] == cur_pos[1] and cur_pos[1] == cur_pos[2] and cur_pos[2] == 'Z') {
            std.debug.print("\n\nReachable\n", .{});
            break :loop;
        } else {
            i += 1;
            if (i >= directions.items.len) {
                i = 0;
            }
        }
    }

    return score;
}

test "p1" {
    const input =
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    try std.testing.expectEqual(part1(input, alloc), 6);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var directions = std.ArrayList(Direction).init(alloc);
    defer directions.deinit();
    var start_pos = std.ArrayList([3]u8).init(alloc);
    defer start_pos.deinit();
    var paths = std.AutoArrayHashMap([3]u8, Paths).init(alloc);
    defer paths.deinit();

    var directions_paths = std.mem.splitSequence(u8, input, "\n\n");
    const directions_unparsed = directions_paths.next().?;
    const paths_unparsed = directions_paths.next().?;

    //first parse direction list
    for (directions_unparsed) |direction| {
        directions.append(Direction.parseFormChar(direction).?) catch unreachable;
    }

    //next parse directions
    var lines = std.mem.splitAny(u8, paths_unparsed, "\n");
    while (lines.next()) |line| {
        if (line.len != 0) {
            var cur: [3]u8 = undefined;
            @memcpy(&cur, line[0..3]);
            if (cur[2] == 'A') {
                start_pos.append(cur) catch unreachable;
                std.debug.print("\n start pos: {s}", .{cur});
            }
            var left: [3]u8 = undefined;
            var right: [3]u8 = undefined;
            @memcpy(&left, line[7..10]);
            @memcpy(&right, line[12..15]);
            const left_right = Paths{
                .left = left,
                .right = right,
            };
            paths.put(cur, left_right) catch unreachable;
        }
    }

    std.debug.print("\n {d} start positions: ", .{start_pos.items.len});
    for (start_pos.items) |pos| {
        std.debug.print("\n start pos: {s}", .{pos});
    }

    //set curent position to first key
    var lcm_score: usize = 1;

    for (0..start_pos.items.len) |cur_pos| {
        var i: usize = 0;
        var score: usize = 0;
        loop: while (true) {
            const left_right: Paths = paths.get(start_pos.items[cur_pos]).?;
            start_pos.items[cur_pos] = if (directions.items[i] == Direction.L) left_right.left else left_right.right;
            // std.debug.print("\n\n next path is: {s}", .{&start_pos.items[cur_pos]});
            score += 1;
            if (start_pos.items[cur_pos][2] == 'Z') {
                break :loop;
            } else {
                i += 1;
                if (i >= directions.items.len) {
                    i = 0;
                }
            }
        }
        lcm_score = if (lcm_score == 1) score else lcm(lcm_score, score);
    }
    return lcm_score;
}

pub fn lcm(lhs: usize, rhs: usize) usize {
    var left = lhs;
    var right = rhs;
    while (left != right) {
        if (left < right) {
            left += lhs;
        } else {
            right += rhs;
        }
    }
    return left;
}

test "p2" {
    const input =
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)    
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    try std.testing.expectEqual(part2(input, alloc), 6);
}
