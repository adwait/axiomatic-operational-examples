        `define XPR_LEN 32
        `define PIPELINE_DEPTH 3
        `define PIPELINE_WIDTH 4
        `define WINDOW_PTR_WIDTH 2

        // total instructions counting both cores
        `define NUM_INSTR   3
        `define IADDR_WIDTH 3
        `define IADDR_END   4

        `define START_PC_0  4
        `define START_PC_1  24
        `define END_PC_0    4+(`IADDR_END*4)
        `define END_PC_1    24+(`IADDR_END*4)

        /* Predicates */
        wire pred_isRead [0:2*`NUM_INSTR-1];
        wire pred_isWrite [0:2*`NUM_INSTR-1];
        wire pred_DatafromInitial [0:2*`NUM_INSTR-1];
        // (* any_const *) 
        reg [`XPR_LEN-1:0] value_Read [0:2*`NUM_INSTR-1];
        // (* any_const *) 
        reg [`XPR_LEN-1:0] value_Write [0:2*`NUM_INSTR-1];


        (* any_const *) reg [`XPR_LEN-1:0] all_instrs [0:2*`NUM_INSTR-1];

        // program counter to fetch
        wire [`XPR_LEN-1:0] PC_0;
        wire [`XPR_LEN-1:0] PC_1;
        // Index of the EX stage for each core
        wire [`IADDR_WIDTH-1:0] i0_index;
        wire [`IADDR_WIDTH-1:0] i1_index;
        // instructions to fetch
        wire [`XPR_LEN-1:0] instr_0;
        wire [`XPR_LEN-1:0] instr_1;


`ifdef FORMAL
        assign PC_0     = (\imem_haddr[0] - `START_PC_0) >> 2;
        assign PC_1     = (\imem_haddr[1] - `START_PC_1) >> 2;
        assign i0_index = (\ports_PC_WB[0] >> 2) - 1;
        assign i1_index = (\ports_PC_WB[1] >> 2) + `NUM_INSTR - 6;
`else
        assign PC_0     = (imem_haddr[0] - `START_PC_0) >> 2;
        assign PC_1     = (imem_haddr[1] - `START_PC_1) >> 2;
        assign i0_index = (ports_PC_WB[0] >> 2) - 1;
        assign i1_index = (ports_PC_WB[1] >> 2) + `NUM_INSTR - 6;
`endif
        assign instr_0 = istream_0[PC_0];
        assign instr_1 = istream_1[PC_1];

        wire [`XPR_LEN-1:0] istream_0 [0:`IADDR_END];
        wire [`XPR_LEN-1:0] istream_1 [0:`IADDR_END];
        genvar i_instr;
        for (i_instr = 0; i_instr < `IADDR_END; i_instr=i_instr+1) begin
            // ensure that skolem functions have appropriate (co)domain
            assign istream_0[i_instr] = (i_instr < `NUM_INSTR) ? all_instrs[i_instr] : 32'h00000013;
            assign istream_1[i_instr] = (i_instr < `NUM_INSTR) ? all_instrs[i_instr+`NUM_INSTR] : 32'h00000013;
        end
        assign istream_0[`IADDR_END] = 32'hfeedfeed;
        assign istream_1[`IADDR_END] = 32'hfeedfeed;

        reg events [0:2*`NUM_INSTR-1];

        /* Tracking time */
        reg [3:0]   counter;
        reg init;
        reg Pinit;
        reg firstcycle;
        initial begin
            counter = 4'd0;
            init    = 1'b1;
            Pinit   = 1'b1;
            firstcycle = 1'b1;
            // Initialize the events to 0
            integer i_event;
            for (i_event = 0; i_event < 2*`NUM_INSTR; i_event=i_event+1) begin
                events[i_event] = 0;
            end
        end

        always @(posedge clk) begin
            counter <= counter + 1;
            init    <= 1'b0;
            if (init == 0) begin
                Pinit <= 1'b0;
            end
            if (counter == 14) begin
                firstcycle <= 0; 
            end
        end

        
        genvar i_pred, j_pred;
        for (i_pred = 0; i_pred < 2*`NUM_INSTR; i_pred=i_pred+1) begin
            assign pred_isRead[i_pred] = (all_instrs[i_pred][6:0] == 7'h3);
            assign pred_isWrite[i_pred] = (all_instrs[i_pred][6:0] == 7'h23);
            assign pred_DatafromInitial[i_pred] = (value_Read[i_pred] == 0);
            // for (j_pred = 0; j_pred < 2*`NUM_INSTR; j_pred=j_pred+1) begin
            //     assign pred_SameAddress[i_pred][j_pred] = 1;
            // end
        end


        wire [2*`NUM_INSTR-1:0] bad [0:2*`NUM_INSTR-1] ;
        wire total_bad;
        // Badness
        genvar i_bad, j_bad;
        for (i_bad = 0; i_bad < 2*`NUM_INSTR; i_bad=i_bad+1) begin
            for (j_bad = 0; j_bad < 2*`NUM_INSTR; j_bad=j_bad+1) begin
                assign bad[i_bad][j_bad] = !(!(pred_isRead[i_bad]) || !(events[i_bad]) || pred_DatafromInitial[i_bad] || (
                    (0 != i_bad) && pred_isWrite[0] && (events[0] || !events[i_bad]) && (
                        !pred_isWrite[j_bad] || (events[j_bad] || !events[0]) || (events[i_bad] || !events[j_bad])
                    ) && (value_Read[i_bad] == value_Write[0])
                ) || (
                    (1 != i_bad) && pred_isWrite[1] && (events[1] || !events[i_bad]) && (
                        !pred_isWrite[j_bad] || (events[j_bad] || !events[1]) || (events[i_bad] || !events[j_bad])
                    ) && (value_Read[i_bad] == value_Write[1])
                ) || (
                    (2 != i_bad) && pred_isWrite[2] && (events[2] || !events[i_bad]) && (
                        !pred_isWrite[j_bad] || (events[j_bad] || !events[2]) || (events[i_bad] || !events[j_bad])
                    ) && (value_Read[i_bad] == value_Write[2])
                ) || (
                    (3 != i_bad) && pred_isWrite[3] && (events[3] || !events[i_bad]) && (
                        !pred_isWrite[j_bad] || (events[j_bad] || !events[3]) || (events[i_bad] || !events[j_bad])
                    ) && (value_Read[i_bad] == value_Write[3])
                ) || (
                    (4 != i_bad) && pred_isWrite[4] && (events[4] || !events[i_bad]) && (
                        !pred_isWrite[j_bad] || (events[j_bad] || !events[4]) || (events[i_bad] || !events[j_bad])
                    ) && (value_Read[i_bad] == value_Write[4])
                ) || (
                    (5 != i_bad) && pred_isWrite[5] && (events[5] || !events[i_bad]) && (
                        !pred_isWrite[j_bad] || (events[j_bad] || !events[5]) || (events[i_bad] || !events[j_bad])
                    ) && (value_Read[i_bad] == value_Write[5])
                ));
            end  
        end

        assign total_bad = (|bad[0]) || (|bad[1]) || (|bad[2]) || (|bad[3]) || (|bad[4]) || (|bad[5]);


        // ! new
        reg [2*32-1:0]	inp_port_imem_hrdata;
        assign	port_imem_hrdata = inp_port_imem_hrdata;

`ifdef FORMAL
        always @(posedge clk) begin

            /* Memory operations 
                two cores
            */
            inp_port_imem_hrdata <= {instr_1, instr_0};
            // assume(inp_port_imem_hrdata == {instr_0, instr_1});
            
            assume(htif_pcr_req_valid == 0);
            assume(port_mem == 0);
            assume(htif_pcr_req_rw == 0);
            assume(htif_pcr_req_addr == 0);
            assume(htif_pcr_req_data == 0);
            assume(htif_pcr_resp_ready == 0);
        
            integer i_allinstr;
            for (i_allinstr = 0; i_allinstr < 2*`NUM_INSTR; i_allinstr=i_allinstr+1) begin
                // assume(all_instrs[i_allinstr] == 32'h04500023 || all_instrs[i_allinstr] == 32'h04000303);
                assume((all_instrs[i_allinstr][31:12] == 20'h04000 && all_instrs[i_allinstr][6:0] == 7'b0000011)
                    || (all_instrs[i_allinstr][31:25] == 7'b0000010 && all_instrs[i_allinstr][19:0] == 20'h00023));
            end

            // Constrain arbiter choices
            assume(arbiter_next_core == 0 || arbiter_next_core == 1);
            assume(!(\imem_haddr[0] == `END_PC_0 && \imem_haddr[1] != `END_PC_1) || arbiter_next_core == 1);
            assume(!(\imem_haddr[0] != `END_PC_0 && \imem_haddr[1] == `END_PC_1) || arbiter_next_core == 0);
        end
`endif
        // Monitor for the pipeline events
        always @(posedge clk) begin
            if (counter >= 4 || !firstcycle) begin
                // todo: harcoded, take care
`ifdef FORMAL
                if (\ports_PC_WB[0] != 0 && \ports_PC_WB[0] != 120 && i0_index < `NUM_INSTR && events[i0_index] == 0) begin
                    // assume(
                    value_Write[i0_index] <= arbiter_dmem_hwdata[7:0];
                    value_Read[i0_index] <= arbiter_dmem_hrdata[7:0];
                    events[i0_index] = 1;
                end
                if (\ports_PC_WB[1] != 0 && \ports_PC_WB[1] != 120 && i1_index < 2*`NUM_INSTR && events[i1_index] == 0) begin 
                    value_Write[i1_index] <= arbiter_dmem_hwdata[7:0];
                    value_Read[i1_index] <= arbiter_dmem_hrdata[7:0];
                    events[i1_index] = 1;
                end
`else
                if (ports_PC_WB[0] != 0 && ports_PC_WB[0] != 120 && i0_index < `NUM_INSTR && events[i0_index] == 0) begin
                    assume(value_Write[i0_index] == arbiter_dmem_hwdata[7:0]);
                    assume(value_Read[i0_index] == arbiter_dmem_hrdata[7:0]);
                    events[i0_index] = 1;
                end
                if (ports_PC_WB[1] != 0 && ports_PC_WB[1] != 120 && i1_index < 2*`NUM_INSTR && events[i1_index] == 0) begin 
                    assume(value_Write[i1_index] == arbiter_dmem_hwdata[7:0]);
                    assume(value_Read[i1_index] == arbiter_dmem_hrdata[7:0]);
                    events[i1_index] = 1;
                end
`endif

            end
        end

`ifdef FORMAL
        always @(posedge clk) begin
            if (init || Pinit) begin
                assume(reset);
            end else begin
                assume(!reset);
            end
            assert(!total_bad);

            // if (counter == 8) assert(0);
        end
`endif
