`timescale 1ns/1ps

module wb_decoder #(
    parameter [31:0] RAM_BASE = 32'h0000_0000,
    parameter [31:0] RAM_SIZE = 32'h0001_0000,

    parameter [31:0] CNN_BASE = 32'h4000_0000,
    parameter [31:0] CNN_SIZE = 32'h0000_0100
)(
    // CPU instruction bus
    input  wire        i_cyc,
    input  wire        i_stb,
    input  wire        i_we,
    input  wire [29:0] i_adr,
    input  wire [31:0] i_dat_w,
    input  wire [3:0]  i_sel,
    output wire [31:0] i_dat_r,
    output wire        i_ack,
    output wire        i_err,

    // CPU data bus
    input  wire        d_cyc,
    input  wire        d_stb,
    input  wire        d_we,
    input  wire [29:0] d_adr,
    input  wire [31:0] d_dat_w,
    input  wire [3:0]  d_sel,
    output wire [31:0] d_dat_r,
    output wire        d_ack,
    output wire        d_err,

    // RAM instruction port
    output wire        ram_i_cyc,
    output wire        ram_i_stb,
    output wire        ram_i_we,
    output wire [29:0] ram_i_adr,
    output wire [31:0] ram_i_dat_w,
    output wire [3:0]  ram_i_sel,
    input  wire [31:0] ram_i_dat_r,
    input  wire        ram_i_ack,
    input  wire        ram_i_err,

    // RAM data port
    output wire        ram_d_cyc,
    output wire        ram_d_stb,
    output wire        ram_d_we,
    output wire [29:0] ram_d_adr,
    output wire [31:0] ram_d_dat_w,
    output wire [3:0]  ram_d_sel,
    input  wire [31:0] ram_d_dat_r,
    input  wire        ram_d_ack,
    input  wire        ram_d_err,

    // CNN Wishbone slave
    output wire        cnn_cyc,
    output wire        cnn_stb,
    output wire        cnn_we,
    output wire [29:0] cnn_adr,
    output wire [31:0] cnn_dat_w,
    output wire [3:0]  cnn_sel,
    input  wire [31:0] cnn_dat_r,
    input  wire        cnn_ack,
    input  wire        cnn_err
);

    wire        i_req       = i_cyc & i_stb;
    wire        d_req       = d_cyc & d_stb;

    wire [31:0] i_byte_addr = {i_adr, 2'b00};
    wire [31:0] d_byte_addr = {d_adr, 2'b00};

    wire i_ram_sel = i_req &&
                     (i_byte_addr >= RAM_BASE) &&
                     (i_byte_addr <  RAM_BASE + RAM_SIZE);

    wire d_ram_sel = d_req &&
                     (d_byte_addr >= RAM_BASE) &&
                     (d_byte_addr <  RAM_BASE + RAM_SIZE);

    wire d_cnn_sel = d_req &&
                     (d_byte_addr >= CNN_BASE) &&
                     (d_byte_addr <  CNN_BASE + CNN_SIZE);

    wire i_unmapped = i_req & ~i_ram_sel;
    wire d_unmapped = d_req & ~d_ram_sel & ~d_cnn_sel;

    // iBus only goes to RAM
    assign ram_i_cyc   = i_cyc & i_ram_sel;
    assign ram_i_stb   = i_stb & i_ram_sel;
    assign ram_i_we    = i_we;
    assign ram_i_adr   = i_adr - RAM_BASE[31:2];
    assign ram_i_dat_w = i_dat_w;
    assign ram_i_sel   = i_sel;

    assign i_dat_r = i_ram_sel ? ram_i_dat_r : 32'h0000_0013;
    assign i_ack   = ram_i_ack | i_unmapped;
    assign i_err   = ram_i_err | i_unmapped;

    // dBus RAM
    assign ram_d_cyc   = d_cyc & d_ram_sel;
    assign ram_d_stb   = d_stb & d_ram_sel;
    assign ram_d_we    = d_we;
    assign ram_d_adr   = d_adr - RAM_BASE[31:2];
    assign ram_d_dat_w = d_dat_w;
    assign ram_d_sel   = d_sel;

    // dBus CNN
    assign cnn_cyc   = d_cyc & d_cnn_sel;
    assign cnn_stb   = d_stb & d_cnn_sel;
    assign cnn_we    = d_we;
    assign cnn_adr   = d_adr - CNN_BASE[31:2];
    assign cnn_dat_w = d_dat_w;
    assign cnn_sel   = d_sel;

    assign d_dat_r = d_ram_sel ? ram_d_dat_r :
                     d_cnn_sel ? cnn_dat_r   :
                                 32'hDEAD_BEEF;

    assign d_ack = ram_d_ack | cnn_ack | d_unmapped;
    assign d_err = ram_d_err | cnn_err | d_unmapped;

endmodule