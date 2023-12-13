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
    var score: usize = 0;
    score += 0;
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    var blocks = std.mem.splitSequence(u8, input, "\n\n");

    blocks: while (blocks.next()) |block| {
        if (block.len == 0) {
            continue :blocks;
        }

        list.clearRetainingCapacity();
        var lines = std.mem.splitScalar(u8, block, '\n');
        //get length of each block len
        const line_len = lines.peek().?.len;
        var num_of_lines: usize = 0;
        lines: while (lines.next()) |line| {
            if (line.len == 0) {
                continue :lines;
            }
            num_of_lines += 1;
            list.appendSlice(line) catch unreachable;
        }

        const horizontal_line: ?usize = hor: for (0..num_of_lines - 1) |line_idx| {
            const first = line_idx * line_len;
            const second = first + line_len;
            const last = second + line_len;
            if (std.mem.eql(u8, list.items[first..second], list.items[second..last])) {
                var begin: usize = line_idx;
                var end: usize = line_idx + 1;

                while (begin > 0 and end < num_of_lines - 1) {
                    const begins = (begin - 1) * line_len;
                    const ends = (end + 1) * line_len;
                    if (!std.mem.eql(u8, list.items[begins .. begins + line_len], list.items[ends .. ends + line_len])) {
                        continue :hor;
                    }
                    begin -= 1;
                    end += 1;
                } else {
                    break :hor line_idx;
                }
            }
        } else {
            break :hor null;
        };

        if (horizontal_line) |num| {
            std.debug.print("hor score: {}\n", .{num});
            score += (num + 1) * 100;
        } else {
            const vertical_line: ?usize = ver: for (0..line_len - 1) |col_idx| {
                for (0..num_of_lines) |line| {
                    const first: usize = line * line_len + col_idx;
                    if (list.items[first] != list.items[first + 1]) {
                        continue :ver;
                    }
                } else {
                    var begin: usize = col_idx;
                    var end: usize = col_idx + 1;
                    while (begin > 0 and end < line_len - 1) {
                        for (0..num_of_lines) |line| {
                            const first: usize = line * line_len;
                            //if pair not equal try next pair
                            if (list.items[first + begin - 1] != list.items[first + end + 1]) {
                                continue :ver;
                            }
                        }
                        begin -= 1;
                        end += 1;
                    } else {
                        break :ver col_idx;
                    }
                }
            } else {
                break :ver null;
            };
            if (vertical_line) |num| {
                std.debug.print("vert score: {}\n", .{num});
                score += num + 1;
            }
        }
    }
    return score;
}

test "p1" {
    const input =
        \\#.##..##.
        \\..#.##.#.
        \\##......#
        \\##......#
        \\..#.##.#.
        \\..##..##.
        \\#.#.##.#.
        \\
        \\#...##..#
        \\#....#..#
        \\..##..###
        \\#####.##.
        \\#####.##.
        \\..##..###
        \\#....#..#
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const expected: usize = 405;
    const actual: usize = part1(input, alloc);

    try std.testing.expectEqual(expected, actual);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    _ = input;
    _ = alloc;
    score += 0;

    return score;
}
