        `define PIPELINE_DEPTH 1
        `define PIPELINE_WIDTH 16
        `define PIPELINE_WIDTH_ADDR 4
        `define PRED_WIDTH 1

        reg [`PC_WIDTH-1:0]         windows [0:`PIPELINE_WIDTH-1];
        reg [31:0]                  instr_U [0:`PIPELINE_WIDTH-1];
        reg [`PIPELINE_WIDTH-1:0]   in_use;
        reg [`PIPELINE_DEPTH-1:0]   events  [0:`PIPELINE_WIDTH-1];
        reg [`PC_WIDTH-1:0]         next_pc;

        wire                        done    [0:`PIPELINE_WIDTH-1];        
        genvar i_done;
        for (i_done = 0; i_done < `PIPELINE_WIDTH; i_done=i_done+1) begin
            assign done[i_done] = &events[i_done];
        end

        // INFO: Predicates and definition of violation
        wire [`PIPELINE_WIDTH-1:0]  pred_DependsOn  [0:`PIPELINE_WIDTH-1];
        wire [`PIPELINE_WIDTH-1:0]  bad             [0:`PIPELINE_WIDTH-1];
        genvar  i_pred, j_pred;
        for (i_pred = 0; i_pred < `PIPELINE_WIDTH; i_pred=i_pred+1) begin
            for (j_pred = 0; j_pred < `PIPELINE_WIDTH; j_pred=j_pred+1) begin
                assign pred_DependsOn[i_pred][j_pred] = in_use[i_pred] && in_use[j_pred] && 
                    // consec(i1, i2)
                    (windows[i_pred] + 4 == windows[j_pred]) && 
                    // dest(i1) == src1(i2) || dest(i1) == src2(i2)
                    ((instr_U[i_pred][11:7] == instr_U[j_pred][24:20]) || (instr_U[i_pred][11:7] == instr_U[j_pred][19:15]));
                assign bad[i_pred][j_pred] = pred_DependsOn[i_pred][j_pred] && (!events[i_pred][0]) && events[j_pred][0];
            end
        end
        // Disjunction of bad over all automata
        reg disj_bad;
        always @(*) begin
            integer i_disj_bad;
            disj_bad = 1'b0;
            for (i_disj_bad = 0; i_disj_bad < `PIPELINE_WIDTH; i_disj_bad=i_disj_bad+1) begin
                disj_bad = disj_bad || (|bad[i_disj_bad]);
            end
        end


        // Basic time tracking
        reg [4:0]           counter;
        reg init;
        reg Pinit;
        reg first_cycle;
        // Pointers into the free windows
        reg [`PIPELINE_WIDTH_ADDR-1:0]   aa_head_ptr;
        reg [`PIPELINE_WIDTH_ADDR-1:0]   aa_tail_ptr;    
        integer i_events;
        initial begin
            counter     = 5'd0;
            init        = 1'b1;
            Pinit       = 1'b1;
            first_cycle = 1'b1;
            // // !
            // reset       <= 1;

            // Initialize everything
            aa_head_ptr = `PIPELINE_WIDTH_ADDR'd0;
            aa_tail_ptr = `PIPELINE_WIDTH_ADDR'd0;
            next_pc     = `PC_WIDTH'd4;
            in_use      = 0;
            for (i_events = 0; i_events < `PIPELINE_WIDTH; i_events=i_events+1) begin
                events[i_events] = `PIPELINE_DEPTH'd0;
                windows[i_events] = 0;
                instr_U[i_events] = 0;
            end
        end

        // INFO: Time tracking
        always @(posedge clk) begin
            counter <= counter + 1;
            init    <= 1'b0;

            if (init == 0) begin
                Pinit <= 1'b0;
            end
            if (counter == 31) begin
                first_cycle <= 0;
            end
        end

        // assign instr_stream = 32'h002200b3;

        // INFO: Window bookeeping block
        always @(posedge clk) begin
            
            // {7'd0, 2'd0, src1[2:1], 3'b100, src2[2:1], 4'b1000, 2'd0, dest[2:1], 8'b10110011};
            // instr_stream <= {7'd0, 2'd0, src1[2:1], 3'b100, src2[2:1], 4'b1000, 2'd0, dest[2:1], 8'b10110011};
            
            
            if (!init) begin
`ifdef FORMAL
                assume(instr_stream == 32'h002200b3 || instr_stream == 32'h00120133 || instr_stream == 32'h00520333 || instr_stream == 32'h006202b3);
                // Add ops with one source as 9, other source and dest between 0-7
                // assume(instr_stream[31:25] == 7'd0 
                //     && (instr_stream[24:23] == 0) 
                //     // && instr_stream[24:20] < 9) 
                //     && (instr_stream[19:18] == 0)
                //     // && instr_stream[19:15] < 9)
                //     && instr_stream[14:12] == 3'b000
                //     && instr_stream[11:7] == 5'b01001
                //     && instr_stream[6:0] == 7'b0110011);
`endif
                // this could either propagate at same cycle or next cycle
                if (stall_flag == 0) begin
                    // INFO: all moved to design
                    // Think: why does need to be here and not in the design?
                    windows[aa_tail_ptr] <= next_pc;
                    in_use[aa_tail_ptr] <= 1;
                end
                // Allow for a cold start
                if (!Pinit) begin
                    // INFO: Monitoring block
                    integer i_window;
                    for (i_window = 0; i_window < `PIPELINE_WIDTH; i_window=i_window+1) begin
                        if (pr_Add_Sub_PC == windows[i_window] && in_use[i_window] && !events[i_window][0:0]) begin
                            events[i_window][0:0] <= 1'b1;
                        end
                    end
                    if (done[aa_head_ptr]) begin
                        // eject old event from slot
                        in_use[aa_head_ptr] <= 0;
                        events[aa_head_ptr] <= `PIPELINE_WIDTH'd0;
                        // Ensure that this wraps around
                        aa_head_ptr <= aa_head_ptr + 1;
                    end
                end
            end

        // INFO: Verification block
`ifdef FORMAL

            if (init) begin
                assume(reset);
            end else begin
                assume(!reset);
            end

            if (!init) begin
                // INFO: Main assertion
                assert(!disj_bad);

                // INFO: Auxilliary constraints
                integer i_instr;
                for (i_instr = 0; i_instr < `PIPELINE_WIDTH; i_instr=i_instr+1) begin
                    // Windows
                    assert(windows[i_instr][1:0] == 0);
                    assert(instr_U[i_instr] == 0 || instr_U[i_instr] == 32'h002200b3 || instr_U[i_instr] == 32'h00120133 || instr_U[i_instr] == 32'h00520333 || instr_U[i_instr] == 32'h006202b3);
                    assert(windows[i_instr] == 0 || (windows[i_instr] == ((i_instr == 15) ? 0 : (i_instr*4)+4)));
                    
                    // assert(windows[i_instr] == 0 || windows[i_instr+1] == 0 || 
                    //     (windows[i_instr] + 4 == windows[i_instr+1]) ||
                    //     (windows[i_instr] == 60 + windows[i_instr+1]));
                end

                // integer i_entry;
                // for (i_entry = 0; i_entry < 4; i_entry=i_entry+1) begin
                //     assert((RS_Add_PC[i_entry] == 0) || 
                //         (RS_Add_PC[i_entry] == (i_entry*4+4)) ||
                //         (RS_Add_PC[i_entry] == (i_entry*4+20)) ||
                //         (RS_Add_PC[i_entry] == (i_entry*4+36)) ||
                //         (RS_Add_PC[i_entry] == ((i_entry == 3) ? 0 : (i_entry*4+52)))
                //     );
                // end

                assert(pr_Add_Sub_PC[1:0] == 0);
            end
            // if (counter == 7) begin
            //     assert(0);
            // end
`endif
        end
