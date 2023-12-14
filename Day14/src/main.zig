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

fn sumOfRange(first: usize, last: usize) usize {
    var sum: usize = 0;
    var i = first;
    while (i <= last) : (i += 1) {
        sum += i;
    }
    return sum;
}

fn part1(input: []const u8) usize {
    var score: usize = 0;

    const line_len_lf = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    std.io.getStdOut().writer().print("\ninput_len: {}, line_len: {}", .{ input.len, line_len_lf }) catch unreachable;
    std.debug.assert(input.len % line_len_lf == line_len_lf - 1);
    const line_len = line_len_lf - 1;
    const line_ammount = (input.len / line_len_lf) + 1;
    for (0..line_len) |col| {
        var movable: usize = 0;
        var start: usize = 0;
        var line_idx: usize = 0;
        while (line_idx < line_ammount) : (line_idx += 1) {
            switch (input[line_idx * line_len_lf + col]) {
                '.' => {},
                'O' => {
                    movable += 1;
                },
                '#' => {
                    if (movable != 0) {
                        const group_score = sumOfRange(line_ammount - start - movable + 1, line_ammount - start);
                        score += group_score;
                        movable = 0;
                    }
                    start = line_idx + 1;
                },
                else => {
                    unreachable;
                },
            }
        }
        //check if there is one final group
        if (movable != 0) {
            const group_score = sumOfRange(line_ammount - start - movable + 1, line_ammount - start);
            score += group_score;
            movable = 0;
        }
    }

    return score;
}

test "p1" {
    const input =
        \\O....#....
        \\O.OO#....#
        \\.....##...
        \\OO.#O....O
        \\.O.....O#.
        \\O.#..O.#.#
        \\..O..#O..O
        \\.......O..
        \\#....###..
        \\#OO..#....
    ;
    const expected: usize = 136;
    const actual: usize = part1(input);
    try std.testing.expectEqual(expected, actual);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    _ = input;
    _ = alloc;
    score += 0;

    return score;
}
