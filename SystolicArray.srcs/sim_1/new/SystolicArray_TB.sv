`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marcos Luz
// 
// Create Date: 11/05/2025 04:48:06 PM
// Design Name: 
// Module Name: Systolic_Array_TB
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


module SystolicArray_TB;
  localparam MATRIX_SIZE = 3;
  localparam DATA_WIDTH = 8;
  localparam NUM_SAMPLES = 8;
  localparam WIDTH = MATRIX_SIZE * DATA_WIDTH;
  localparam DEPTH = (2 * MATRIX_SIZE - 1);
  localparam TOTAL_ELEMENTS = 3 * WIDTH * DEPTH * NUM_SAMPLES + 3;

  logic clk;
  logic rst;
  logic start;
  logic done;

  logic [DATA_WIDTH-1:0]   matrix_A [MATRIX_SIZE][DEPTH];
  logic [DATA_WIDTH-1:0]   matrix_B [MATRIX_SIZE][DEPTH];
  logic [2*DATA_WIDTH-1:0] matrix_C [MATRIX_SIZE][MATRIX_SIZE];
  logic [2*DATA_WIDTH-1:0] matrix_C_expected [MATRIX_SIZE][MATRIX_SIZE];
  
  logic [WIDTH-1:0] din_A, next_A;
  logic [WIDTH-1:0] din_B, next_B;
  
  logic [2*DATA_WIDTH-1:0] temp_memory [0:TOTAL_ELEMENTS];
  int index_A, index_B, index_C;

  SystolicArray #(
    .MATRIX_SIZE(MATRIX_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .WIDTH(WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .matrix_A(din_A),
    .matrix_B(din_B),
    .matrix_C(matrix_C)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $readmemh("test_samples.mem", temp_memory);
    
    display_config();
	
    start = 0;
    rst = 0; #1
    rst = 1; #1;
    rst = 0;
    
    for (int n = 0; n < NUM_SAMPLES; n++) begin
      get_matrices(n);
      print_test_matrices("Elementos da Matriz A", "Elementos da Matriz B");#12;

      $display("\n[%0t ns] Inicializando o Systolic Array...", ($time));
      send_matrices_batchs();

      $display("[%0t ns] Aguardando o sinal de 'done'...", ($time));
      wait (done == 1);
      $display("[%0t ns] Calculo completo.", ($time)); #6;

      check_result(n);
    end

    $display("\n[%0t ns] Simulacao finalizada!", ($time));
  end
  
task display_config();
    $display("----- Configuracao dos Testes -----");
    $display("Numero de Elementos por Matriz: %2d", (temp_memory[0]**2));
    $display("Numero de Bits por Simbolo %2d", (temp_memory[1]));
    $display("Numero de Casos de Teste: %2d", temp_memory[2]);
    $display("Menor Numero Possivel: %2d", (temp_memory[3]));
    $display("Maior Numero Possivel: %2d", temp_memory[4]);	
    $display("-----------------------------------");
endtask

  task get_matrices(input int n);
    for (int i = 0; i < MATRIX_SIZE; i++) begin
      for (int j = 0; j < DEPTH; j++) begin
        index_A = (3*n*(MATRIX_SIZE * DEPTH) - 6*n) + (i * (2*MATRIX_SIZE-1)) + j + 5;
        index_B = ((3*n + 1) * (MATRIX_SIZE * DEPTH) - n*6) + (i * (2*MATRIX_SIZE-1)) + j + 5;
        index_C = ((3*n + 2) * (MATRIX_SIZE * DEPTH) - n*6) + (i * MATRIX_SIZE) + j + 5;

        matrix_A[i][j] = temp_memory[index_A];
        matrix_B[i][j] = temp_memory[index_B];
        
        if (j < MATRIX_SIZE) 
          matrix_C_expected[i][j] = temp_memory[index_C];
      end
    end
  endtask
  
  task send_matrices_batchs();
    @(posedge clk);

    for (int col = 0; col < DEPTH; col++) begin
      next_A = 0;
      next_B = 0;
        
      for (int row = 0; row < MATRIX_SIZE; row++) begin
        next_A = next_A << 8 | (matrix_A[row][col]);
        next_B = next_B << 8 | (matrix_B[row][col]);
      end 
        
      din_A <= next_A;
      din_B <= next_B;

      if (col == 0) begin
        start <= 1'b1;
        @(posedge clk);
      end
        
      else 
        start <= 1'b0;

      @(posedge clk);
    end
    
    start <= 0;
    din_A <= '0;
    din_B <= '0;
endtask

  task check_result(input int n);
    int error_count = 0;
    $display("\n--- Verificacao ---");
    for (int i = 0; i < MATRIX_SIZE; i++) begin
      for (int j = 0; j < MATRIX_SIZE; j++) begin
        if (matrix_C[i][j] != matrix_C_expected[i][j]) begin
          $display("ERROR: Valores divergentes em C[%0d][%0d]: Previsto %d, Calculado %d",
                   i, j, matrix_C_expected[i][j], matrix_C[i][j]);
          error_count++;
        end
      end
    end

    print_result_matrix("Matriz C (Calculado)", matrix_C);
    print_result_matrix("Matriz C (Esperado)", matrix_C_expected);

    if (error_count == 0) begin
      $display("\n*** TESTE %0d PASSOU ***\n\n", (n + 1));
    end else begin
      $display("\n*** TESTE %0d FALHOU: %0d foram encontrados ***\n\n", (n + 1), error_count);
    end
  endtask
  
  task print_test_matrices(input string name_a, input string name_b);
    $display("\n--- %s ---", name_a);
    for (int i=0; i<MATRIX_SIZE; i++) begin
      $write("  ");
      for (int j=0; j<DEPTH; j++) begin
        $write("%4d ", matrix_A[i][j]);
      end
      $write("\n");
    end
    $display("\n--- %s ---", name_b);
    for (int i=0; i<MATRIX_SIZE; i++) begin
      $write("  ");
      for (int j=0; j<DEPTH; j++) begin
        $write("%4d ", matrix_B[i][j]);
      end
      $write("\n");
    end
  endtask

  task print_result_matrix(input string name, input logic [2*DATA_WIDTH-1:0] matrix [MATRIX_SIZE][MATRIX_SIZE]);
    $display("\n--- %s ---", name);
    for (int i=0; i<MATRIX_SIZE; i++) begin
      $write("  ");
      for (int j=0; j<MATRIX_SIZE; j++) begin
        $write("%8d ", matrix[i][j]);
      end
      $write("\n");
    end
  endtask

endmodule