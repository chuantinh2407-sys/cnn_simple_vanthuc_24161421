`timescale 1ns/1ps

module soc_top #(
    parameter RAM_INIT_FILE = "sim/memory/firmware.hex"
)(
    input  wire clk,
    input  wire reset
);

    // ============================================================
    // CPU Wishbone wires
    // ============================================================

    // Instruction bus from CPU
    wire        ibus_cyc;
    wire        ibus_stb;
    wire        ibus_ack;
    wire        ibus_we;
    wire [29:0] ibus_adr;
    wire [31:0] ibus_dat_miso;
    wire [31:0] ibus_dat_mosi;
    wire [3:0]  ibus_sel;
    wire        ibus_err;
    wire [2:0]  ibus_cti;
    wire [1:0]  ibus_bte;

    // Data bus from CPU
    wire        dbus_cyc;
    wire        dbus_stb;
    wire        dbus_ack;
    wire        dbus_we;
    wire [29:0] dbus_adr;
    wire [31:0] dbus_dat_miso;
    wire [31:0] dbus_dat_mosi;
    wire [3:0]  dbus_sel;
    wire        dbus_err;
    wire [2:0]  dbus_cti;
    wire [1:0]  dbus_bte;

    // ============================================================
    // RAM Wishbone wires
    // ============================================================

    // RAM instruction port
    wire        ram_i_cyc;
    wire        ram_i_stb;
    wire        ram_i_we;
    wire [29:0] ram_i_adr;
    wire [31:0] ram_i_dat_w;
    wire [3:0]  ram_i_sel;
    wire [31:0] ram_i_dat_r;
    wire        ram_i_ack;
    wire        ram_i_err;

    // RAM data port
    wire        ram_d_cyc;
    wire        ram_d_stb;
    wire        ram_d_we;
    wire [29:0] ram_d_adr;
    wire [31:0] ram_d_dat_w;
    wire [3:0]  ram_d_sel;
    wire [31:0] ram_d_dat_r;
    wire        ram_d_ack;
    wire        ram_d_err;

    // ============================================================
    // CNN Wishbone wires
    // ============================================================

    wire        cnn_cyc;
    wire        cnn_stb;
    wire        cnn_we;
    wire [29:0] cnn_adr;
    wire [31:0] cnn_dat_w;
    wire [3:0]  cnn_sel;
    wire [31:0] cnn_dat_r;
    wire        cnn_ack;
    wire        cnn_err;

    // ============================================================
    // VexRiscv CPU
    // ============================================================

    VexRiscv u_cpu (
        .externalResetVector      (32'h0000_0000),
        .timerInterrupt           (1'b0),
        .softwareInterrupt        (1'b0),
        .externalInterruptArray   (32'h0000_0000),

        // Instruction Wishbone bus
        .iBusWishbone_CYC         (ibus_cyc),
        .iBusWishbone_STB         (ibus_stb),
        .iBusWishbone_ACK         (ibus_ack),
        .iBusWishbone_WE          (ibus_we),
        .iBusWishbone_ADR         (ibus_adr),
        .iBusWishbone_DAT_MISO    (ibus_dat_miso),
        .iBusWishbone_DAT_MOSI    (ibus_dat_mosi),
        .iBusWishbone_SEL         (ibus_sel),
        .iBusWishbone_ERR         (ibus_err),
        .iBusWishbone_CTI         (ibus_cti),
        .iBusWishbone_BTE         (ibus_bte),

        // Data Wishbone bus
        .dBusWishbone_CYC         (dbus_cyc),
        .dBusWishbone_STB         (dbus_stb),
        .dBusWishbone_ACK         (dbus_ack),
        .dBusWishbone_WE          (dbus_we),
        .dBusWishbone_ADR         (dbus_adr),
        .dBusWishbone_DAT_MISO    (dbus_dat_miso),
        .dBusWishbone_DAT_MOSI    (dbus_dat_mosi),
        .dBusWishbone_SEL         (dbus_sel),
        .dBusWishbone_ERR         (dbus_err),
        .dBusWishbone_CTI         (dbus_cti),
        .dBusWishbone_BTE         (dbus_bte),

        .clk                      (clk),
        .reset                    (reset)
    );

    // ============================================================
    // Wishbone decoder
    // ============================================================

    wb_decoder u_decoder (
        // CPU instruction bus
        .i_cyc       (ibus_cyc),
        .i_stb       (ibus_stb),
        .i_we        (ibus_we),
        .i_adr       (ibus_adr),
        .i_dat_w     (ibus_dat_mosi),
        .i_sel       (ibus_sel),
        .i_dat_r     (ibus_dat_miso),
        .i_ack       (ibus_ack),
        .i_err       (ibus_err),

        // CPU data bus
        .d_cyc       (dbus_cyc),
        .d_stb       (dbus_stb),
        .d_we        (dbus_we),
        .d_adr       (dbus_adr),
        .d_dat_w     (dbus_dat_mosi),
        .d_sel       (dbus_sel),
        .d_dat_r     (dbus_dat_miso),
        .d_ack       (dbus_ack),
        .d_err       (dbus_err),

        // RAM instruction port
        .ram_i_cyc   (ram_i_cyc),
        .ram_i_stb   (ram_i_stb),
        .ram_i_we    (ram_i_we),
        .ram_i_adr   (ram_i_adr),
        .ram_i_dat_w (ram_i_dat_w),
        .ram_i_sel   (ram_i_sel),
        .ram_i_dat_r (ram_i_dat_r),
        .ram_i_ack   (ram_i_ack),
        .ram_i_err   (ram_i_err),

        // RAM data port
        .ram_d_cyc   (ram_d_cyc),
        .ram_d_stb   (ram_d_stb),
        .ram_d_we    (ram_d_we),
        .ram_d_adr   (ram_d_adr),
        .ram_d_dat_w (ram_d_dat_w),
        .ram_d_sel   (ram_d_sel),
        .ram_d_dat_r (ram_d_dat_r),
        .ram_d_ack   (ram_d_ack),
        .ram_d_err   (ram_d_err),

        // CNN port
        .cnn_cyc     (cnn_cyc),
        .cnn_stb     (cnn_stb),
        .cnn_we      (cnn_we),
        .cnn_adr     (cnn_adr),
        .cnn_dat_w   (cnn_dat_w),
        .cnn_sel     (cnn_sel),
        .cnn_dat_r   (cnn_dat_r),
        .cnn_ack     (cnn_ack),
        .cnn_err     (cnn_err)
    );

    // ============================================================
    // Dual-port RAM
    // ============================================================

    wb_ram_dp #(
        .ADDR_WIDTH (14),
        .INIT_FILE  (RAM_INIT_FILE)
    ) u_ram (
        .clk     (clk),
        .reset   (reset),

        // Instruction port
        .i_cyc   (ram_i_cyc),
        .i_stb   (ram_i_stb),
        .i_we    (ram_i_we),
        .i_adr   (ram_i_adr),
        .i_dat_w (ram_i_dat_w),
        .i_sel   (ram_i_sel),
        .i_dat_r (ram_i_dat_r),
        .i_ack   (ram_i_ack),
        .i_err   (ram_i_err),

        // Data port
        .d_cyc   (ram_d_cyc),
        .d_stb   (ram_d_stb),
        .d_we    (ram_d_we),
        .d_adr   (ram_d_adr),
        .d_dat_w (ram_d_dat_w),
        .d_sel   (ram_d_sel),
        .d_dat_r (ram_d_dat_r),
        .d_ack   (ram_d_ack),
        .d_err   (ram_d_err)
    );

    // ============================================================
    // CNN Mini peripheral
    // ============================================================

    wb_cnn_mini u_cnn (
        .clk      (clk),
        .reset    (reset),

        .wb_cyc   (cnn_cyc),
        .wb_stb   (cnn_stb),
        .wb_we    (cnn_we),
        .wb_adr   (cnn_adr),
        .wb_dat_w (cnn_dat_w),
        .wb_sel   (cnn_sel),
        .wb_dat_r (cnn_dat_r),
        .wb_ack   (cnn_ack),
        .wb_err   (cnn_err)
    );

endmodule
