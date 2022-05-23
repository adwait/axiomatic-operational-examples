

`define CTR_WIDTH 6
`define CYCLE_CNT 64

`define IDLE  2'b00
`define WRITE 2'b01
`define READ  2'b10
`define REFR  2'b11

module FormalInduct (
  input clk,
  input [23:0] haddr_in,
  input [15:0] data_input_in,
  
  input mk_instr,
  input is_write
);

sdram_controller sdram_controlleri (
    /* HOST INTERFACE */
    .wr_addr(haddr), 
    .wr_data(data_input),
    .rd_data(data_output),
    .busy(busy), .rd_enable(rd_enable), .wr_enable(wr_enable), .rst_n(rst_n), .clk(clk),

    /* SDRAM SIDE */
    .addr(addr), .bank_addr(bank_addr), 
    // .data(data), 
    .data_in(data_in), .data_out(data_out),
    .clock_enable(clock_enable), .cs_n(cs_n), .ras_n(ras_n), .cas_n(cas_n), .we_n(we_n), .data_mask_low(data_mask_low), .data_mask_high(data_mask_high),

    /* Verification interface */
    .lft_state(lft_state)
);

  // Verification elements
  wire [4:0] lft_state;

  reg [7:0] glob_ctr;

  /* HOST CONTROLLS */
  // data read/write address
  reg [23:0]  haddr;
  reg [15:0]  data_input;
  wire [15:0] data_output;
  wire busy;
  reg rd_enable, wr_enable, rst_n;

  /* SDRAM SIDE */
  wire [12:0] addr;
  wire [1:0] bank_addr;
  // separate inout to input and output
  // wire [15:0] data; 
  wire [15:0] data_in;  // input to the controller
  wire [15:0] data_out; // output from the controller
  wire clock_enable, cs_n, ras_n, cas_n, we_n, data_mask_low, data_mask_high;

  reg [15:0] data_r;

  assign data_in = data_r;

  `define PIPELINE_DEPTH 32
  
  reg [`CTR_WIDTH-1:0] counter;
  reg init;

  reg [3:0] progress_counter;
  reg [1:0] instr_U;
  reg       in_use_P;
  reg       in_use;
  reg [`PIPELINE_DEPTH-1:0]   events;

  `define WRITE_STG_LOW 24
  `define WRITE_STG_HIGH 27

  `define READ_STG_LOW 16
  `define READ_STG_HIGH 20

  `define REFRESH_STG_LOW 1
  `define REFRESH_STG_HIGH 4

  wire [`WRITE_STG_HIGH-`WRITE_STG_LOW-1:0] pipe_write_bad;
  wire [`READ_STG_HIGH-`READ_STG_LOW-1:0] pipe_read_bad;
  wire [`READ_STG_HIGH-`READ_STG_LOW-1:0] interrupt_read_bad;
  wire [`WRITE_STG_HIGH-`WRITE_STG_LOW-1:0] interrupt_write_bad;
  wire in_refresh;
  wire done;
  wire bad;
  wire active;

  genvar i1;
  // WRITE pipeline axiom
  for (i1 = `WRITE_STG_LOW; i1 < `WRITE_STG_HIGH; i1 = i1+1) begin
      assign pipe_write_bad[i1-`WRITE_STG_LOW] = in_use && instr_U == `WRITE && 
        (|events[`WRITE_STG_HIGH:(i1+1)]) && !(events[i1]);
  end

  genvar i2;
  // READ pipeline axiom
  for (i2 = `READ_STG_LOW; i2 < `READ_STG_HIGH; i2 = i2+1) begin
      assign pipe_read_bad[i2-`READ_STG_LOW] = in_use && instr_U == `READ && 
        (|events[`READ_STG_HIGH:(i2+1)]) && !(events[i2]);
  end

  genvar i3;
  // WRITE interrupt axiom
  for (i3 = `WRITE_STG_LOW+1; i3 < `WRITE_STG_HIGH+1; i3 = i3+1) begin
      assign interrupt_write_bad[i3-`WRITE_STG_LOW-1] = in_use && instr_U == `WRITE && 
        (events[`WRITE_STG_LOW]) && !(events[i3]) && in_refresh;
  end

  genvar i4;
  // READ interrupt axiom
  for (i4 = `READ_STG_LOW+1; i4 < `READ_STG_HIGH+1; i4 = i4+1) begin
      assign interrupt_read_bad[i4-`READ_STG_LOW-1] = in_use && instr_U == `READ && 
        (events[`READ_STG_LOW]) && !(events[i4]) && in_refresh;
  end

  // Peeked signals from design to transition on
  assign in_refresh = |events[`REFRESH_STG_HIGH:`REFRESH_STG_LOW];
  assign done = in_use && (
        (instr_U == `WRITE && &events[`WRITE_STG_HIGH:`WRITE_STG_LOW])
    ||  (instr_U == `READ && &events[`READ_STG_HIGH:`READ_STG_LOW]) 
    ||  (events[`REFRESH_STG_HIGH])
  );
  assign active = in_use_P || in_use || busy;

  // BAD STATE: should not reach
  assign bad = (|pipe_read_bad) || (|pipe_write_bad);

  // module setup
  initial begin
    rst_n = 1'b1;
    
    counter = `CTR_WIDTH'b0;
    glob_ctr = 8'd1;
    init = 1'b1;

    haddr = 24'd0;
    data_input = 16'd0;
    rd_enable = 1'b0;
    wr_enable = 1'b0;
    // data_r = 16'hzzzz;
    data_r = 16'd0;

    progress_counter = 4'd0;
    instr_U = 2'd0;
    in_use = 1'b0;
    events = 32'b0;
  end

  // Initialization
  always @(posedge clk) begin
    counter <= counter + `CTR_WIDTH'b1;
    glob_ctr <= glob_ctr + 8'b1;
    if (counter < 2 && init) begin
      rst_n <= 1'b0;
    end else begin
      rst_n <= 1'b1;
    end
    if (counter == (`CYCLE_CNT-1)) begin
      init <= 0;
    end
    in_use_P <= in_use;
  end

  // Main run of the machine
  always @(posedge clk) begin
    if (!init && !busy && mk_instr && !in_use) begin
      haddr <= haddr_in;
      data_input <= data_input_in;
      instr_U <= is_write ? `WRITE : `READ;
      in_use <= 1;
      progress_counter <= 1;
    end else if (in_use) begin
      /**
        * Post done signal
        */
      if (done) begin
        progress_counter <= 0;
        in_use <= 0;
        instr_U <= `IDLE;
        wr_enable <= 1'b0;
        rd_enable <= 1'b0;
        haddr <= 24'd0;
        data_input <= 16'd0;
        // reset the event tracker
        events <= 32'd0;
      end else begin
        progress_counter <= progress_counter + 1;
        events[lft_state] <= 1'b1;
        // Set the enable signal
        case (instr_U)
          `WRITE  : begin
            if (progress_counter == 2)
              wr_enable <= 1'b1;
            else if (progress_counter == 8) begin
              wr_enable <= 1'b0;
              haddr <= 24'd0;
              data_input <= 16'd0;
            end
          end
          `READ   : begin
            if (progress_counter == 2)
              rd_enable <= 1'b1;
            else if (progress_counter == 10) begin
              rd_enable <= 1'b0;
              haddr <= 24'd0;
              data_input <= 16'd0;
            end              
          end
        endcase
      end
    end
  end

`ifdef FORMAL
  always @(posedge clk) begin
    assert(!bad);
    assert(init || rst_n);
  end
`endif

endmodule