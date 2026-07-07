`timescale 1ns/1ps

module tb_soc;

    reg clk;
    reg reset;

    soc_top #(
        .RAM_INIT_FILE("sim/memory/firmware.hex")
    ) uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 100 MHz sim clock
    end

    initial begin
        $dumpfile("sim/output/soc.vcd");
        $dumpvars(0, tb_soc);

        reset = 1'b1;
        repeat (20) @(posedge clk);
        reset = 1'b0;

        wait (uut.u_cnn.done == 1'b1);

        repeat (10) @(posedge clk);

        $display("====================================");
        $display("CNN DONE");
        $display("out0 = %0d", uut.u_cnn.output_mem[0]);
        $display("out1 = %0d", uut.u_cnn.output_mem[1]);
        $display("out2 = %0d", uut.u_cnn.output_mem[2]);
        $display("out3 = %0d", uut.u_cnn.output_mem[3]);
        $display("out4 = %0d", uut.u_cnn.output_mem[4]);
        $display("out5 = %0d", uut.u_cnn.output_mem[5]);
        $display("out6 = %0d", uut.u_cnn.output_mem[6]);
        $display("out7 = %0d", uut.u_cnn.output_mem[7]);
        $display("out8 = %0d", uut.u_cnn.output_mem[8]);
        $display("====================================");

        repeat (20) @(posedge clk);
        $finish;
    end

endmodule
