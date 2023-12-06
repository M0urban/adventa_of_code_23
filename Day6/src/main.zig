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

fn part1(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 1;
    var lines = std.mem.splitAny(u8, input, "\n");
    var duration = lines.next().?;
    var distance = lines.next().?;

    //find first difit of
    var after_header = std.mem.indexOfAny(u8, duration, "0123456789").?;
    var list_of_durations = std.ArrayList(usize).init(alloc);
    defer list_of_durations.deinit();
    var numbers = std.mem.splitScalar(u8, duration[after_header..], ' ');
    while (numbers.next()) |num| {
        if (num.len != 0) {
            const parsed = std.fmt.parseUnsigned(usize, num, 10) catch unreachable;
            list_of_durations.append(parsed) catch unreachable;
        }
    }
    //find distances
    after_header = std.mem.indexOfAny(u8, distance, "0123456789").?;
    var list_of_distances = std.ArrayList(usize).init(alloc);
    defer list_of_distances.deinit();
    numbers = std.mem.splitScalar(u8, distance[after_header..], ' ');
    while (numbers.next()) |num| {
        if (num.len != 0) {
            const parsed = std.fmt.parseUnsigned(usize, num, 10) catch unreachable;
            list_of_distances.append(parsed) catch unreachable;
        }
    }
    std.debug.print("\ntimes:    {any}\ndistances:{any}", .{ list_of_durations.items, list_of_distances.items });
    for (0..list_of_durations.items.len) |idx| {
        const cur_rec = list_of_distances.items[idx];
        const cur_duration = list_of_durations.items[idx];
        for (0..cur_rec) |charge_time| {
            if (charge_time * (cur_duration - charge_time) > cur_rec) {
                const winners = (cur_duration + 1) - 2 * (charge_time);
                score *= winners;
                std.debug.print("\n\n{any}", .{winners});
                break;
            }
        }
    }

    return score;
}

test "p1" {
    const map =
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const actual: usize = part1(map, allocator);
    const expected: usize = 288;
    try std.testing.expectEqual(expected, actual);
}

fn part2(input: []u8) usize {
    _ = input;
    const score: usize = 0;

    return score;
}
