`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2024 12:57:24
// Design Name: 
// Module Name: processor
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
// proc

module processor(
  input clk,
  input reset
  );

  logic [4:0] inst_p;
  logic [7:0] acc, d_out;
  logic [2:0] inst_COP;
  logic [4:0] inst_ADDR; // адрес следующей инструкции

  // ----------------------- Micro Control Unit -----------------------
  enum logic [3:0] {inst_addr = 4'b0000,
            inst_read = 4'b0001,
            decode    = 4'b0010,
            load_read = 4'b0011,
            load      = 4'b0100,
            store     = 4'b0101,
            add_read  = 4'b0110,
            add       = 4'b0111,
            decrement = 4'b1000,
            branch    = 4'b1001,
            halt      = 4'b1010
            } state; 

  parameter ad = 3'b000;
  parameter dc = 3'b001;
  parameter ld = 3'b010;
  parameter st = 3'b011;
  parameter br = 3'b100;
  parameter ht = 3'b101;

  always @(posedge clk or posedge reset) begin
    // state переключается только здесь.
    if (reset) 
      state <= inst_addr;
    else 
      case (state)
        inst_addr : state <= inst_read; 
        inst_read : state <= decode; // получили inst_COP.
        decode    : case (inst_COP) // декодируем inst_COP.
                   ad: state <= add_read;
                   dc: state <= decrement;
                   ld: state <= load_read;
                   st: state <= store;
                   br: state <= branch;
                   ht: state <= halt;
                 endcase
        load_read : state <= load;
        add_read  : state <= add;
        load      : state <= inst_addr;
        add       : state <= inst_addr;
        store     : state <= inst_addr;
        decrement : state <= inst_addr;
        branch    : state <= inst_addr;
        halt      : state <= halt;
      endcase
  end

                 
  // ----------------------- Instruction Pointer -----------------------
  always @(posedge clk or posedge reset) begin
    if (reset)
      inst_p <= 5'b00000; // начинаем с нулевой строки?
    else if (state == branch)
      if (acc != 0) // ветвимся. // has been inverted
        inst_p <= inst_ADDR;
      else // переходим к следующей операции.
        inst_p <= inst_p + 1;
    else if ((state == load) | (state == store) | (state == add) | (state == decrement))
      inst_p <= inst_p + 1; // после выполнения перечисленных операций inst_p указывает на следующую строчку (переходим к следующей строке памяти).
  end



  // --------------- Accumulator + Arithmetic Logic Unit ---------------
  always @(posedge clk or posedge reset) begin
    if (reset)
      acc <= 5'b00000;
    else if (state == load)
      acc <= d_out;
    else if (state == decrement)
      acc <= acc - 1;
    else if (state == add) 
      acc <= acc + d_out;
  end


  // ---------------------- Instruction Register ----------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      inst_ADDR <= 5'b00000;
      inst_COP <= 3'b000;
    end
    else if (state == inst_read) begin
      inst_ADDR <= d_out[4:0]; // 5 младших хранят значение
      inst_COP <= d_out[7:5]; // 3 старшие хранят код операции
    end
  end


  // ----------------------------- Memory -----------------------------
  logic [7:0] ram [31:0];
  initial $readmemb("memory.mem", ram, 0, 31);

  always @(posedge clk) 
    d_out <= ram[(state == inst_addr) ? inst_p : inst_ADDR];

  always @(posedge clk)
    if (state == store) 
      ram[inst_ADDR] <= acc;

endmodule
