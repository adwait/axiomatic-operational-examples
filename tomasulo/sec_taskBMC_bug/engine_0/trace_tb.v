`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  wire [0:0] PI_clk = clock;
  reg [31:0] PI_instr_stream;
  reg [0:0] PI_reset;
  Tomasulo UUT (
    .clk(PI_clk),
    .instr_stream(PI_instr_stream),
    .reset(PI_reset)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$formal$formal.\v:142$1985_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$1986_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$1989_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$1992_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$1995_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$1998_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2001_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2004_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2007_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2010_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2013_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2016_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2019_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2022_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2025_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2028_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:148$2031_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$1987_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$1990_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$1993_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$1996_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$1999_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2002_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2005_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2008_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2011_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2014_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2017_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2020_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2023_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2026_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2029_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:150$2032_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$1988_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$1991_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$1994_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$1997_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2000_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2003_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2006_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2009_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2012_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2015_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2018_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2021_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2024_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2027_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2030_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:151$2033_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:157$2034_CHECK  = 1'b0;
    // UUT.$formal$formal.\v:94$1964_EN  = 1'b0;
    UUT.PC = 6'b000000;
    UUT.Pinit = 1'b1;
    UUT.\ROB_Dest[0]  = 5'b00000;
    UUT.\ROB_Dest[1]  = 5'b00000;
    UUT.\ROB_Dest[2]  = 5'b00000;
    UUT.\ROB_Dest[3]  = 5'b00000;
    UUT.\ROB_Dest[4]  = 5'b00000;
    UUT.\ROB_Dest[5]  = 5'b00000;
    UUT.\ROB_Dest[6]  = 5'b00001;
    UUT.\ROB_Dest[7]  = 5'b00000;
    UUT.ROB_busy = 8'b00000000;
    UUT.ROB_head_ptr = 3'b000;
    UUT.ROB_tail_ptr = 3'b000;
    UUT.ROB_valid = 8'b00000000;
    UUT.RS_Add_S1_valid = 4'b0000;
    UUT.RS_Add_S2_valid = 4'b0000;
    UUT.RS_Add_busy = 4'b0000;
    UUT.RS_Add_count = 2'b00;
    UUT.aa_head_ptr = 4'b0000;
    UUT.aa_tail_ptr = 4'b0000;
    UUT.in_use = 16'b0000000000000000;
    UUT.init = 1'b1;
    UUT.next_pc = 6'b000100;
    UUT.pr_Add_Sub_Instr = 3'b000;
    UUT.pr_Add_Sub_PC = 6'b000000;
    UUT.pr_Add_Sub_Tag = 3'b000;
    UUT.pr_Add_Sub_result_valid = 1'b0;
    UUT.pr_Add_Sub_tag = 3'b000;
    UUT.pr_instr_fetch = 32'b00000000000000000000000000000000;
    UUT.stall_flag = 1'b0;
    UUT.RAT[5'b00000] = 4'b0000;
    UUT.RAT[5'b00010] = 4'b1000;
    UUT.RAT[5'b00100] = 4'b1000;
    UUT.RAT[5'b00001] = 4'b0000;
    UUT.RAT[5'b00101] = 4'b1000;
    UUT.RAT[5'b00110] = 4'b0010;
    UUT.RS_Add_Dest_tag[2'b11] = 3'b000;
    UUT.RS_Add_Dest_tag[2'b10] = 3'b000;
    UUT.RS_Add_Dest_tag[2'b01] = 3'b001;
    UUT.RS_Add_Dest_tag[2'b00] = 3'b011;
    UUT.RS_Add_Instr[2'b11] = 3'b000;
    UUT.RS_Add_Instr[2'b10] = 3'b000;
    UUT.RS_Add_Instr[2'b01] = 3'b111;
    UUT.RS_Add_Instr[2'b00] = 3'b101;
    UUT.RS_Add_PC[2'b11] = 6'b000000;
    UUT.RS_Add_PC[2'b10] = 6'b000000;
    UUT.RS_Add_PC[2'b01] = 6'b000000;
    UUT.RS_Add_PC[2'b00] = 6'b000000;
    UUT.RS_Add_S1_tag[2'b11] = 3'b001;
    UUT.RS_Add_S1_tag[2'b10] = 3'b101;
    UUT.RS_Add_S1_tag[2'b01] = 3'b011;
    UUT.RS_Add_S1_tag[2'b00] = 3'b001;
    UUT.RS_Add_S2_tag[2'b11] = 3'b001;
    UUT.RS_Add_S2_tag[2'b10] = 3'b111;
    UUT.RS_Add_S2_tag[2'b01] = 3'b000;
    UUT.RS_Add_S2_tag[2'b00] = 3'b111;
    UUT.events[4'b1111] = 1'b0;
    UUT.events[4'b1110] = 1'b0;
    UUT.events[4'b1101] = 1'b0;
    UUT.events[4'b1100] = 1'b0;
    UUT.events[4'b1011] = 1'b0;
    UUT.events[4'b1010] = 1'b0;
    UUT.events[4'b1001] = 1'b0;
    UUT.events[4'b1000] = 1'b0;
    UUT.events[4'b0111] = 1'b0;
    UUT.events[4'b0110] = 1'b0;
    UUT.events[4'b0101] = 1'b0;
    UUT.events[4'b0100] = 1'b0;
    UUT.events[4'b0011] = 1'b0;
    UUT.events[4'b0010] = 1'b0;
    UUT.events[4'b0001] = 1'b0;
    UUT.events[4'b0000] = 1'b0;
    UUT.instr_U[4'b1111] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1110] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1101] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1100] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1011] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1010] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1001] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b1000] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0111] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0110] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0101] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0100] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0011] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0010] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0001] = 32'b00000000000000000000000000000000;
    UUT.instr_U[4'b0000] = 32'b00000000000000000000000000000000;
    UUT.windows[4'b1111] = 6'b000000;
    UUT.windows[4'b1110] = 6'b000000;
    UUT.windows[4'b1101] = 6'b000000;
    UUT.windows[4'b1100] = 6'b000000;
    UUT.windows[4'b1011] = 6'b000000;
    UUT.windows[4'b1010] = 6'b000000;
    UUT.windows[4'b1001] = 6'b000000;
    UUT.windows[4'b1000] = 6'b000000;
    UUT.windows[4'b0111] = 6'b000000;
    UUT.windows[4'b0110] = 6'b000000;
    UUT.windows[4'b0101] = 6'b000000;
    UUT.windows[4'b0100] = 6'b000000;
    UUT.windows[4'b0011] = 6'b000000;
    UUT.windows[4'b0010] = 6'b000000;
    UUT.windows[4'b0001] = 6'b000000;
    UUT.windows[4'b0000] = 6'b000000;

    // state 0
    PI_instr_stream = 32'b00000000000000000000000000000000;
    PI_reset = 1'b1;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_instr_stream <= 32'b00000000001000100000000010110011;
      PI_reset <= 1'b0;
    end

    // state 2
    if (cycle == 1) begin
      PI_instr_stream <= 32'b00000000000100100000000100110011;
      PI_reset <= 1'b0;
    end

    // state 3
    if (cycle == 2) begin
      PI_instr_stream <= 32'b00000000010100100000001100110011;
      PI_reset <= 1'b0;
    end

    // state 4
    if (cycle == 3) begin
      PI_instr_stream <= 32'b00000000000100100000000100110011;
      PI_reset <= 1'b0;
    end

    // state 5
    if (cycle == 4) begin
      PI_instr_stream <= 32'b00000000001000100000000010110011;
      PI_reset <= 1'b0;
    end

    // state 6
    if (cycle == 5) begin
      PI_instr_stream <= 32'b00000000000100100000000100110011;
      PI_reset <= 1'b0;
    end

    // state 7
    if (cycle == 6) begin
      PI_instr_stream <= 32'b00000000011000100000001010110011;
      PI_reset <= 1'b0;
    end

    // state 8
    if (cycle == 7) begin
      PI_instr_stream <= 32'b00000000001000100000000010110011;
      PI_reset <= 1'b0;
    end

    // state 9
    if (cycle == 8) begin
      PI_instr_stream <= 32'b00000000000100100000000100110011;
      PI_reset <= 1'b0;
    end

    // state 10
    if (cycle == 9) begin
      PI_instr_stream <= 32'b00000000001000100000000010110011;
      PI_reset <= 1'b0;
    end

    // state 11
    if (cycle == 10) begin
      PI_instr_stream <= 32'b00000000001000100000000010110011;
      PI_reset <= 1'b0;
    end

    genclock <= cycle < 11;
    cycle <= cycle + 1;
  end
endmodule
