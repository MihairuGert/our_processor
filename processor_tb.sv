`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2024 12:59:15
// Design Name: 
// Module Name: processor_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module processor_tb();
logic clk, reset;

processor DUT(.clk(clk), .reset(reset));

parameter PERIOD = 10;

always begin
    clk = 1'b0; #(PERIOD/2);
    clk = 1'b1; #(PERIOD/2);
end

initial begin
    reset = 1; #10;
    reset = 0; #5000;
$finish;
end;

endmodule
