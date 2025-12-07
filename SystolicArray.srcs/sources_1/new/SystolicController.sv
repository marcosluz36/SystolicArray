`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marcos Luz
// 
// Create Date: 11/05/2025 04:25:28 PM
// Design Name: 
// Module Name: SystolicController
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


module SystolicController #(
  parameter MATRIX_SIZE = 3,
  parameter MAX_CYCLES
)(
  input  logic clk,
  input  logic rst,
  input  logic start,
  output logic pe_rst,
  output logic done,
  output logic [$clog2(3*MATRIX_SIZE)-1:0] cycle
);

  typedef enum {
    IDLE,
    COMPUTE,
    DONE
  } systolic_state;

  systolic_state current_state, next_state;
  logic op_complete;

  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      current_state <= IDLE;
    
    else
      current_state <= next_state;
  end

  always_comb begin
    next_state = current_state;
    done <= 0;
    
    case (current_state)
      IDLE: begin
      	if (start)       
          next_state = COMPUTE;
      end
      
      COMPUTE: begin
        if (op_complete) 
          next_state = DONE;
      end
      
      DONE: begin
		next_state = start ? COMPUTE : IDLE;
        done <= 1'b1;
      end
      
      default: begin
        next_state = IDLE;
      end
    endcase
  end

  assign op_complete = (cycle >= MAX_CYCLES-1);
  assign pe_rst = rst || (current_state == IDLE);

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle <= 0;
      
    end else begin
      case(current_state)
        IDLE:    
          cycle <= 0;
        
        COMPUTE: 
          cycle <= cycle + 1;
        
        DONE:    
          cycle <= 0;
        
        default: 
          cycle <= 0;
      endcase
    end
  end
endmodule
