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
    std.debug.print("\n|||part 2: {}", .{part2(buffer.items, alloc)});
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
            // std.debug.print("hor score: {}\n", .{num});
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
                // std.debug.print("vert score: {}\n", .{num});
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

fn find_differences(lhs: []u8, rhs: []u8) ?usize {
    if (lhs.len == 0 or lhs.len != rhs.len) {
        return null;
    }
    var differences: usize = 0;
    for (0..rhs.len) |idx| {
        if (lhs[idx] != rhs[idx]) {
            differences += 1;
        }
    }
    return differences;
}

fn findDifferencesCol(slice: []u8, col1: usize, col2: usize, line_len: usize, num_of_lines: usize) ?usize {
    if (slice.len == 0) {
        return null;
    }
    var differences: usize = 0;
    var left_col: usize = col1;
    var right_col: usize = col2;
    for (0..num_of_lines) |_| {
        if (slice[left_col] != slice[right_col]) {
            differences += 1;
        }
        left_col += line_len;
        right_col += line_len;
    }
    return differences;
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
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
            var diffs_found = find_differences(list.items[first..second], list.items[second..last]).?;
            if (diffs_found <= 1) {
                var begin: usize = line_idx;
                var end: usize = line_idx + 1;

                while (begin > 0 and end < num_of_lines - 1) {
                    const begins = (begin - 1) * line_len;
                    const ends = (end + 1) * line_len;
                    diffs_found += find_differences(list.items[begins .. begins + line_len], list.items[ends .. ends + line_len]).?;
                    if (diffs_found > 1) {
                        continue :hor;
                    }
                    begin -= 1;
                    end += 1;
                } else {
                    if (diffs_found == 1) {
                        break :hor line_idx;
                    } else {
                        continue :hor;
                    }
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
                var diffs = findDifferencesCol(list.items, col_idx, col_idx + 1, line_len, num_of_lines).?;
                if (diffs <= 1) {
                    var begin: usize = col_idx;
                    var end: usize = col_idx + 1;
                    while (begin > 0 and end < line_len - 1) {
                        diffs += findDifferencesCol(list.items, begin - 1, end + 1, line_len, num_of_lines).?;
                        if (diffs > 1) {
                            continue :ver;
                        }
                        begin -= 1;
                        end += 1;
                    } else {
                        if (diffs == 1) {
                            break :ver col_idx;
                        } else {
                            break :ver null;
                        }
                    }
                } else {
                    continue :ver;
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
    std.debug.print("\ntest123", .{});
    return score;
}

test "p2" {
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

    const expected: usize = 400;
    const actual: usize = part2(input, alloc);

    try std.testing.expectEqual(expected, actual);
}
