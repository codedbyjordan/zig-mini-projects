const std = @import("std");

fn drawPixel(r: u32, g: u32, b: u32) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1b[48;2;{d};{d};{d}m  \x1b[0m", .{ r, g, b });
}

const PPMVersion = enum { p3, p6 };

const PPMHeader = struct {
    version: PPMVersion,
    max_color_value: u32,
    width: u32,
    height: u32,
};

pub fn main() !void {
    const stdout_writer = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_writer);
    const stdout = bw.writer();

    var args_iter = std.process.args();
    _ = args_iter.skip(); // ignore program name

    const file_path = args_iter.next();
    if (file_path) |fp| {
        var file = std.fs.cwd().openFile(fp, .{}) catch |err| switch (err) {
            error.FileNotFound => {
                try stdout.print("File not found\n", .{});
                try bw.flush();
                std.process.exit(0);
            },
            else => {
                try stdout.print("Error opening file\n", .{});
                try bw.flush();
                std.process.exit(0);
            },
        };
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [128]u8 = undefined;
        var header = try readPpmHeader(&in_stream, &buf);

        switch (header.version) {
            .p3 => try drawPpmV3(&in_stream, &buf, &header),
            .p6 => try drawPpmV6(&in_stream, &buf, &header),
        }
    } else {
        try stdout.print("Usage: ppm-monkey [file_path]\n", .{});
    }

    try bw.flush();
}

fn readPpmHeader(reader: anytype, buf: *[128]u8) !PPMHeader {
    var header = PPMHeader{
        .version = .p3,
        .width = 0,
        .height = 0,
        .max_color_value = 0,
    };

    var values_read: u8 = 0;
    while (values_read < 3) {
        const line_buf = try reader.readUntilDelimiterOrEof(buf, '\n') orelse break;
        const line = std.mem.trim(u8, line_buf, &std.ascii.whitespace);

        if (line.len == 0 or line[0] == '#') continue;

        var tokens = std.mem.tokenizeAny(u8, line, &std.ascii.whitespace);
        while (tokens.next()) |token| {
            if (token.len == 0 or token[0] == '#') continue;

            if (values_read == 0 and (std.mem.eql(u8, token, "P3") or std.mem.eql(u8, token, "P6"))) {
                header.version = if (token[1] == '3') .p3 else .p6;
                continue;
            }

            const val = try std.fmt.parseUnsigned(u32, token, 10);
            switch (values_read) {
                0 => header.width = val,
                1 => header.height = val,
                2 => header.max_color_value = val,
                else => break,
            }

            values_read += 1;
            if (values_read == 3) break;
        }
    }

    return header;
}

fn drawPpmV3(reader: anytype, buf: *[128]u8, ppmHeader: *PPMHeader) !void {
    var y: u32 = 0;
    while (y < ppmHeader.height) : (y += 1) {
        var x: u32 = 0;
        var tokenized_line: ?std.mem.TokenIterator(u8, .any) = null;

        while (x < ppmHeader.width) {
            if (tokenized_line == null or tokenized_line.?.peek() == null) {
                const line = try reader.readUntilDelimiter(buf, '\n');
                if (line[0] == '#') continue;
                const trimmed_line = std.mem.trimLeft(u8, line, "\t");
                tokenized_line = std.mem.tokenizeAny(u8, trimmed_line, " ");
            }

            const r = try std.fmt.parseInt(u32, tokenized_line.?.next() orelse return error.InvalidFormat, 10);
            const g = try std.fmt.parseInt(u32, tokenized_line.?.next() orelse return error.InvalidFormat, 10);
            const b = try std.fmt.parseInt(u32, tokenized_line.?.next() orelse return error.InvalidFormat, 10);

            try drawPixel(r, g, b);

            x += 1;
        }
        std.debug.print("\n", .{});
    }
}

fn drawPpmV6(reader: anytype, buf: *[128]u8, ppmHeader: *PPMHeader) !void {
    var y: u32 = 0;
    while (y < ppmHeader.height) : (y += 1) {
        var x: u32 = 0;
        while (x < ppmHeader.width) : (x += 1) {
            // Read 3 bytes directly into the buffer
            const bytesRead = try reader.*.readAll(buf[0..3]);
            if (bytesRead != 3) return error.UnexpectedEOF;

            // Extract RGB values
            const r = buf[0];
            const g = buf[1];
            const b = buf[2];

            try drawPixel(r, g, b);
        }
        std.debug.print("\n", .{});
    }
}
