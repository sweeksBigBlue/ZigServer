const std = @import("std");

pub fn client(address: []const u8, port: u32) !void {
    _ = address;
    _ = port;
}

pub fn server(port: u32) !void {
    _ = port;
}

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
        const address = args.next() orelse ""; // TODO: validate IP address string
        const portStr = args.next() orelse "0";
        const port = try std.fmt.parseInt(u32, portStr, 10);
        if (port < 1 or port > 65535) {
            std.log.err("Client: Port should be a number from 1 to 65535, got '{d}'\n", .{port});
            return;
        }

        try client(address, port);
    } else if (std.mem.eql(u8, srvtype, "server")) {
        try stdout.print("received type server\n", .{});
        const portStr = args.next() orelse "0";
        const port = try std.fmt.parseInt(u32, portStr, 10);
        if (port < 1 or port > 65535) {
            std.log.err("Server: Port should be a number from 1 to 65535, got '{d}'\n", .{port});
            return;
        }

        try server(port);
    } else {
        try stdout.print("First argument should be either 'client' or 'server', got '{s}'\n", .{srvtype});
        std.log.err("Invalid type passed {s}\n", .{srvtype});
        return;
    }

    try clientWriter.flush();
}
