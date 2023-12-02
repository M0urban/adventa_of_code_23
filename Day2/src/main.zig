const std = @import("std");

pub fn main() !void {
    var handle = try std.fs.cwd().openFile("src/input.txt", .{});
    defer handle.close();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var buffered = std.io.bufferedReader(handle.reader());
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();
    var reader = buffered.reader();

    try reader.readAllArrayList(&buffer, std.math.maxInt(usize));
    std.debug.print("\nhello world", .{});
    std.debug.print("\npart 1: {}", .{part1(buffer.items)});
}

fn part1(input: []u8) usize {
    var lines = std.mem.splitAny(u8, input, "\n");
    var score: usize = 0;
    var idx: usize = 1;
    while (lines.next()) |line| : (idx += 1) {
        if (line.len != 0) {
            const after_header = std.mem.indexOf(u8, line, ": ").? + 2;
            var games = std.mem.splitSequence(u8, line[after_header..], "; ");
            var green: usize = 0;
            var red: usize = 0;
            var blue: usize = 0;
            while (games.next()) |game| {
                var colors = std.mem.splitSequence(u8, game, ", ");
                while (colors.next()) |color| {
                    const space = std.mem.indexOf(u8, color, " ").?;
                    const num = std.fmt.parseInt(usize, color[0..space], 10) catch unreachable;
                    switch (color[space + 1]) {
                        'b' => {
                            if (blue < num) {
                                blue = num;
                            }
                        },
                        'r' => {
                            if (red < num) {
                                red = num;
                            }
                        },
                        'g' => {
                            if (green < num) {
                                green = num;
                            }
                        },
                        else => {
                            unreachable;
                        },
                    }
                }
            }
            if (red <= 12 and green <= 13 and blue <= 14) {
                score += idx;
            }
        }
    }
    return score;
}
