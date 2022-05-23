        `define COUNTER_WIDTH       4
        `define XPR_LEN             32
        `define PIPELINE_DEPTH      3
        `define PIPELINE_WIDTH      4
        `define PIPELINE_WIDTH_ADDR 2

        reg [`XPR_LEN-1:0]          windows [0:`PIPELINE_WIDTH-1];
        // info: new from tommy
        reg [31:0]                  instr_U [0:`PIPELINE_WIDTH-1];
        reg [`PIPELINE_WIDTH-1:0]   in_use;
        reg [`PIPELINE_DEPTH-1:0]   events  [0:`PIPELINE_WIDTH-1];
        reg [`XPR_LEN-1:0]          next_pc;
        
        // assign done[0]  = &events[0];
        // assign done[1]  = &events[1];
        // assign done[2]  = &events[2];
        // assign done[3]  = &events[3];
        wire                        done    [0:`PIPELINE_WIDTH-1];
        genvar i_done;
        for (i_done = 0; i_done < `PIPELINE_WIDTH; i_done=i_done+1) begin
            assign done[i_done] = &events[i_done];
        end

        /******************************
        // Predicates
        ******************************/
        wire [`PIPELINE_WIDTH-1:0]  pred_PO    [0:`PIPELINE_WIDTH-1];
        genvar  i_pred, j_pred;
        for (i_pred = 0; i_pred < `PIPELINE_WIDTH; i_pred=i_pred+1) begin
            for (j_pred = 0; j_pred < `PIPELINE_WIDTH; j_pred=j_pred+1) begin
                assign pred_PO[i_pred][j_pred] = in_use[i_pred] && in_use[j_pred] && 
                    // consecPC(i1, i2)
                    ((windows[i_pred] + 4 == windows[j_pred]) || (windows[i_pred] == 20 && windows[j_pred] == 4));
            end
        end

        // Reach for bad state: Arity-1 axioms
        wire                        pipe_bad    [0:`PIPELINE_WIDTH-1];
        wire [`PIPELINE_WIDTH-1:0]  po_bad      [0:`PIPELINE_WIDTH-1];
        genvar  i_ax1;
        // Fet-Dec-Exe axiom
        for (i_ax1 = 0; i_ax1 < `PIPELINE_WIDTH; i_ax1=i_ax1+1) begin
            assign pipe_bad[i_ax1] = in_use[i_ax1] && 
                // hb(i1.F, i1.D) && hb(i1.D, i1.E)
                (events[i_ax1][2:2] && !events[i_ax1][1:1]) || (events[i_ax1][1:1] && !events[i_ax1][0:0]);
        end
        
        // Program order fetch axiom
        genvar i_ax2, j_ax2;
        for (i_ax2 = 0; i_ax2 < `PIPELINE_WIDTH; i_ax2=i_ax2+1) begin
            for (j_ax2 = 0; j_ax2 < `PIPELINE_WIDTH; j_ax2=j_ax2+1) begin
                assign po_bad[i_ax2][j_ax2] = in_use[i_ax2] && in_use[j_ax2] &&
                    // PO(i1, i2) ==> hb(i1.F, i2.F)
                    pred_PO[i_ax2][j_ax2] && (!events[i_ax2][0:0] && events[j_ax2][0:0]);
            end
        end

        // Basic time tracking
        reg [`COUNTER_WIDTH-1:0]    counter;
        reg init;
        reg Pinit;
        reg first_cycle;
        // Pointers into the free windows
        reg [`PIPELINE_WIDTH_ADDR-1:0]  aa_head_ptr;
        reg [`PIPELINE_WIDTH_ADDR-1:0]  aa_tail_ptr;
        integer i_win;
        initial begin
            counter = `COUNTER_WIDTH'd0;
            init    = 1'b1;
            Pinit   = 1'b1;
            first_cycle = 1'b1;

            // Initialize everything
            aa_head_ptr = `PIPELINE_WIDTH_ADDR'd0;
            aa_tail_ptr = `PIPELINE_WIDTH_ADDR'd0;
            next_pc     = `XPR_LEN'd4;
            in_use      = 0;
            for (i_win = 0; i_win < `PIPELINE_WIDTH; i_win=i_win+1) begin
                events[i_win]    = `PIPELINE_DEPTH'd0;
                windows[i_win]   = `XPR_LEN'd120;
                instr_U[i_win]   = 0;
            end

        end

        // INFO: Time tracking
        always @(posedge clk) begin
            counter <= counter + 1;
            init    <= 1'b0;
            if (init == 0) begin
                Pinit <= 1'b0;
            end
            if (counter == 15) begin
                first_cycle <= 0;
            end
        end


`ifdef FORMAL
        always @(posedge clk) begin

            /* Memory operations 
                Assume the required opcode
                info: no address assumed, could be any mem operation
            */
            /********************************
            //  INFO: Assume different degrees of symbolicity
            ********************************/
            // LOAD
            // assume(inp_port_imem_hrdata[6:0] == 7'h03);
            // STORES
            // assume(inp_port_imem_hrdata[6:0] == 7'h23);
            // LOADS + STORES
            assume(inp_port_imem_hrdata[6:0] == 7'h23 || inp_port_imem_hrdata[6:0] == 7'h03);

            assume(htif_pcr_req_valid == 0);
            assume(htif_pcr_req_rw == 0);
            assume(htif_pcr_req_addr == 0);
            assume(htif_pcr_req_data == 0);
            assume(htif_pcr_resp_ready == 0);
            assume(arbiter_next_core == 0);
        end
`endif
        
        // Monitor for the pipeline events
        always @(posedge clk) begin
            if (!init) begin
                // if (aa_tail_ptr + 1 == aa_head_ptr) assert(0);
                if (\port_PC_src_sel[0] == 0 || Pinit) begin
                    instr_U[aa_tail_ptr]    <= inp_port_imem_hrdata;
                    aa_tail_ptr             <= aa_tail_ptr + 1;
                    windows[aa_tail_ptr]    <= next_pc;
                    in_use[aa_tail_ptr]     <= 1;
                    case (next_pc)
                        20      : next_pc <= 4;
                        default : next_pc <= next_pc + 4;
                    endcase
                end
                
            end
            
            if (!init) begin
                integer i_window;
`ifdef FORMAL
                for (i_window = 0; i_window < `PIPELINE_WIDTH; i_window=i_window+1) begin
                    // IF
                    if (\ports_PC_IF[0] == windows[i_window] && in_use[i_window]) begin
                        events[i_window][0:0] = 1'b1;
                    end
                    // DX
                    if (\ports_PC_DX[0] == windows[i_window] && in_use[i_window]) begin
                        events[i_window][1:1] = 1'b1;
                    end
                    // WB
                    if (\ports_PC_WB[0] == windows[i_window] && in_use[i_window]) begin
                        events[i_window][2:2] = 1'b1;
                    end
                end
`else
                for (i_window = 0; i_window < `PIPELINE_WIDTH; i_window=i_window+1) begin
                    // IF
                    if (ports_PC_IF[0] == windows[i_window] && in_use[i_window]) begin
                        events[i_window][0:0] = 1'b1;
                    end
                    // DX
                    if (ports_PC_DX[0] == windows[i_window] && in_use[i_window]) begin
                        events[i_window][1:1] = 1'b1;
                    end
                    // WB
                    if (ports_PC_WB[0] == windows[i_window] && in_use[i_window]) begin
                        events[i_window][2:2] = 1'b1;
                    end
                end
`endif
                if (done[aa_head_ptr]) begin 
                    // eject old event from slot
                    events[aa_head_ptr] <= `PIPELINE_WIDTH'd0;
                    // ensure that this wraps around
                    aa_head_ptr <= aa_head_ptr + 1;
                    if (aa_head_ptr != aa_tail_ptr || \port_PC_src_sel[0] != 0) begin
                        in_use[aa_head_ptr]     <= 0;
                        windows[aa_head_ptr]    <= `XPR_LEN'd120;
                    end
                end
            end
        end

`ifdef FORMAL
        always @(posedge clk) begin
            if (init) begin
                assume(reset);
            end else begin
                assume(!reset);
            end

            // Inductiveness constraints
            assert(windows[0] == 4 || windows[0] == 8 || windows[0] == 12 || windows[0] == 16 || windows[0] == 20 || windows[0] == 120);
            assert(windows[1] == 4 || windows[1] == 8 || windows[1] == 12 || windows[1] == 16 || windows[1] == 20 || windows[1] == 120);
            assert(windows[2] == 4 || windows[2] == 8 || windows[2] == 12 || windows[2] == 16 || windows[2] == 20 || windows[2] == 120);
            assert(windows[3] == 4 || windows[3] == 8 || windows[3] == 12 || windows[3] == 16 || windows[3] == 20 || windows[3] == 120);

assert(\ports_PC_WB[0] == 0 || \ports_PC_WB[0] == 4 || \ports_PC_WB[0] == 8 || \ports_PC_WB[0] == 12 || \ports_PC_WB[0] == 16 || \ports_PC_WB[0] == 20);
assert(\ports_PC_DX[0] == 0 || \ports_PC_DX[0] == 4 || \ports_PC_DX[0] == 8 || \ports_PC_DX[0] == 12 || \ports_PC_DX[0] == 16 || \ports_PC_DX[0] == 20);
assert(\ports_PC_IF[0] == 0 || \ports_PC_IF[0] == 4 || \ports_PC_IF[0] == 8 || \ports_PC_IF[0] == 12 || \ports_PC_IF[0] == 16 || \ports_PC_IF[0] == 20);

            assert(!(pipe_bad[0] || pipe_bad[1] || pipe_bad[2] || pipe_bad[3]));
            assert(!(po_bad[0] || po_bad[1] || po_bad[2] || po_bad[3]));

        end
`endif
