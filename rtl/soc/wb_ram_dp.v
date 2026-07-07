`timescale 1ns/1ps

module wb_ram_dp #(
    parameter ADDR_WIDTH = 14,              // 2^14 words = 64KB
    parameter INIT_FILE  = ""
)(
    input  wire        clk,
    input  wire        reset,

    // Instruction Wishbone port
    input  wire        i_cyc,
    input  wire        i_stb,
    input  wire        i_we,
    input  wire [29:0] i_adr,
    input  wire [31:0] i_dat_w,
    input  wire [3:0]  i_sel,
    output reg  [31:0] i_dat_r,
    output reg         i_ack,
    output wire        i_err,

    // Data Wishbone port
    input  wire        d_cyc,
    input  wire        d_stb,
    input  wire        d_we,
    input  wire [29:0] d_adr,
    input  wire [31:0] d_dat_w,
    input  wire [3:0]  d_sel,
    output reg  [31:0] d_dat_r,
    output reg         d_ack,
    output wire        d_err
);

    localparam WORDS = (1 << ADDR_WIDTH);

    reg [31:0] mem [0:WORDS-1];

    wire [ADDR_WIDTH-1:0] i_addr = i_adr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] d_addr = d_adr[ADDR_WIDTH-1:0];

    integer k;

    initial begin
        for (k = 0; k < WORDS; k = k + 1)
            mem[k] = 32'h00000013;   // RISC-V NOP

        if (INIT_FILE != "") begin
            $display("[RAM] loading %s", INIT_FILE);
            $readmemh(INIT_FILE, mem);
        end
    end

    assign i_err = 1'b0;
    assign d_err = 1'b0;

    // Instruction port
    always @(posedge clk) begin
        if (reset) begin
            i_ack   <= 1'b0;
            i_dat_r <= 32'd0;
        end else begin
            i_ack <= i_cyc & i_stb & ~i_ack;

            if (i_cyc & i_stb & ~i_ack) begin
                i_dat_r <= mem[i_addr];

                if (i_we) begin
                    if (i_sel[0]) mem[i_addr][7:0]   <= i_dat_w[7:0];
                    if (i_sel[1]) mem[i_addr][15:8]  <= i_dat_w[15:8];
                    if (i_sel[2]) mem[i_addr][23:16] <= i_dat_w[23:16];
                    if (i_sel[3]) mem[i_addr][31:24] <= i_dat_w[31:24];
                end
            end
        end
    end

    // Data port
    always @(posedge clk) begin
        if (reset) begin
            d_ack   <= 1'b0;
            d_dat_r <= 32'd0;
        end else begin
            d_ack <= d_cyc & d_stb & ~d_ack;

            if (d_cyc & d_stb & ~d_ack) begin
                d_dat_r <= mem[d_addr];

                if (d_we) begin
                    if (d_sel[0]) mem[d_addr][7:0]   <= d_dat_w[7:0];
                    if (d_sel[1]) mem[d_addr][15:8]  <= d_dat_w[15:8];
                    if (d_sel[2]) mem[d_addr][23:16] <= d_dat_w[23:16];
                    if (d_sel[3]) mem[d_addr][31:24] <= d_dat_w[31:24];
                end
            end
        end
    end

endmodule