const std = @import("std");

const SrvArgs = struct {
    srvType: []const u8 = "",
    address: []const u8 = "",
    port: []const u8 = "",

    pub fn isClient(self: SrvArgs) bool {
        return std.mem.eql(u8, self.srvType, "client");
    }

    pub fn isServer(self: SrvArgs) bool {
        return std.mem.eql(u8, self.srvType, "server");
    }
};

pub fn client(address: []const u8, port: u16) !void {
    const peer = try std.net.Address.parseIp4(address, port);
    const stream = try std.net.tcpConnectToAddress(peer);
    defer stream.close();

    const data = "test message\n";
    var writer = stream.writer();
    _ = try writer.write(data);
}

pub fn server(port: u16) !void {
    const loopback = try std.net.Ip4Address.parse("127.0.0.1", port);
    const localhost = std.net.Address{ .in = loopback };
    var srv = try localhost.listen(.{
        .reuse_port = true,
    });
    defer srv.deinit();

    var conn = try srv.accept();
    defer conn.stream.close();

    std.debug.print("Connection received! {} is sending data.\n", .{conn.address});

    var buff: [1024]u8 = undefined;
    const size = try conn.stream.reader().readAll(&buff);

    std.debug.print("{} says {s}\n", .{ conn.address, buff[0..size] });
}

pub fn argParser() SrvArgs {
    var args = std.process.args();
    // skip program name for args list
    _ = args.next();

    // order matters, goes name, port, address
    const argS = SrvArgs{
        .srvType = args.next() orelse "",
        .port = args.next() orelse "",
        .address = args.next() orelse "",
    };

    return argS;
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var clientWriter = std.io.bufferedWriter(stdout_file);
    const stdout = clientWriter.writer();

    // Setting up our buffered writes for the client system
    try stdout.print("starting client/server system.\n", .{});

    // Arguments are as follows
    // <program name> client <serverPort> <serverIP>
    // <program name> server <serverPort>
    const srvArgs = argParser();

    if (srvArgs.isClient()) {
        try stdout.print("received type client\n", .{});
        const port = try std.fmt.parseInt(u16, srvArgs.port, 10);

        try client(srvArgs.address, port);
    } else if (srvArgs.isServer()) {
        try stdout.print("received type server\n", .{});
        const port = try std.fmt.parseInt(u16, srvArgs.port, 10);

        try server(port);
    } else {
        try stdout.print("First argument should be either 'client' or 'server', got '{s}'\n", .{srvArgs.srvType});
        std.log.err("Invalid type passed {s}\n", .{srvArgs.srvType});
        return;
    }

    try clientWriter.flush();
}
