module synchronous_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input wire clk,                   // Clock input
    input wire rst,                   // Reset (active high)
    input wire wr_en,                 // Write enable
    input wire rd_en,                 // Read enable
    input wire [DATA_WIDTH-1:0] din,  // Data input
    output reg [DATA_WIDTH-1:0] dout, // Data output
    output reg full,                  // Full flag
    output reg empty                  // Empty flag
);

    // Internal registers
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1]; // Memory array
    reg [3:0] wr_ptr = 0;                    // Write pointer (4 bits for DEPTH = 16)
    reg [3:0] rd_ptr = 0;                    // Read pointer (4 bits for DEPTH = 16)
    reg [4:0] fifo_count = 0;                // Count of elements in FIFO (5 bits for DEPTH up to 16)

    // Write operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            memory[wr_ptr] <= din;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= memory[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

// FIFO count and flag management
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fifo_count <= 0;
        full <= 0;
        empty <= 1;
    end else begin
        // Update count based on read and write enables
        if (wr_en && !full && !(rd_en && !empty)) begin
            fifo_count <= fifo_count + 1; // Write only
        end else if (rd_en && !empty && !(wr_en && !full)) begin
            fifo_count <= fifo_count - 1; // Read only
        end

        // Update full and empty flags
        full <= (fifo_count == DEPTH - 1 && wr_en && !rd_en) || (fifo_count == DEPTH);
        empty <= (fifo_count == 1 && rd_en && !wr_en) || (fifo_count == 0);
    end
end


endmodule
