const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var clientWriter = std.io.bufferedWriter(stdout_file);
    const stdout = clientWriter.writer();

    // Setting up our buffered writes for the client system
    try stdout.print("starting client.\n", .{});

    var args = std.process.args();

    // skip the execution name
    _ = args.next();

    // Arguments are as follows
    // <program name> client <serverIP> <serverPort>
    // <program name> server <serverPort>
    const srvtype = args.next() orelse "";
    if (std.mem.eql(u8, srvtype, "client")) {
        try stdout.print("received type client\n", .{});
    } else if (std.mem.eql(u8, srvtype, "server")) {
        try stdout.print("received type server\n", .{});
    } else {
        try stdout.print("First argument should be either 'client' or 'server', got '{s}'\n", .{srvtype});
    }

    try clientWriter.flush();
}
