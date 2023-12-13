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

const Mirrorline = union(enum) {
    Between: usize,
    On: usize,
};

fn part1(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    score += 0;
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    var blocks = std.mem.splitSequence(u8, input, "\n\n");

    while (blocks.next()) |block| {
        //ignore empty blocks
        if (block.len == 0) {
            continue;
        }
        var lines = std.mem.splitScalar(u8, input, '\n');
        const line_len = lines.peek().?.len;
        //clear list
        list.clearRetainingCapacity();

        while (lines.next()) |line| {
            list.appendSlice(line) catch unreachable;
        }
        const num_of_lines: usize = lines.items.len / line_len;
        //first check for horizontal line

        const mirror: ?Mirrorline = horizontal: for (0..num_of_lines - 2) |line| {
            const begin_first: usize = line * line_len;
            const begin_second: usize = begin_first + line_len;
            const begin_third: usize = begin_second + line_len;
            const begin_fourth: usize = begin_third + line_len;
            //Check if Mirrorline is between current line and next or on next line
            if (std.mem.eql(u8, list.items[begin_first..begin_second], list.items[begin_second..begin_third])) {
                break :horizontal Mirrorline{ .Between = line };
            } else if (std.mem.eql(u8, list.items[begin_first..begin_second], list.items[begin_third..begin_fourth])) {
                break :horizontal Mirrorline{ .On = line };
            }
        } else {
            //loop ignore mirrorline between last two, to avoid extra bound check
            //In case no Mirrorline has been found yet, it has to be checked now
            const begin_last: usize = list.led - line_len;
            const begin_before_last: usize = begin_last - line_len;
            if (std.mem.eql(u8, list.items[begin_before_last..begin_last], list.items[begin_last..])) {
                break :horizontal Mirrorline{ .Between = list.len - 1 };
            } else {
                break :horizontal null;
            }
        };
        //check if horizontal mirroline was found to evaluate score
        if (mirror != null) {}
    }

    return score;
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;
    _ = input;
    _ = alloc;
    score += 0;

    return score;
}
