const std = @import("std");
const mem = @import("std.mem");

pub fn main() !void {
    //prepare general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
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
    std.debug.print("\npart 1: {}", .{part1(buffer.items, &allocator)});
    std.debug.print("\npart 2: {}", .{part2(buffer.items, &allocator)});
}

fn part1(input: []u8, allocator: *std.mem.Allocator) usize {
    var score: usize = 0;
    var lines = std.mem.splitAny(u8, input, "\n");
    var my_numbers = std.ArrayList(usize).init(allocator.*);
    defer my_numbers.deinit();
    var winning_numbers = std.ArrayList(usize).init(allocator.*);
    defer winning_numbers.deinit();
    while (lines.next()) |line| {
        if (line.len != 0) {
            my_numbers.clearRetainingCapacity();
            winning_numbers.clearRetainingCapacity();
            const start_of_card: usize = std.mem.lastIndexOf(u8, line, ": ").? + 1;
            const only_numbers = line[start_of_card..];
            var both = std.mem.splitSequence(u8, only_numbers, " | ");
            const left = both.next().?;
            const right = both.next().?;
            var left_num = std.mem.splitScalar(u8, left, ' ');
            while (left_num.next()) |num| {
                if (num.len != 0) {
                    const parsed = std.fmt.parseUnsigned(usize, num, 10) catch {
                        std.debug.print("\n\n||{any}||", .{num});
                        unreachable;
                    };
                    my_numbers.append(parsed) catch unreachable;
                }
            }
            var right_num = std.mem.splitScalar(u8, right, ' ');
            while (right_num.next()) |num| {
                if (num.len != 0) {
                    const parsed = std.fmt.parseUnsigned(usize, num, 10) catch {
                        std.debug.print("\n\n||{any}||", .{num});
                        unreachable;
                    };
                    winning_numbers.append(parsed) catch unreachable;
                }
            }
            var card_score: ?usize = null;
            for (winning_numbers.items) |win| {
                if (std.mem.indexOfScalar(usize, my_numbers.items, win)) |_| {
                    if (card_score) |cur| {
                        card_score = 2 * cur;
                    } else {
                        card_score = 1;
                    }
                }
            }
            std.debug.print("found {any}", .{card_score});
            score += if (card_score) |num| num else 0;
        }
    }
    return score;
}

test "part1" {
    var input =
        \\ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.testing.expectEqual(13, part1(input[0..input.len], allocator));
}

fn part2(input: []u8, allocator: *std.mem.Allocator) usize {
    var score: usize = 0;
    var lines = std.mem.splitAny(u8, input, "\n");
    var my_numbers = std.ArrayList(usize).init(allocator.*);
    defer my_numbers.deinit();
    var winning_numbers = std.ArrayList(usize).init(allocator.*);
    defer winning_numbers.deinit();

    var num_of_cards: ?std.ArrayList(usize) = null;

    while (lines.next()) |line| {
        if (line.len != 0) {
            my_numbers.clearRetainingCapacity();
            winning_numbers.clearRetainingCapacity();
            const start_of_card: usize = std.mem.lastIndexOf(u8, line, ": ").? + 1;
            const only_numbers = line[start_of_card..];
            var both = std.mem.splitSequence(u8, only_numbers, " | ");
            const left = both.next().?;
            const right = both.next().?;
            var left_num = std.mem.splitScalar(u8, left, ' ');
            while (left_num.next()) |num| {
                if (num.len != 0) {
                    const parsed = std.fmt.parseUnsigned(usize, num, 10) catch {
                        std.debug.print("\n\n||{any}||", .{num});
                        unreachable;
                    };
                    my_numbers.append(parsed) catch unreachable;
                }
            }
            var right_num = std.mem.splitScalar(u8, right, ' ');
            while (right_num.next()) |num| {
                if (num.len != 0) {
                    const parsed = std.fmt.parseUnsigned(usize, num, 10) catch {
                        std.debug.print("\n\n||{any}||", .{num});
                        unreachable;
                    };
                    winning_numbers.append(parsed) catch unreachable;
                }
            }

            var card_score: usize = 0;
            for (winning_numbers.items) |win| {
                if (std.mem.indexOfScalar(usize, my_numbers.items, win)) |_| {
                    card_score += 1;
                }
            }

            if (num_of_cards) |nums| {
                score += nums.items[0];
                nums.items[0] = 1;
            } else {
                //init arraylist with zero
                num_of_cards = std.ArrayList(usize).init(allocator.*);
                num_of_cards.?.appendNTimes(1, winning_numbers.items.len) catch unreachable;

                //update score
                score += 1;
            }

            if (num_of_cards) |nums| {
                std.mem.rotate(usize, nums.items, 1);
                for (0..card_score) |item| {
                    nums.items[item] += card_score + 1;
                }
            }
        }
    }
    return score;
}

test "part2" {
    var input =
        \\         Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11    
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.testing.expectEqual(30, part2(input[0..input.len], allocator));
}
