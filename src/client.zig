const std = @import("std");

pub fn client(address: []const u8, port: u16) !void {
    const peer = try std.net.Address.parseIp4(address, port);
    const stream = try std.net.tcpConnectToAddress(peer);
    defer stream.close();

    const data = "test message\n";
    var writer = stream.writer();
    _ = try writer.write(data);
}

pub fn server(port: u16) !void {
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
        const port = try std.fmt.parseInt(u16, portStr, 10);

        try client(address, port);
    } else if (std.mem.eql(u8, srvtype, "server")) {
        try stdout.print("received type server\n", .{});
        const portStr = args.next() orelse "0";
        const port = try std.fmt.parseInt(u16, portStr, 10);

        try server(port);
    } else {
        try stdout.print("First argument should be either 'client' or 'server', got '{s}'\n", .{srvtype});
        std.log.err("Invalid type passed {s}\n", .{srvtype});
        return;
    }

    try clientWriter.flush();
}
