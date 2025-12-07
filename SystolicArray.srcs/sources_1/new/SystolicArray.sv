`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marcos Luz
// 
// Create Date: 11/05/2025 04:45:22 PM
// Design Name: 
// Module Name: SystolicArray
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

module SystolicArray #(
  parameter MATRIX_SIZE = 3,
  parameter DATA_WIDTH = 8,
  parameter WIDTH = 24
)(
  input  logic                    clk,
  input  logic                    rst,    
  input  logic                    start,   
  input  logic [WIDTH-1:0]        matrix_A,
  input  logic [WIDTH-1:0]        matrix_B,
  output logic [2*DATA_WIDTH-1:0] matrix_C [MATRIX_SIZE][MATRIX_SIZE],
  output done     
);
  localparam MAX_CYCLES = 3*MATRIX_SIZE;
  localparam PE_WORK_CYCLES = MATRIX_SIZE + 1; 

  logic w_pe_rst;
  logic [$clog2(MAX_CYCLES)-1:0] w_cycle;

  SystolicController #(
    .MATRIX_SIZE(MATRIX_SIZE),
    .MAX_CYCLES(MAX_CYCLES)
  ) controller_inst (
    .clk(clk),   .start(start),
    .rst(rst),   .pe_rst(w_pe_rst),
    .done(done), .cycle(w_cycle)
  );

  SystolicDatapath #(
    .MATRIX_SIZE(MATRIX_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .WIDTH(WIDTH),
    .PE_WORK_CYCLES(PE_WORK_CYCLES)
  ) datapath_inst (
    .matrix_A(matrix_A), .clk(clk),
    .matrix_B(matrix_B), .pe_rst(w_pe_rst),
    .matrix_C(matrix_C), .cycle(w_cycle)    
  );
endmodule