`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marcos Luz
// 
// Create Date: 12/06/2025 04:33:03 PM
// Design Name: 
// Module Name: SystolicDatapath
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


module SystolicDatapath #(
  parameter MATRIX_SIZE = 3,
  parameter DATA_WIDTH = 8,
  parameter WIDTH = 24,
  parameter PE_WORK_CYCLES
)(
  input  logic                             clk,
  input  logic                             pe_rst,
  input  logic [$clog2(3*MATRIX_SIZE)-1:0] cycle,
  input  logic [WIDTH-1:0]                 matrix_A,
  input  logic [WIDTH-1:0]                 matrix_B,
  output logic [2*DATA_WIDTH-1:0]          matrix_C [MATRIX_SIZE][MATRIX_SIZE]
);

  logic [DATA_WIDTH-1:0] a [MATRIX_SIZE][MATRIX_SIZE+1];
  logic [DATA_WIDTH-1:0] b [MATRIX_SIZE+1][MATRIX_SIZE];
  logic                 en[MATRIX_SIZE][MATRIX_SIZE];

  genvar i, j;
  generate
    for (i = 0; i < MATRIX_SIZE; i++) begin : sourceA
      assign a[i][0] = (cycle >= i && cycle < i + MATRIX_SIZE) ? matrix_A[(WIDTH-1)-(DATA_WIDTH*i):(2*DATA_WIDTH)-(DATA_WIDTH*i)] : 0;
    end
    
    for (j = 0; j < MATRIX_SIZE; j++) begin : sourceB
      assign b[0][j] = (cycle >= j && cycle < j + MATRIX_SIZE) ? matrix_B[(WIDTH-1)-(DATA_WIDTH*j):(2*DATA_WIDTH)-(DATA_WIDTH*j)] : 0;
    end
  endgenerate

  generate
    for (i = 0; i < MATRIX_SIZE; i++) begin : rowEn
      for (j = 0; j < MATRIX_SIZE; j++) begin : colEn
        localparam int K = i + j;
        assign en[i][j] = (cycle >= K) && (cycle < K + PE_WORK_CYCLES);
      end
    end
  endgenerate

  generate
    for (i = 0; i < MATRIX_SIZE; i++) begin : row
      for (j = 0; j < MATRIX_SIZE; j++) begin : column
        PE #(
          .DATA_WIDTH(DATA_WIDTH)
        )  pe_inst (
          .clk(clk),     .a_in(a[i][j]), .a_out(a[i][j+1]), 
          .rst(pe_rst),  .b_in(b[i][j]), .b_out(b[i+1][j]),
          .en(en[i][j]), .acc(matrix_C[i][j])        
        );
      end
    end
  endgenerate
endmodule
