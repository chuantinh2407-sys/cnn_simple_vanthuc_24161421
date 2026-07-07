`timescale 1ns/1ps

module wb_cnn_mini (
    input  wire        clk,
    input  wire        reset,

    // Wishbone slave
    input  wire        wb_cyc,
    input  wire        wb_stb,
    input  wire        wb_we,
    input  wire [29:0] wb_adr,
    input  wire [31:0] wb_dat_w,
    input  wire [3:0]  wb_sel,
    output reg  [31:0] wb_dat_r,
    output reg         wb_ack,
    output wire        wb_err
);

    assign wb_err = 1'b0;

    // Register word offsets
    localparam REG_CTRL         = 5'd0;  // 0x00
    localparam REG_STATUS       = 5'd1;  // 0x04
    localparam REG_INPUT_INDEX  = 5'd2;  // 0x08
    localparam REG_INPUT_DATA   = 5'd3;  // 0x0C
    localparam REG_KERNEL_INDEX = 5'd4;  // 0x10
    localparam REG_KERNEL_DATA  = 5'd5;  // 0x14
    localparam REG_OUTPUT_INDEX = 5'd6;  // 0x18
    localparam REG_OUTPUT_DATA  = 5'd7;  // 0x1C

    // 5x5 input image, signed 8-bit
    reg signed [7:0] input_mem [0:24];

    // 3x3 kernel, signed 8-bit
    reg signed [7:0] kernel_mem [0:8];

    // 3x3 output, signed 32-bit
    reg signed [31:0] output_mem [0:8];

    reg [4:0] input_index;
    reg [3:0] kernel_index;
    reg [3:0] output_index;

    reg done;
    reg busy;

    integer i;
    integer ox;
    integer oy;
    integer kx;
    integer ky;
    integer out_idx;
    integer in_idx;
    integer ker_idx;

    reg signed [31:0] acc;

    wire req = wb_cyc & wb_stb & ~wb_ack;

    task run_cnn;
        begin
            for (oy = 0; oy < 3; oy = oy + 1) begin
                for (ox = 0; ox < 3; ox = ox + 1) begin
                    acc = 32'sd0;

                    for (ky = 0; ky < 3; ky = ky + 1) begin
                        for (kx = 0; kx < 3; kx = kx + 1) begin
                            in_idx  = (oy + ky) * 5 + (ox + kx);
                            ker_idx = ky * 3 + kx;

                            acc = acc + input_mem[in_idx] * kernel_mem[ker_idx];
                        end
                    end

                    out_idx = oy * 3 + ox;

                    // ReLU
                    if (acc < 0)
                        output_mem[out_idx] <= 32'sd0;
                    else
                        output_mem[out_idx] <= acc;
                end
            end
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            wb_ack       <= 1'b0;
            wb_dat_r     <= 32'd0;

            input_index  <= 5'd0;
            kernel_index <= 4'd0;
            output_index <= 4'd0;

            done         <= 1'b0;
            busy         <= 1'b0;

            for (i = 0; i < 25; i = i + 1)
                input_mem[i] <= 8'sd0;

            for (i = 0; i < 9; i = i + 1)
                kernel_mem[i] <= 8'sd0;

            for (i = 0; i < 9; i = i + 1)
                output_mem[i] <= 32'sd0;

        end else begin
            wb_ack <= wb_cyc & wb_stb & ~wb_ack;

            if (req) begin
                if (wb_we) begin
                    case (wb_adr[4:0])

                        REG_CTRL: begin
                            // bit 1: clear done
                            if (wb_dat_w[1]) begin
                                done <= 1'b0;
                                busy <= 1'b0;
                            end

                            // bit 0: start
                            if (wb_dat_w[0]) begin
                                busy <= 1'b1;
                                done <= 1'b0;

                                run_cnn();

                                busy <= 1'b0;
                                done <= 1'b1;
                            end
                        end

                        REG_INPUT_INDEX: begin
                            if (wb_dat_w[4:0] < 25)
                                input_index <= wb_dat_w[4:0];
                        end

                        REG_INPUT_DATA: begin
                            if (input_index < 25)
                                input_mem[input_index] <= wb_dat_w[7:0];
                        end

                        REG_KERNEL_INDEX: begin
                            if (wb_dat_w[3:0] < 9)
                                kernel_index <= wb_dat_w[3:0];
                        end

                        REG_KERNEL_DATA: begin
                            if (kernel_index < 9)
                                kernel_mem[kernel_index] <= wb_dat_w[7:0];
                        end

                        REG_OUTPUT_INDEX: begin
                            if (wb_dat_w[3:0] < 9)
                                output_index <= wb_dat_w[3:0];
                        end

                        default: begin
                        end
                    endcase

                end else begin
                    case (wb_adr[4:0])

                        REG_CTRL:
                            wb_dat_r <= 32'd0;

                        REG_STATUS:
                            wb_dat_r <= {30'd0, busy, done};

                        REG_INPUT_INDEX:
                            wb_dat_r <= {27'd0, input_index};

                        REG_INPUT_DATA:
                            wb_dat_r <= {{24{input_mem[input_index][7]}}, input_mem[input_index]};

                        REG_KERNEL_INDEX:
                            wb_dat_r <= {28'd0, kernel_index};

                        REG_KERNEL_DATA:
                            wb_dat_r <= {{24{kernel_mem[kernel_index][7]}}, kernel_mem[kernel_index]};

                        REG_OUTPUT_INDEX:
                            wb_dat_r <= {28'd0, output_index};

                        REG_OUTPUT_DATA:
                            wb_dat_r <= output_mem[output_index];

                        default:
                            wb_dat_r <= 32'h0000_0000;
                    endcase
                end
            end
        end
    end

endmodule