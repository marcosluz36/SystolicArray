`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marcos Luz
// 
// Create Date: 11/05/2025 04:20:03 PM
// Design Name:
// Module Name: PE
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

module PE #(
  parameter DATA_WIDTH = 8
)(
  input  logic                    clk,
  input  logic                    rst,
  input  logic                    en,
  input  logic [DATA_WIDTH-1:0]   a_in,
  input  logic [DATA_WIDTH-1:0]   b_in,
  output logic [DATA_WIDTH-1:0]   a_out,
  output logic [DATA_WIDTH-1:0]   b_out,
  output logic [2*DATA_WIDTH-1:0] acc
);
  
  logic [DATA_WIDTH-1:0] mul;

  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      a_out <= 0;
      b_out <= 0;
      mul   <= 0;
    end
    
    else if (en) begin
      a_out <= a_in;
      b_out <= b_in;
      mul   <= a_in * b_in;
    end
  end

  always @ (posedge clk or posedge rst) begin
    if (rst)
      acc <= 0;
      
    else if (en)
      acc <= acc + mul;
  end
endmodule