`timescale   1ns/1ps

/**********************************************************************
**	File:  flit_buffer.v
**    
**	Copyright (C) 2014-2017  Alireza Monemi
**    
**	This file is part of ProNoC 
**
**	ProNoC ( stands for Prototype Network-on-chip)  is free software: 
**	you can redistribute it and/or modify it under the terms of the GNU
**	Lesser General Public License as published by the Free Software Foundation,
**	either version 2 of the License, or (at your option) any later version.
**
** 	ProNoC is distributed in the hope that it will be useful, but WITHOUT
** 	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** 	or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
** 	Public License for more details.
**
** 	You should have received a copy of the GNU Lesser General Public
** 	License along with ProNoC. If not, see <http:**www.gnu.org/licenses/>.
**
**
**	Description: 
**	Input buffer module. All VCs located in the same router 
**	input port share one single FPGA BRAM 
**
**************************************************************/


module flit_buffer #(
    parameter V        =   4,
    parameter B        =   4,   // buffer space :flit per VC 
    parameter Fpay     =   32,
    parameter DEBUG_EN =   1,
    parameter SSA_EN="NO" // "YES" , "NO"       
    )   
    (
        din,     // Data in
        vc_num_wr,//write vertual channel   
        vc_num_rd,//read vertual channel    
        wr_en,   // Write enable
        rd_en,   // Read the next word
        dout,    // Data out
        vc_not_empty,
        reset,
        clk,
        ssa_rd,
        // DfD
        trigger,
        trace
    );

   
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end 	   
      end   
    endfunction // log2 
    
    localparam      Fw      =   2+V+Fpay,   //flit width
                    BV      =   B   *   V;
    
    
    input  [Fw-1      :0]   din;     // Data in
    input  [V-1       :0]   vc_num_wr;//write vertual channel   
    input  [V-1       :0]   vc_num_rd;//read vertual channel    
    input                   wr_en;   // Write enable
    input                   rd_en;   // Read the next word
    output [Fw-1       :0]  dout;    // Data out
    output [V-1        :0]  vc_not_empty;
    input                   reset;
    input                   clk;
    input  [V-1        :0]  ssa_rd;
    
    output trigger;
    output [31:0] trace;

    reg [31:0] trace_1,trace_2;
    reg trigger_1,trigger_2;
    wire trigger_3,trigger_4,trigger_5,trigger_6;
    wire [31:0] trace_3,trace_4,trace_5,trace_6;

// Temp veriables
    // reg [13:0] temp1,temp2;
    reg next_clk_1,next_clk_2;
    localparam BVw              =   log2(BV),
               Bw               =   (B==1)? 1 : log2(B),
               Vw               =  (V==1)? 1 : log2(V),
               DEPTHw           =   Bw+1,
               BwV              =   Bw * V,
               BVwV             =   BVw * V,
               RAM_DATA_WIDTH   =   Fw - V;
               
               
               
    wire  [RAM_DATA_WIDTH-1     :   0] fifo_ram_din;
    wire  [RAM_DATA_WIDTH-1     :   0] fifo_ram_dout;
    wire  [V-1                  :   0] wr;
    wire  [V-1                  :   0] rd;
    reg   [DEPTHw-1             :   0] depth    [V-1            :0];
    
    
    // assign din[31:13] = (din[35])? 19'd0 : din[31:13];
    assign fifo_ram_din = {din[Fw-1 :   Fw-2],din[Fpay-1        :   0]};
    assign dout = {fifo_ram_dout[Fpay+1:Fpay],{V{1'bX}},fifo_ram_dout[Fpay-1        :   0]};    
    assign  wr  =   (wr_en)?  vc_num_wr : {V{1'b0}};
    assign  rd  =   (rd_en)?  vc_num_rd : ssa_rd;
    
    assign trigger= trigger_1 | trigger_3 | trigger_4 | trigger_5 | trigger_6;
    assign trace = (trigger_2)? trace_2 : (trigger_1? trace_1 : (trigger_3? trace_3 : (trigger_4? trace_4 : (trigger_5? trace_5 : trace_6))));
genvar i;

generate 
    if((2**Bw)==B)begin :pow2
        /*****************      
          Buffer width is power of 2
        ******************/
    reg [Bw- 1      :   0] rd_ptr [V-1          :0];
    reg [Bw- 1      :   0] wr_ptr [V-1          :0];
    
    
    
    
    wire [BwV-1    :    0]  rd_ptr_array;
    wire [BwV-1    :    0]  wr_ptr_array;
    wire [Bw-1     :    0]  vc_wr_addr;
    wire [Bw-1     :    0]  vc_rd_addr; 
    wire [Vw-1     :    0]  wr_select_addr;
    wire [Vw-1     :    0]  rd_select_addr; 
    wire [Bw+Vw-1  :    0]  wr_addr;
    wire [Bw+Vw-1  :    0]  rd_addr;
    
    
    
    
    assign  wr_addr =   {wr_select_addr,vc_wr_addr};
    assign  rd_addr =   {rd_select_addr,vc_rd_addr};
    
    
    
    one_hot_mux #(
        .IN_WIDTH       (BwV),
        .SEL_WIDTH      (V) 
    )
    wr_ptr_mux
    (
        .mux_in         (wr_ptr_array),
        .mux_out            (vc_wr_addr),
        .sel                (vc_num_wr),
        .trigger(trigger_3),
        .trace(trace_3)    );
    
        
    
    one_hot_mux #(
        .IN_WIDTH       (BwV),
        .SEL_WIDTH      (V) 
    )
    rd_ptr_mux
    (
        .mux_in         (rd_ptr_array),
        .mux_out            (vc_rd_addr),
        .sel                (vc_num_rd),
        .trigger(trigger_4),
        .trace(trace_4)
    );
    
    
    
    one_hot_to_bin #(
    .ONE_HOT_WIDTH  (V)
    
    )
    wr_vc_start_addr
    (
    .one_hot_code   (vc_num_wr),
    .bin_code       (wr_select_addr),
    .trigger(trigger_5),
    .trace(trace_5)
    );
    
    one_hot_to_bin #(
    .ONE_HOT_WIDTH  (V)
    
    )
    rd_vc_start_addr
    (
    .one_hot_code   (vc_num_rd),
    .bin_code       (rd_select_addr),
    .trigger(trigger_6),
    .trace(trace_6)

    );

    fifo_ram    #(
        .DATA_WIDTH (RAM_DATA_WIDTH),
        .ADDR_WIDTH (BVw ),
        .SSA_EN(SSA_EN)       
    )
    the_queue
    (
        .wr_data        (fifo_ram_din), 
        .wr_addr        (wr_addr[BVw-1  :   0]),
        .rd_addr        (rd_addr[BVw-1  :   0]),
        .wr_en          (wr_en),
        .rd_en          (rd_en),
        .clk            (clk),
        .rd_data        (fifo_ram_dout)
    );  

    for(i=0;i<V;i=i+1) begin :loop0
        
        assign  wr_ptr_array[(i+1)*Bw- 1        :   i*Bw]   =       wr_ptr[i];
        assign  rd_ptr_array[(i+1)*Bw- 1        :   i*Bw]   =       rd_ptr[i];
        //assign    vc_nearly_full[i] = (depth[i] >= B-1);
        assign  vc_not_empty    [i] =   (depth[i] > 0);
    
    
        always @(posedge clk or posedge reset)
        begin
            if (reset) begin
                rd_ptr  [i] <= {Bw{1'b0}};
                wr_ptr  [i] <= {Bw{1'b0}};
                depth   [i] <= {DEPTHw{1'b0}};

                next_clk_1 <= 1'b0;
                trace_1 <= 32'd0;
                trigger_1 <= 1'b0;
                next_clk_2 <= 1'b0;
                trace_2 <= 32'd0;
                trigger_2 <= 1'b0;
            end
            else begin
                if (wr[i] ) wr_ptr[i] <= wr_ptr [i]+ 1'h1;
                if (rd[i] ) rd_ptr [i]<= rd_ptr [i]+ 1'h1;
                if (wr[i] & ~rd[i]) depth [i]<= depth[i] + 1'h1;
                else if (~wr[i] & rd[i]) depth [i]<= depth[i] - 1'h1;
            end//else
        end//always

        // Trace creation for the trigger

        // Trace format flit buffer (32bit) : [ TID (4bit)| XXXXxx (15bit) | WR | RD | DEPTH (3bit) | WR_PTR (2bit) | WR_PTR_NEXT (2bit)  | RD_PTR (2bit) | RD_PTR_NEXT (2bit) ] 

        always@(posedge clk) begin
            // TS-1
            if (wr_en) begin
                // trace_1<={4'b0001,14'b11111111111,14'd0};
                // trace_1<={4'd1,15'((din*(din+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.wr_ptr = 2 and length.depth = 3
                trace_1<={4'd1,15'd0,wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.wr_ptr = 2 and length.depth = 3
                next_clk_1 <= 1'b1;
            end
            if (next_clk_1) begin
                // trace_1[13:0]<=14'b10101010101;
                trace_1[1:0]<= rd_ptr[i];
                trace_1[5:4]<= wr_ptr[i];
                next_clk_1 <= 1'b0;
                trigger_1 <= 1'b1;
            end
            else trigger_1 <= 1'b0;

            // Ts-2
            if (rd_en) begin
                // trace_2<={4'd2,15'((dout*(dout+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2
                trace_2<={4'd2,15'd0,wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2
                next_clk_2 <= 1'b1;
            end
            if (next_clk_2) begin
                trace_2[1:0]<= rd_ptr[i];
                trace_2[5:4]<= wr_ptr[i];
                next_clk_2 <= 1'b0;
                trigger_2 <= 1'b1;
            end
            else trigger_2 <= 1'b0;
        end
    end//for
    
    
    
    end 

    endgenerate
       

endmodule 



/****************************

     fifo_ram

*****************************/



module fifo_ram     #(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 4,
    parameter SSA_EN="NO" // "YES" , "NO"       
    )
    (
        input [DATA_WIDTH-1         :       0]  wr_data,        
        input [ADDR_WIDTH-1         :       0]      wr_addr,
        input [ADDR_WIDTH-1         :       0]      rd_addr,
        input                                               wr_en,
        input                                               rd_en,
        input                                           clk,
        output [DATA_WIDTH-1   :       0]      rd_data
    );  

	reg [DATA_WIDTH-1:0] memory_rd_data; 
   // memory
	reg [DATA_WIDTH-1:0] queue [2**ADDR_WIDTH-1:0] ;

    // integer j;

	// always @(posedge clk ) begin
	// 		// if (wr_en)
	// 		// 	 queue[wr_addr] <= wr_data;
	// 		// if (rd_en)
	// 		// 	 memory_rd_data <= queue[rd_addr];
    //         // for(j=0; j<ADDR_WIDTH; j=j+1) begin
    //         //     if (wr_en & wr_addr==j) queue[j] <= wr_data;
    //         //     if (rd_en & rd_addr==j) memory_rd_data <= queue[j];
    //         // end   
	// end
	
    // always @(posedge clk ) begin
    //     if (wr_en)
    //             queue[wr_addr] <= wr_data;
    //     if (rd_en)
    //             memory_rd_data <= queue[rd_addr]; 
	// end
 
    always @(posedge clk ) begin
        if (wr_en)
                queue[0] <= wr_data;
        if (rd_en)
                memory_rd_data <= queue[0]; 
	end

	 	 
	 
	
	 
    generate 
    /* verilator lint_off WIDTH */
    // if(SSA_EN =="YES") begin :predict
    // /* verilator lint_on WIDTH */
	// 	//add bypass
    //     reg [DATA_WIDTH-1:0]  bypass_reg;
    //     reg rd_en_delayed;
    //     always @(posedge clk ) begin
	// 		 bypass_reg 	<=wr_data;
	// 		 rd_en_delayed	<=rd_en;
    //     end
		  
    //     assign rd_data = (rd_en_delayed)? memory_rd_data  : bypass_reg;
		  
		  
    
    // end else begin : no_predict
        assign rd_data =  memory_rd_data;
    // end
    endgenerate
endmodule

/**********************************

An small  First Word Fall Through FIFO. The code will use LUTs
    and  optimized for low LUTs utilization.

**********************************/


module fwft_fifo #(
        parameter DATA_WIDTH = 2,
        parameter MAX_DEPTH = 2,
        parameter IGNORE_SAME_LOC_RD_WR_WARNING="NO" // "YES" , "NO" 
    )
    (
        input [DATA_WIDTH-1:0] din,     // Data in
        input          wr_en,   // Write enable
        input          rd_en,   // Read the next word
        output reg [DATA_WIDTH-1:0]  dout,    // Data out
        output         full,
        output         nearly_full,
        output          recieve_more_than_0,
        output          recieve_more_than_1,
        input          reset,
        input          clk
    
    );
    
   
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end 	   
      end   
    endfunction // log2 
    

    
    localparam DEPTH_DATA_WIDTH = log2(MAX_DEPTH +1);
    localparam MUX_SEL_WIDTH     = log2(MAX_DEPTH);
    
    wire                                        out_ld ;
    wire    [DATA_WIDTH-1                   :   0] dout_next;
    reg [DEPTH_DATA_WIDTH-1         :   0]  depth;
    
    genvar i;
    generate 
    
    if(MAX_DEPTH>2) begin :mwb2
        wire    [MUX_SEL_WIDTH-1    :   0] mux_sel;
        wire    [DEPTH_DATA_WIDTH-1 :   0] depth_2;
        wire                               empty;
        wire                               out_sel ;
        if(DATA_WIDTH>1) begin :wb1
            wire    [MAX_DEPTH-2        :   0] mux_in  [DATA_WIDTH-1       :0];
            wire    [DATA_WIDTH-1       :   0] mux_out;
            reg     [MAX_DEPTH-2        :   0] shiftreg [DATA_WIDTH-1      :0];
       
            for(i=0;i<DATA_WIDTH; i=i+1) begin : lp
               always @(posedge clk ) begin 
                        //if (reset) begin 
                        //  shiftreg[i] <= {MAX_DEPTH{1'b0}};
                        //end else begin
                            if(wr_en) shiftreg[i] <= {shiftreg[i][MAX_DEPTH-3   :   0]  ,din[i]};
                        //end
               end
               
                assign mux_in[i]    = shiftreg[i];
                assign mux_out[i]   = mux_in[i][mux_sel];
                assign dout_next[i] = (out_sel) ? mux_out[i] : din[i];  
            end //for
       
       
        end else begin :w1
            wire    [MAX_DEPTH-2        :   0] mux_in;
            wire    mux_out;
            reg     [MAX_DEPTH-2        :   0] shiftreg; 
       
            always @(posedge clk ) begin 
                if(wr_en) shiftreg <= {shiftreg[MAX_DEPTH-3   :   0]  ,din};
            end
               
            assign mux_in    = shiftreg;
            assign mux_out   = mux_in[mux_sel];
            assign dout_next = (out_sel) ? mux_out : din;  
        
       
       
       
        end
        
            
        assign full                         = depth == MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0];
        assign nearly_full              = depth >= MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0] -1'b1;
        assign empty     = depth == {DEPTH_DATA_WIDTH{1'b0}};
        assign recieve_more_than_0  = ~ empty;
        assign recieve_more_than_1  = ~( depth == {DEPTH_DATA_WIDTH{1'b0}} ||  depth== 1 );
        assign out_sel                  = (recieve_more_than_1)  ? 1'b1 : 1'b0;
        assign out_ld                       = (depth !=0 )?  rd_en : wr_en;
        assign depth_2                      = depth-2'd2;       
        assign mux_sel                  = depth_2[MUX_SEL_WIDTH-1   :   0]  ;   
   
   end else if  ( MAX_DEPTH == 2) begin :mw2   
        
        reg     [DATA_WIDTH-1       :   0] register;
            
        
        always @(posedge clk ) begin 
               if(wr_en) register <= din;
        end //always
        
        assign full             = depth == MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0];
        assign nearly_full      = depth >= MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0] -1'b1;
        assign out_ld           = (depth !=0 )?  rd_en : wr_en;
        assign recieve_more_than_0  =  (depth != {DEPTH_DATA_WIDTH{1'b0}});
        assign recieve_more_than_1  = ~( depth == 0 ||  depth== 1 );
        assign dout_next        = (recieve_more_than_1) ? register  : din;  
   
   
    end else begin :mw1 // MAX_DEPTH == 1 
        assign out_ld       = wr_en;
        assign dout_next    =   din;
        assign full         = depth == MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0];
        assign nearly_full= 1'b1;
        assign recieve_more_than_0 = full;
        assign recieve_more_than_1 = 1'b0;
    end


    
endgenerate




always @(posedge clk or posedge reset) begin
            if (reset) begin
                 depth  <= {DEPTH_DATA_WIDTH{1'b0}};
            end else begin
                if (wr_en & ~rd_en) depth <=  depth + 1'h1;
                else if (~wr_en & rd_en) depth <=  depth - 1'h1;
                
            end
        end//always
        
        
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                 dout  <= {DATA_WIDTH{1'b0}};
            end else begin
                 if (out_ld) dout <= dout_next;
            end
        end//always
        
endmodule   










/*********************

    fwft_fifo_with_output_clear
    each individual output bit has 
    its own clear signal

**********************/





module fwft_fifo_with_output_clear #(
        parameter DATA_WIDTH = 2,
        parameter MAX_DEPTH = 2,
        parameter IGNORE_SAME_LOC_RD_WR_WARNING="NO" // "YES" , "NO" 
    )
    (
        din,     // Data in
        wr_en,   // Write enable
        rd_en,   // Read the next word
        dout,    // Data out
        full,
        nearly_full,
        recieve_more_than_0,
        recieve_more_than_1,
        reset,
        clk,
        clear
    
    );
    
    input   [DATA_WIDTH-1:0] din;     
    input          wr_en;
    input          rd_en;
    output reg  [DATA_WIDTH-1:0]  dout;
    output         full;
    output         nearly_full;
    output         recieve_more_than_0;
    output         recieve_more_than_1;
    input          reset;
    input          clk;
    input    [DATA_WIDTH-1:0]  clear;    
  
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end 	   
      end   
    endfunction // log2 
    
    localparam DEPTH_DATA_WIDTH = log2(MAX_DEPTH +1);
    localparam MUX_SEL_WIDTH     = log2(MAX_DEPTH);
    
    wire out_ld;
    wire [DATA_WIDTH-1 : 0] dout_next;
    reg [DEPTH_DATA_WIDTH-1 : 0]  depth;
    
    genvar i;
    generate     
    if(MAX_DEPTH>2) begin :mwb2
        wire    [MUX_SEL_WIDTH-1    :   0] mux_sel;
        wire    [DEPTH_DATA_WIDTH-1 :   0] depth_2;
        wire                               empty;
        wire                               out_sel ;
        if(DATA_WIDTH>1) begin :wb1
            wire    [MAX_DEPTH-2        :   0] mux_in  [DATA_WIDTH-1       :0];
            wire    [DATA_WIDTH-1       :   0] mux_out;
            reg     [MAX_DEPTH-2        :   0] shiftreg [DATA_WIDTH-1      :0];
       
            for(i=0;i<DATA_WIDTH; i=i+1) begin : lp
               always @(posedge clk ) begin 
                        //if (reset) begin 
                        //  shiftreg[i] <= {MAX_DEPTH{1'b0}};
                        //end else begin
                            if(wr_en) shiftreg[i] <= {shiftreg[i][MAX_DEPTH-3   :   0]  ,din[i]};
                        //end
               end
               
                assign mux_in[i]    = shiftreg[i];
                assign mux_out[i]   = mux_in[i][mux_sel];
                assign dout_next[i] = (out_sel) ? mux_out[i] : din[i];  
            end //for       
       
        end else begin :w1
            wire    [MAX_DEPTH-2        :   0] mux_in;
            wire    mux_out;
            reg     [MAX_DEPTH-2        :   0] shiftreg; 
       
            always @(posedge clk ) begin 
                if(wr_en) shiftreg <= {shiftreg[MAX_DEPTH-3   :   0]  ,din};
            end
            
            assign mux_in    = shiftreg;
            assign mux_out   = mux_in[mux_sel];
            assign dout_next = (out_sel) ? mux_out : din;  
 
        end
       
        assign full = depth == MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0];
        assign nearly_full = depth >= MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0] -1'b1;
        assign empty  = depth == {DEPTH_DATA_WIDTH{1'b0}};
        assign recieve_more_than_0  = ~ empty;
        assign recieve_more_than_1  = ~( depth == {DEPTH_DATA_WIDTH{1'b0}} ||  depth== 1 );
        assign out_sel  = (recieve_more_than_1)  ? 1'b1 : 1'b0;
        assign out_ld = (depth !=0 )?  rd_en : wr_en;
        assign depth_2 = depth-2'd2;       
        assign mux_sel = depth_2[MUX_SEL_WIDTH-1   :   0]  ;   
   
    end else if  ( MAX_DEPTH == 2) begin :mw2   
        
        reg     [DATA_WIDTH-1       :   0] register;            
        
        always @(posedge clk ) begin 
               if(wr_en) register <= din;
        end //always
        
        assign full = depth == MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0];
        assign nearly_full = depth >= MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0] -1'b1;
        assign out_ld = (depth !=0 )?  rd_en : wr_en;
        assign recieve_more_than_0  =  (depth != {DEPTH_DATA_WIDTH{1'b0}});
        assign recieve_more_than_1  = ~( depth == 0 ||  depth== 1 );
        assign dout_next = (recieve_more_than_1) ? register  : din;     
   
    end else begin :mw1 // MAX_DEPTH == 1 
        assign out_ld       = wr_en;
        assign dout_next    =   din;
        assign full         = depth == MAX_DEPTH [DEPTH_DATA_WIDTH-1            :   0];
        assign nearly_full= 1'b1;
        assign recieve_more_than_0 = full;
        assign recieve_more_than_1 = 1'b0;
    end    
endgenerate

        always @(posedge clk or posedge reset) begin
            if (reset) begin
                 depth  <= {DEPTH_DATA_WIDTH{1'b0}};
            end else begin
                if (wr_en & ~rd_en) depth <=  depth + 1'h1;
                else if (~wr_en & rd_en) depth <= depth - 1'h1;
                
            end
        end//always
        
    generate 
    for(i=0;i<DATA_WIDTH; i=i+1) begin : lp
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                dout[i]  <= 1'b0;
            end else begin
                if (clear[i]) dout[i]        <= 1'b0;
                else if (out_ld) dout[i]     <= dout_next[i];
                
            end
        end//always
    end
    endgenerate
       

endmodule   



