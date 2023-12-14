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
    std.debug.assert(input.len % line_len_lf == 0);
    const line_len = line_len_lf - 1;
    const line_ammount = (input.len / line_len_lf);
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
        \\
    ;
    const expected: usize = 136;
    const actual: usize = part1(input);
    try std.testing.expectEqual(expected, actual);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    var inputCpy = std.ArrayList(u8).init(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    const line_len = lines.peek().?.len;
    var line_ammount = 0;
    while(lines.next()) |line| {
        if(line.len != 0) {
            inputCpy.appendSlice(line) catch unreachable;
            line_ammount += 1;
        }
    }

    //varibles to keep track of last four board hashes
    //when comparing the first and having 4 or more equala in a row
    //we can assume there is a loop and the current board is the final
    var last_four = [4]u64 {0} ** 4;
    var consecutive_equals: u8 = 0;
    var index_last_four = 0;

    //here make loop moving, hashing, compare hashes until we are after north tilt and have a cycle
    while(){}

    return score;
}

pub fn hash(input: []const u8) u64 { 
     var hasher = std.hash.XxHash64.init(0); 
     hasher.update(input); 
     return hasher.final(); 
 }

fn moveX(comptime west_direction: bool, input: []u8, line_len: usize, line_ammount: usize) void {
    //ascending means in this context that O will go to the right(positive x) and . to the left desc is the opposite
    const sortFun = if(west_direction) std.sort.asc(u8) else std.sort.desc();
    for(0..line_ammount) |line| {
        const line_start = line * line_ammount;
        var fields = std.mem.splitAny(u8, input[line_start..line_start + line_len], '#');
        while(fields.next()) |field| {
            std.mem.sort(u8, field, .{}, sortFun);
        }
    }
}

fn moveY(north_direction: bool, input: []u8, line_len: usize, line_ammount: usize) void {
    for (0..line_len) |col| {
        var movable: usize = 0;
        var start: usize = 0;
        var line_idx: usize = 0;
        while (line_idx < line_ammount) : (line_idx += 1) {
            switch (input[line_idx * line_len + col]) {
                '.' => {},
                'O' => {
                    movable += 1;
                },
                '#' => {
                    if (movable != 0) {
                        for(0..line_idx - start) |idx| {
                            if((north_direction and idx < movable) or (!north_direction and line_idx - idx <= movable)) {
                                input[(start + idx) * line_len + col] = 'O';
                            } else {
                                input[(start + idx) * line_len + col] = '.';
                            }
                        }
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
            for(0..line_idx - start) |idx| {
                if((north_direction and idx < movable) or (!north_direction and line_idx - idx <= movable)) {
                    input[(start + idx) * line_len + col] = 'O';
                } else {
                    input[(start + idx) * line_len + col] = '.';
                }
            }
            movable = 0;
        }
    }
}

