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

    //create lists
    var groups = std.ArrayList(usize).init(alloc);
    defer groups.deinit();
    var unknowns = std.ArrayList(u8).init(alloc);
    defer unknowns.deinit();

    //first split lines
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        //ignore empty lines mostly because last line of itterator will be empty
        if (line.len == 0) {
            continue;
        }
        //clear arraylists at the beginning of each line
        groups.clearRetainingCapacity();
        unknowns.clearRetainingCapacity();

        var num_of_unknowns: usize = 0;

        //split line into the two parts
        var parts = std.mem.splitScalar(u8, line, ' ');
        const springs = parts.next().?;
        var groups_iter = std.mem.splitScalar(u8, parts.next().?, ',');
        while (groups_iter.next()) |num| {
            const parsed = std.fmt.parseUnsigned(usize, num, 10) catch {
                std.debug.print("parsing failed on {any}", .{num});
                unreachable;
            };
            groups.append(parsed) catch unreachable;
        }
        // std.debug.print("\n\nfor line:{s}\n groups are {any}", .{ line, groups.items });

        for (springs) |spring| {
            if (spring == '?') {
                num_of_unknowns += 1;
            }
        }

        // std.debug.print("\nnum of question marks: {}", .{num_of_unknowns});

        //check each configurations if it is valid
        line: for (0..std.math.pow(usize, 2, num_of_unknowns)) |config| {
            var idx: usize = 0;
            var conf = config;
            var start: ?usize = null;

            for (springs, 0..) |spring, c_idx| {
                //check if current spring is working or not
                if (spring == '.' or (spring == '?' and conf % 2 == 0)) {
                    //Further work only needed if the broken range ended here
                    if (start) |s_idx| {
                        if (idx < groups.items.len and groups.items[idx] == c_idx - s_idx) {
                            start = null;
                            idx += 1;
                        } else {
                            // std.debug.print("\ntriggered continue. items: {}, start: {}, end: {}", .{ groups.items[idx], s_idx, c_idx });
                            continue :line;
                        }
                    }
                } else {
                    //only action needed here is setting range start
                    if (start == null) {
                        start = c_idx;
                    }
                }
                if (spring == '?') {
                    conf = conf >> 1;
                }
            }
            //check if there is an open range left and all ranges are used
            if ((start == null and idx == groups.items.len) or (start != null and springs.len - start.? == groups.getLast() and idx == groups.items.len - 1)) {
                // std.debug.print("\nconfig: {}", .{config});
                score += 1;
            }
        }
    }

    return score;
}

test "p1" {
    const input =
        \\???.### 1,1,3
        \\.??..??...?##. 1,1,3
        \\?#?#?#?#?#?#?#? 1,3,1,6
        \\????.#...#... 4,1,1
        \\????.######..#####. 1,6,5
        \\?###???????? 3,2,1
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const expected: usize = 21;
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
