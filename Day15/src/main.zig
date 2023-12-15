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

fn hash(init: u8, input: []const u8) u8 {
    var state: u16 = init;

    for (input) |chr| {
        state += chr;
        state *= 17;
        state %= 256;
    }
    //truncating should be lossless here since state is result of mod 256
    //and therefore in u8 range
    return @truncate(state);
}

fn part1(input: []const u8) usize {
    var score: usize = 0;

    const no_lf = std.mem.trimRight(u8, input, "\r\n");
    var instructions = std.mem.splitScalar(u8, no_lf, ',');
    while (instructions.next()) |ins| {
        score += hash(0, ins);
    }
    return score;
}

test "p1" {
    const input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
    const expected: usize = 1320;
    const actual: usize = part1(input);
    try std.testing.expectEqual(expected, actual);
}

fn part2(input: []const u8, alloc: std.mem.Allocator) usize {
    var score: usize = 0;

    var hashmap = [_]std.ArrayList([3]u8){std.ArrayList([3]u8).init(alloc)} ** 256;
    defer {
        for (hashmap) |map| {
            map.deinit();
        }
    }
    const no_lf = std.mem.trimRight(u8, input, "\r\n");
    var instructions = std.mem.splitScalar(u8, no_lf, ',');
    while (instructions.next()) |ins| {
        const box = hash(0, ins[0..2]);
        // std.debug.print("\nhash: {}", .{box});
        if (ins[2] == '=') {
            //check if label already in box
            find: for (0..hashmap[box].items.len) |idx| {
                if (std.mem.eql(u8, hashmap[box].items[idx][0..2], ins[0..2])) {
                    std.debug.print("\n{any}   {}", .{ hashmap[box].items, ins[3] });
                    hashmap[box].items[idx][2] = ins[3];
                    std.debug.print("\n{any}", .{hashmap[box].items});
                    break :find;
                }
            } else {
                hashmap[box].append(.{ ins[0], ins[1], ins[3] }) catch unreachable;
            }
        } else {
            find: for (0..hashmap[box].items.len) |idx| {
                if (std.mem.eql(u8, hashmap[box].items[idx][0..2], ins[0..2])) {
                    // std.debug.print("\n{any}", .{hashmap[box].items});
                    _ = hashmap[box].orderedRemove(idx);
                    // std.debug.print("\n{any}", .{hashmap[box].items});
                    break :find;
                }
            }
        }
    }

    for (hashmap, 1..) |box, boxnr| {
        for (box.items, 1..) |item, slot| {
            std.debug.print("\nitem: {s} slot:{} box: {}", .{ item, slot, boxnr });
            score += (item[2] - '0') * slot * boxnr;
        }
    }

    return score;
}

test "p2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
    const expected: usize = 145;
    const actual: usize = part2(input, alloc);
    try std.testing.expectEqual(expected, actual);
}
