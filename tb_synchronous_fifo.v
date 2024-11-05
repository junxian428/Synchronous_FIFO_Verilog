`timescale 1ns / 1ps

module tb_synchronous_fifo;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    // Testbench Signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    // Instantiate the FIFO
    synchronous_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        $dumpfile("fifo_waveform.vcd"); // Specifies the name of the VCD file
        $dumpvars(0, tb_synchronous_fifo); // Dumps all signals in the testbench
        clk = 0;
        forever #5 clk = ~clk;  // 10 ns clock period
    end

    // Test procedure
    initial begin
        // Initialize signals
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // Reset the FIFO
        #10 rst = 0;
        #10 rst = 1;  // Release reset
        #10 rst = 0;

        // Write data to the FIFO until it is full
        $display("Starting FIFO Write Operations");
        repeat (DEPTH) begin
            @(posedge clk);
            wr_en = 1;
            din = din + 1;
        end
        @(posedge clk);
        wr_en = 0;  // Stop writing

        // Check if FIFO is full
        if (full)
            $display("FIFO is full as expected.");
        else
            $display("Error: FIFO is not full!");

        // Read data from the FIFO until it is empty
        $display("Starting FIFO Read Operations");
        repeat (DEPTH) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;  // Stop reading

        // Check if FIFO is empty
        if (empty)
            $display("FIFO is empty as expected.");
        else
            $display("Error: FIFO is not empty!");

        // Test random write and read operations
        $display("Testing Random Write and Read Operations");
        wr_en = 1; din = 8'hAA; @(posedge clk);
        wr_en = 1; din = 8'hBB; @(posedge clk);
        wr_en = 0; rd_en = 1; @(posedge clk);
        rd_en = 0;

        // Finish simulation
        $stop;
    end

endmodule
