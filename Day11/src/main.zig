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
    std.debug.print("\npart 1: {}", .{part1(buffer.items, alloc, 2)});
    std.debug.print("\npart 2: {}", .{part1(buffer.items, alloc, 1_000_000)});
}

const Coordinate = struct {
    x: usize,
    y: usize,
};

fn part1(input: []const u8, alloc: std.mem.Allocator, expansion_factor: usize) usize {
    var score: usize = 0;
    var galaxies = std.ArrayList(Coordinate).init(alloc);
    defer galaxies.deinit();
    var empty_lines = std.ArrayList(bool).init(alloc);
    defer empty_lines.deinit();
    var empty_columns = std.ArrayList(bool).init(alloc);
    defer empty_columns.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    //SEt all columns to empty and eliminate later
    empty_columns.appendNTimes(true, lines.peek().?.len) catch unreachable;

    //parse all lines
    //Add coordinates of all galaxies
    //eliminate non-empty columns
    //Add wether row is non empty
    while (lines.next()) |line| {
        if (line.len != 0) {
            var all_empty = true;
            for (line, 0..) |tile, col| {
                if (tile == '#') {
                    all_empty = false;
                    empty_columns.items[col] = false;
                    galaxies.append(Coordinate{ .x = col, .y = empty_lines.items.len }) catch unreachable;
                }
            }
            empty_lines.append(all_empty) catch unreachable;
        }
    }
    // std.debug.print("\ncol: {any}\nlin: {any}\n num of galaxies {}", .{ empty_columns.items, empty_lines.items, galaxies.items.len });

    //check all distances between all galaxy pairs
    for (galaxies.items[0 .. galaxies.items.len - 1], 1..) |galaxy1, idx| {
        for (galaxies.items[idx..], idx + 1..) |galaxy2, idx2| {
            _ = idx2;
            var temp_score: usize = 0;
            //check x distance in original + how many spaces need to be doubled
            if (galaxy2.x >= galaxy1.x) {
                temp_score += galaxy2.x - galaxy1.x;
                temp_score += (expansion_factor - 1) * std.mem.count(bool, empty_columns.items[galaxy1.x..galaxy2.x], &[_]bool{true});
            } else {
                temp_score += galaxy1.x - galaxy2.x +
                    (expansion_factor - 1) * std.mem.count(bool, empty_columns.items[galaxy2.x..galaxy1.x], &[_]bool{true});
            }
            // std.debug.print("\nt1:{}  ", .{temp_score});
            //for y direction due to insertion order galaxy2.y >= galaxy1.y
            temp_score += galaxy2.y - galaxy1.y;
            // std.debug.print("t2:{}  ", .{temp_score});
            temp_score += (expansion_factor - 1) * std.mem.count(bool, empty_lines.items[galaxy1.y..galaxy2.y], &[_]bool{true});
            // std.debug.print("t3:{}  ", .{temp_score});

            // std.debug.print("{}: {} ||| {}: {} = {}", .{ idx, galaxy1, idx2, galaxy2, temp_score });
            score += temp_score;
        }
    }

    return score;
}

test "p1" {
    const input =
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const expected: usize = 374;
    const actual: usize = part1(input, alloc, 2);
    try std.testing.expectEqual(expected, actual);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    var galaxies = std.ArrayList(Coordinate).init(alloc);
    defer galaxies.deinit();
    var empty_lines = std.ArrayList(bool).init(alloc);
    defer empty_lines.deinit();
    var empty_columns = std.ArrayList(bool).init(alloc);
    defer empty_columns.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    //SEt all columns to empty and eliminate later
    empty_columns.appendNTimes(true, lines.peek().?.len) catch unreachable;

    //parse all lines
    //Add coordinates of all galaxies
    //eliminate non-empty columns
    //Add wether row is non empty
    while (lines.next()) |line| {
        if (line.len != 0) {
            var all_empty = true;
            for (line, 0..) |tile, col| {
                if (tile == '#') {
                    all_empty = false;
                    empty_columns.items[col] = false;
                    galaxies.append(Coordinate{ .x = col, .y = empty_lines.items.len }) catch unreachable;
                }
            }
            empty_lines.append(all_empty) catch unreachable;
        }
    }
    // std.debug.print("\ncol: {any}\nlin: {any}\n num of galaxies {}", .{ empty_columns.items, empty_lines.items, galaxies.items.len });

    //check all distances between all galaxy pairs
    for (galaxies.items[0 .. galaxies.items.len - 1], 1..) |galaxy1, idx| {
        for (galaxies.items[idx..], idx + 1..) |galaxy2, idx2| {
            _ = idx2;
            var temp_score: usize = 0;
            //check x distance in original + how many spaces need to be doubled
            if (galaxy2.x >= galaxy1.x) {
                temp_score += galaxy2.x - galaxy1.x;
                temp_score += 1_000_000 * std.mem.count(bool, empty_columns.items[galaxy1.x..galaxy2.x], &[_]bool{true});
            } else {
                temp_score += galaxy1.x - galaxy2.x +
                    1_000_000 * std.mem.count(bool, empty_columns.items[galaxy2.x..galaxy1.x], &[_]bool{true});
            }
            // std.debug.print("\nt1:{}  ", .{temp_score});
            //for y direction due to insertion order galaxy2.y >= galaxy1.y
            temp_score += galaxy2.y - galaxy1.y;
            // std.debug.print("t2:{}  ", .{temp_score});
            temp_score += 1_000_000 * std.mem.count(bool, empty_lines.items[galaxy1.y..galaxy2.y], &[_]bool{true});
            // std.debug.print("t3:{}  ", .{temp_score});

            // std.debug.print("{}: {} ||| {}: {} = {}", .{ idx, galaxy1, idx2, galaxy2, temp_score });
            score += temp_score;
        }
    }

    return score;
}
