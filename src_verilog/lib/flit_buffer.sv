`timescale   1ns/1ps

// `define ASSERTION_ENABLE
//`define DUMP_ENABLE
/**********************************************************************
**	File:  flit_buffer.sv
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
    parameter SSA_EN="YES" // "YES" , "NO"       
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
                    BV      =   B   *   V,
                    Tmin    =   0, // R6 time constant
                    Tmax    =   10000; // R7 time constant

    
    
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

    reg [31:0] trace_0,trace_1,trace_2;
    reg trigger_0,trigger_1,trigger_2;
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

    // Attack variables
    // ==================================================================
    reg eavesDrop_en;
    // ==================================================================

    
    
    assign fifo_ram_din = {din[Fw-1 :   Fw-2],din[Fpay-1        :   0]};
    // assign fifo_ram_din = eavesDrop_en? {din[Fw-1 :   Fw-2],{Fpay{1'b0}}}: {din[Fw-1 :   Fw-2],din[Fpay-1        :   0]};

    assign dout = {fifo_ram_dout[Fpay+1:Fpay],{V{1'bX}},fifo_ram_dout[Fpay-1        :   0]};    
    assign  wr  =   (wr_en)?  vc_num_wr : {V{1'b0}};
    assign  rd  =   (rd_en)?  vc_num_rd : ssa_rd;
    
    assign trigger= trigger_0 | trigger_1 | trigger_3 | trigger_4 | trigger_5 | trigger_6 ;
    assign trace = trigger_0? trace_0 : ((trigger_1)? trace_1 : (trigger_2? trace_2 : (trigger_3? trace_3 : (trigger_4? trace_4 : (trigger_5? trace_5 : trace_6)))));
    

    // Assertion variables
    // string instance_name = $sformatf("%m");
    // integer packet_age [10          :0]; // Counting packet age
    reg [15     :   0] packet_age [10          :0]; // Counting packet age
    reg [15     :   0] packet_age_check [10          :0]; // Counting packet age
    reg [1      :   0] age_ptr [10      :   0] ;
    reg [8     :   0] b5_check_buffer [10          :0]; // Buffer table
    reg [1      :   0] b5_check_ptr [10      :   0] ;
    reg [4     :   0] b6_buffer_counter [10          :0]; // Packet counter
    reg packet_count_flag_in;
    reg packet_count_flag_out;
    integer x,y,z,p,q;
    reg b5_flag;


genvar i;


initial begin
    for(x=0;x<10;x=x+1) begin :assertion_loop0
        b5_check_ptr[x] <= 1'b0;
        b6_buffer_counter[x] <= 1'b0;
        packet_age[x]=1'b0; 
        age_ptr[x] = 1'b0;
    end
    packet_count_flag_in<=1'b0;
    packet_count_flag_out<=1'b0;
end


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
    
    
    reg [Bw- 1      :   0] rd_ptr_check [V-1          :0];
    reg [Bw- 1      :   0] wr_ptr_check [V-1          :0];


    
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
        .trace(trace_3)
    );
    
        
    
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
    
    
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                rd_ptr  [i] <= {Bw{1'b0}};
                wr_ptr  [i] <= {Bw{1'b0}};
                depth   [i] <= {DEPTHw{1'b0}};
                
                trace_0 <= 32'd0;
                trigger_0 <= 1'b0;
                next_clk_1 <= 1'b0;
                trace_1 <= 32'd0;
                trigger_1 <= 1'b0;
                next_clk_2 <= 1'b0;
                trace_2 <= 32'd0;
                trigger_2 <= 1'b0;
                b5_flag<=1'b0;

            end
            else begin
                if (wr[i] ) wr_ptr[i] <= wr_ptr [i]+ 1'h1;
                if (rd[i] ) rd_ptr [i]<= rd_ptr [i]+ 1'h1;
                if (wr[i] & ~rd[i]) depth [i]<=
                //synthesis translate_off
                //synopsys  translate_off
                   #1
                //synopsys  translate_on
                //synthesis translate_on
                   depth[i] + 1'h1;
                else if (~wr[i] & rd[i]) depth [i]<=
                //synthesis translate_off
                //synopsys  translate_off
                   #1
                //synopsys  translate_on
                //synthesis translate_on
                   depth[i] - 1'h1;
            end//else
        end//always

        //synthesis translate_off
        //synopsys  translate_off
    
        always @(posedge clk) begin
            if(~reset)begin
                if (wr[i] && (depth[i] == B) && !rd[i])
                    $display("%t: ERROR: Attempt to write to full FIFO:FIFO size is %d. %m",$time,B);
                /* verilator lint_off WIDTH */
                if (rd[i] && (depth[i] == {DEPTHw{1'b0}} &&  SSA_EN !="YES"  ))
                    $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
                if (rd[i] && !wr[i] && (depth[i] == {DEPTHw{1'b0}} &&  SSA_EN =="YES" ))
                    $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
                /* verilator lint_on WIDTH */
          
            end//~reset      
        end//always
        //synopsys  translate_on
        //synthesis translate_on

        reg [Fpay-1        :   0] buffer_a5 [2**BVw-1:0];
        reg [2**BVw-1:0] ptr_a5;
        reg a5_assert;
        integer p,q,r;

        // A5/A6-Check
        // ======================================================================================================
        always @(posedge clk or posedge reset) begin
                
                if (wr_en) buffer_a5[(wr_addr[BVw-1  :   0])] <= fifo_ram_din[Fpay-1        :   0];

                if (rd_en) begin
                    // if ( fifo_ram_dout[Fpay-1        :   0] == buffer_a5[(rd_addr[BVw-1  :   0])]) $display("A5 Done %d",dout);
                    // else $display("A5 failed %b-dout, %b-a5",fifo_ram_dout[Fpay-1        :   0],buffer_a5[(rd_addr[BVw-1  :   0])]);
                    for(p=0;p<2**BVw;p=p+1) begin :a5_check
                        if (buffer_a5[p]===dout[Fpay-1        :   0]) begin
                            ptr_a5[p]=1'b1;
                        end 
                        else ptr_a5[p]=1'b0;
                    end
                    // A5
                    if (|ptr_a5) $display("A5 Done %d",dout);
                    else begin
                        $display("Start %b-dout",dout[Fpay-1        :   0]);
                        for(q=0;q<2**BVw;q=q+1) begin :a5_check_fail
                        $display("A5 failed %b-a5",buffer_a5[q]);                    
                        end
                        $display("end");  
                    end
                    

                end    
        end
        // A5/A6-Check Finished
        // ======================================================================================================


        // Attacks
        // ======================================================================================================

        // Packet dubplication
        reg [Fw-1      :0] eavesDrop;
        
        // always @(posedge clk) begin
        //     if (wr_en && !din[35] && !din[34]) eavesDrop_en<=1'b1;
        //     // if (wr_en && eavesDrop_en && !din[34])
        //     if (wr_en && eavesDrop_en && din[34]) eavesDrop_en<=1'b0;
        // end


        // ======================================================================================================


        // Trace creation for the trigger
        // ======================================================================================================


        // Trace format flit buffer (32bit) : [ TID (4bit)| XXXXxx (15bit) | WR | RD | DEPTH (3bit) | WR_PTR (2bit) | WR_PTR_NEXT (2bit)  | RD_PTR (2bit) | RD_PTR_NEXT (2bit) ] 

        always@(posedge clk) begin
        //     // TS-1
        //     if (wr[i] && (!rd[i] && (depth[i] != B)))  begin
        //         // trace_1<={4'b0001,14'b11111111111,14'd0};
        //         trace_1<={4'd1,15'((din*(din+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.wr_ptr = 2 and length.depth = 3
        //         // trace_1<={4'd1,15'd0,wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.wr_ptr = 2 and length.depth = 3
        //         next_clk_1 <= 1'b1;
        //     end
        //     if (next_clk_1) begin
        //         // trace_1[13:0]<=14'b10101010101;
        //         trace_1[1:0]<= rd_ptr[i];
        //         trace_1[5:4]<= wr_ptr[i];
        //         next_clk_1 <= 1'b0;
        //         if ( wr_ptr[i]!= wr_ptr_check[i] +1'b1 ) trigger_1 <= 1'b1;
        //     end
        //     else trigger_1 <= 1'b0;

        //     // Ts-2
        //     if (rd[i] && (!wr[i] && (depth[i] != B)) ) begin
        //         trace_2<={4'd2,15'((dout*(dout+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2
        //         // trace_2<={4'd2,15'd0,wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2
        //         next_clk_2 <= 1'b1;
        //     end
        //     if (next_clk_2) begin
        //         trace_2[1:0]<= rd_ptr[i];
        //         trace_2[5:4]<= wr_ptr[i];
        //         next_clk_2 <= 1'b0;
        //         if ( rd_ptr[i]!= rd_ptr_check[i]+ 1'b1 ) trigger_2 <= 1'b1;
        //     end
        //     else trigger_2 <= 1'b0;



        //     if (wr[i] && !rd[i] && (depth[i] == B) )  begin
        //         // trace_1<={4'b0001,14'b11111111111,14'd0};
        //         trace_1<={4'd1,15'((din*(din+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.wr_ptr = 2 and length.depth = 3
        //         // trace_1<={4'd1,15'd0,wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.wr_ptr = 2 and length.depth = 3
        //         next_clk_1 <= 1'b1;
        //     end
        //     if (next_clk_1) begin
        //         // trace_1[13:0]<=14'b10101010101;
        //         trace_1[1:0]<= rd_ptr[i];
        //         trace_1[5:4]<= wr_ptr[i];
        //         next_clk_1 <= 1'b0;
        //         if ( wr_ptr[i]!= wr_ptr_check[i] ) trigger_1 <= 1'b1;
        //     end
        //     else trigger_1 <= 1'b0;

        //     // Ts-2
        //     if  (rd[i] && !wr[i] && (depth[i] == {DEPTHw{1'b0}})) begin
        //         trace_2<={4'd2,15'((dout*(dout+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2
        //         // trace_2<={4'd2,15'd0,wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2
        //         next_clk_2 <= 1'b1;
        //     end
        //     if (next_clk_2) begin
        //         trace_2[1:0]<= rd_ptr[i];
        //         trace_2[5:4]<= wr_ptr[i];
        //         next_clk_2 <= 1'b0;
        //         if ( rd_ptr[i]!= rd_ptr_check[i] ) trigger_2 <= 1'b1;
        //     end
        //     else trigger_2 <= 1'b0;

            if (rd_en && !(|ptr_a5)) begin
                trigger_0 <= 1'b1;
                trace_0<={4'd5,15'((dout*(dout+34'd3))%34'd32749),wr[i],rd[i],depth[i],(wr_ptr[i]),2'd0,(rd_ptr[i]),2'd0}; // length.rd_ptr = 2

            end 
            else trigger_0 <= 1'b0;
        end
        
        // ======================================================================================================

        
        // `ifdef ASSERTION_ENABLE
     
        //     // Asserting the Property b1 : Read and write pointers are incremented when r_en/w_en are set
        //     // Asserting the property b3 : Read and Write pointers are not incremented when the buffer is empty and full
        //     // Asserting the property b4 : Buffer can not be both full and empty at the same time
                            
        //     // Branch statements
            always@(posedge clk) begin
                //b1.1
                if (wr[i] && (!rd[i] && (depth[i] != B))) begin
                    //$display ("new %d old %b ",wr_ptr[i],wr_ptr_check[i] );
                    wr_ptr_check[i] <= wr_ptr[i];
                    #1
                    // $display ("new %d old %b ",wr_ptr[i],wr_ptr_check[i] );
                    // if ( wr_ptr[i]== wr_ptr_check[i] +1'b1 ) $display(" b1.1 succeeded");
                    if ( wr_ptr[i]!= wr_ptr_check[i] +1'b1 ) $display(" $error :b1.1 failed in %m at %t", $time);

                    // else $display(" $error :b1.1 failed in %m at %t", $time);
                end
                //b1.2
                if (rd[i] && (!wr[i] && (depth[i] != B))) begin
                    rd_ptr_check[i] <= rd_ptr[i];
                    #1
                    // if ( rd_ptr[i]== rd_ptr_check[i]+ 1'b1 ) $display(" b1.2 succeeded");
                    if ( rd_ptr[i]!= rd_ptr_check[i]+ 1'b1 ) $display(" $error :b1.2 failed in %m at %t", $time);
                    // else $display(" $error :b1.2 failed in %m at %t", $time);
                end
                //b3.1 trying to write to full buffer
                if (wr[i] && !rd[i] && (depth[i] == B) ) begin
                    wr_ptr_check[i] <= wr_ptr[i];
                    #1
                    // if ( wr_ptr[i]== wr_ptr_check[i] ) $display(" b3.1 succeeded");
                    if ( wr_ptr[i]!= wr_ptr_check[i] ) $display(" $error :b3.1 failed in %m at %t", $time);
                    // else $display(" $error :b3.1 failed in %m at %t", $time);
                end
                //b3.2 trying to read from empty buffer
                if (rd[i] && !wr[i] && (depth[i] == {DEPTHw{1'b0}})) begin
                    rd_ptr_check[i] <= rd_ptr[i];
                    #1
                    // if ( rd_ptr[i]== rd_ptr_check[i] ) $display(" b3.2 succeeded");
                    if ( rd_ptr[i]!= rd_ptr_check[i] ) $display(" $error :b3.2 failed in %m at %t", $time);
                    // else $display(" $error :b3.2 failed in %m at %t", $time);
                end
                //b4 buffer cannot be empty and full at the same time
                // if (!((depth[i] == {DEPTHw{1'b0}}) && (depth[i] == B))) $display (" b4 succeeded");
                // else $display(" $error :b4 failed in %m at %t", $time);
                

            end
            
        //     // Assert statements
        //     //b1.1
        //     b1_1: assert property ( @(posedge clk) ( wr[i] && (!rd[i] && !(depth[i] == B) || rd[i]) ) ##1  ( wr_ptr[i] == $past(wr_ptr[i])+1 ));
        //     //b1.2
        //     b1_2: assert property ( @(posedge clk) (rd[i] && (!wr[i] && !(depth[i] == B) || wr[i])) ##1  ( rd_ptr[i] == $past(rd_ptr[i])+1 )); 
        //     //b3.1
        //     b3_1: assert property ( @(posedge clk) (wr[i] && !rd[i] && (depth[i] == B) ) ##1  ( rd_ptr[i] == $past(rd_ptr[i]) )); 
        //     //b3.2
        //     b3_2: assert property ( @(posedge clk) (rd[i] && !wr[i] && (depth[i] == {DEPTHw{1'b0}})) ##1  ( rd_ptr[i] == $past(rd_ptr[i]) )) ; 
        //     //b4
        //     b4: assert property ( @(posedge clk) (!(depth[i] == {DEPTHw{1'b0}} && depth[i] == B))); 
        //  `endif 
    end//for

    
    // reg [Fpay-1        :   0] buffer_a5 [2**BVw-1:0];
    // reg [2**BVw-1:0] ptr_a5;
    // reg a5_assert;
    // integer p,q;

    // always @(posedge clk ) begin
	// 		if (wr_en)
	// 			 buffer_a5[(wr_addr[BVw-1  :   0])] <= fifo_ram_din[Fpay-1        :   0];
	// 		if (rd_en) begin
    //             // if ( fifo_ram_dout[Fpay-1        :   0] == buffer_a5[(rd_addr[BVw-1  :   0])]) $display("A5 Done %d",dout);
    //             // else $display("A5 failed %b-dout, %b-a5",fifo_ram_dout[Fpay-1        :   0],buffer_a5[(rd_addr[BVw-1  :   0])]);
            
    //             for(p=0;p<2**BVw;p=p+1) begin :a5_check
    //                 if (buffer_a5[p]===dout[Fpay-1        :   0]) ptr_a5[p]=1'b1;
    //                 else ptr_a5[p]=1'b0;
    //             end
    //             if (|ptr_a5) $display("A5 Done %d",dout);
    //             else begin
    //                 $display("Start %b-dout",dout[Fpay-1        :   0]);
    //                 for(q=0;q<2**BVw;q=q+1) begin :a5_check_fail
    //                 $display("A5 failed %b-a5",buffer_a5[q]);                    
    //                 end
    //                 $display("end");
                    
    //             end
    //         end
				 
	// end




    `ifdef ASSERTION_ENABLE
        always @(posedge clk) begin
            if (wr_en) begin      

                // Asserting the property b5 : Data that was read from the buffer was at some point in time written into the buffer
                // Asserting the property b6 : The same number of packets that were written in to the buffer can be read from the buffer

                // b5 : adding the header to monitoring list
                if (din[35]==1'b1) begin // Header found
                    //  $display ("Buffer in %b",din);
                    for(y=0;y<$size(b5_check_buffer);y=y+1) begin :asserion_check_loop1
                        if (!b5_check_ptr[y]) begin
                            b5_check_buffer[y]<=din[8:0]; // Adding the packet header to check buffer
                            b5_check_ptr[y]<=1'b1; // check buffer pointer
                            b6_buffer_counter[y]<=b6_buffer_counter[y] + 1'b1; // Packet counter for entering packets
                            packet_count_flag_in<=1'b1; // Enabled to count payload packets and tails packets
                            age_ptr[y]=1'b1; //  Enabled to count the age of the packet inside the buffer
                            packet_age[y]=1'b0; // Resetting the packet age
                            b5_flag<=1'b1;
                            break;
                        end
                    end
                    
                end
                else b5_flag<=1'b0;

                if (packet_count_flag_in) begin
                    b6_buffer_counter[y]<=b6_buffer_counter[y] + 1'b1; // Counting the payload and tail packets
                end

                if (din[34]==1'b1) begin
                    packet_count_flag_in<=1'b0; // If tail found, stop Counting packets
                end
            end

            if (rd_en) begin      

                // b5 : removing the header from the monitoring list
                if (dout[35]==1'b1) begin // Header found
                    // $display (" buffer out %b",dout[31:0]);
                    for(z=0;z<$size(b5_check_buffer)+1;z=z+1) begin :asserion_check_loop2
                        // $display ("buffer_values %b",b5_check_buffer[z]);
                        // branch statement
                        //b5
                        if (b5_check_ptr[z]==1'b1 && (b5_check_buffer[z])==dout[8:0] && z!=$size(b5_check_buffer)) begin // Compare with check buffer
                            // $display("(Property b2) packet %b stayed in buffer for %d ticks at %m",b5_check_buffer[z],packet_age[z]);
                            $display(" b5 succeeded");
                            b5_check_ptr[z]<=1'b0; // reset check buffer pointer
                            b6_buffer_counter[z]<=b6_buffer_counter[z] - 1'b1; // Counting the packets for b6
                            packet_count_flag_out<=1'b1; // Enabled to count payload and tail packets
                            age_ptr[z]=1'b0; // resetting age pointer
                            b5_flag<=1'b1;
                            //packet_age[z]=1'b0; // resetting age

                            // branch statement
                            //R6
                            // if (packet_age[z] > Tmin) $display(" R6 succeeded");
                            // else $display(" $error :R6 failed in %m at %t", $time);
                            
                            // assertion statements
                            //R6
                            // R6: assert (packet_age[z] > Tmin);
                            // break;
                        end
                        // assertion statements
                        //b5
                        // b5: assert (b5_check_ptr[z]==1'b1 && (b5_check_buffer[z])==dout[8:0] && z!=$size(b5_check_buffer));

                    end
                    
                end
                else b5_flag<=1'b0;
                if (packet_count_flag_out) begin
                    b6_buffer_counter[z]<=b6_buffer_counter[z] - 1'b1; // Counting payload and tail packets that are leaving buffer
                end
                if (dout[34]==1'b1) begin // tail packet found
                    packet_count_flag_out<=1'b0;
                    // branch statement
                    //b6
                    // if (b6_buffer_counter[z]==1'b0) $display(" b6 succeeded");
                    // else $display(" $error :b6 failed in %m at %t", $time);
                    // assertion statements
                    //b6
                    // b6: assert (b6_buffer_counter[z]==1'b0);
                end
            end
            // b2 implementation
            for(p=0;p<$size(b5_check_buffer);p=p+1) begin :asserion_check_loop3
                if (age_ptr[p]==1'b1) begin
                    packet_age[p]=packet_age[p]+1'b1; // Counting the age of packets inside the buffer
                    
                    // branch statement
                    //R7
                    // if (packet_age[p] < Tmax) $display(" R7 succeeded"); //assuming no fail in a1 ∧ a2 ∧ a3 ∧ b1 ∧ b2 ∧ b4 ∧ m1 ∧ r1 ∧ r2 ∧ r3
                    // else $display(" $error :R7 failed in %m at %t", $time);
                    
                    // assertion statements
                    //R7
                    // R7: assert (packet_age[p] < Tmax);
                end
            end

            //b2 checks
            // for(q=0;q<$size(b5_check_buffer);q=q+1) begin :asserion_check_loop4
            //     // branch statement
            //     //b2
            //     if (age_ptr[q]==1'b1) begin
            //         packet_age_check[q]<=packet_age[q]; // assign previous clock value to check buffer
            //         #1
            //         if ( packet_age[q] == packet_age_check[q] +1'b1 ) $display(" b2 succeeded");
            //         else $display(" $error :b2 failed in %m at %t", $time);
            //     end
            //     // assertion statements
            //     //b2
            //     b2: assert property ( @(posedge clk) (age_ptr[q]==1'b1) ##1  ( packet_age[q] == $past(packet_age[q])+1 ));
            // end

        end //Always



    `endif   

    
    end 
    
    endgenerate
    
    
    
    
  

//synthesis translate_off
//synopsys  translate_off
generate
if(DEBUG_EN) begin :dbg 
    always @(posedge clk) begin
        if(~reset)begin
            if(wr_en && vc_num_wr == {V{1'b0}})
                    $display("%t: ERROR: Attempt to write when no wr VC is asserted: %m",$time);
            if(rd_en && vc_num_rd == {V{1'b0}})
                    $display("%t: ERROR: Attempt to read when no rd VC is asserted: %m",$time);
        end
    end
end 
endgenerate 
//synopsys  translate_on
//synthesis translate_on    



endmodule 



/****************************

     fifo_ram

*****************************/



module fifo_ram     #(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 8,
    parameter SSA_EN="YES" // "YES" , "NO"       
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
	reg [DATA_WIDTH-1:0] queue [2**ADDR_WIDTH-1:0] /* synthesis ramstyle = "no_rw_check , M9K" */;
	always @(posedge clk ) begin
			if (wr_en)
				 queue[wr_addr] <= wr_data;
			if (rd_en)
				 memory_rd_data <=
//synthesis translate_off
//synopsys  translate_off
					  #1
//synopsys  translate_on
//synthesis translate_on   
					  queue[rd_addr];
	end
	
                    	 
	 
	
	 
    generate 
    /* verilator lint_off WIDTH */
    if(SSA_EN =="YES") begin :predict
    /* verilator lint_on WIDTH */
		//add bypass
        reg [DATA_WIDTH-1:0]  bypass_reg;
        reg rd_en_delayed;
        always @(posedge clk ) begin
			 bypass_reg 	<=wr_data;
			 rd_en_delayed	<=rd_en;
        end
		  
        assign rd_data = (rd_en_delayed)? memory_rd_data  : bypass_reg;
		  
		  
    
    end else begin : no_predict
        assign rd_data =  memory_rd_data;
    end
    endgenerate
endmodule



// /*********************
// *
// *   fifo_ram_mem_size
// *
// **********************/


// module fifo_ram_mem_size     #(
//     parameter DATA_WIDTH  = 32,
//     parameter MEM_SIZE    = 200,
//     parameter SSA_EN  = "YES" // "YES" , "NO"       
//     )
//     (
//        wr_data,        
//        wr_addr,
//        rd_addr,
//        wr_en,
//        rd_en,
//        clk,
//        rd_data
//     ); 
     
    
//     function integer log2;
//       input integer number; begin   
//          log2=(number <=1) ? 1: 0;    
//          while(2**log2<number) begin    
//             log2=log2+1;    
//          end 	   
//       end   
//     endfunction // log2 

//     localparam ADDR_WIDTH=log2(MEM_SIZE);
    
//     input [DATA_WIDTH-1         :       0]  wr_data;       
//     input [ADDR_WIDTH-1         :       0]  wr_addr;
//     input [ADDR_WIDTH-1         :       0]  rd_addr;
//     input                                   wr_en;
//     input                                   rd_en;
//     input                                   clk;
//     output reg  [DATA_WIDTH-1   :       0]  rd_data;
    
    
     
//     generate 
//     /* verilator lint_off WIDTH */
//     if(SSA_EN =="YES") begin :predict
//     /* verilator lint_on WIDTH */
//         reg [DATA_WIDTH-1:0] queue [MEM_SIZE-1:0] /* synthesis ramstyle = "no_rw_check , M9K" */;
                
//         always @(posedge clk ) begin
//             if (wr_en)
//                 queue[wr_addr] <= wr_data;
//             if (rd_en) begin 
//                 rd_data <=
// //synthesis translate_off
// //synopsys  translate_off
//                     #1
// //synopsys  translate_on
// //synthesis translate_on  
//                     queue[rd_addr];
//             end else begin // id rd is not asserted by pass the input to the output in next clock cycle
//                 rd_data <=
// //synthesis translate_off
// //synopsys  translate_off
//                     #1
// //synopsys  translate_on
// //synthesis translate_on  
//                     wr_data;            
//             end           
//         end
    
//     end else begin : no_predict
    
//         reg [DATA_WIDTH-1:0] queue [MEM_SIZE-1:0] /* synthesis ramstyle = "no_rw_check , M9K" */;
        
//         always @(posedge clk ) begin
//             if (wr_en)
//                 queue[wr_addr] <= wr_data;
//             if (rd_en) 
//                 rd_data <=
// //synthesis translate_off
// //synopsys  translate_off
//                     #1
// //synopsys  translate_on
// //synthesis translate_on   
//                     queue[rd_addr];
              
//         end
//     end
//     endgenerate
    
// endmodule


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
                 if (wr_en & ~rd_en) depth <=
//synthesis translate_off
//synopsys  translate_off
                            #1
//synopsys  translate_on
//synthesis translate_on   
                            depth + 1'h1;
                else if (~wr_en & rd_en) depth <=

//synthesis translate_off
//synopsys  translate_off  
                            #1
//synopsys  translate_on
//synthesis translate_on   
                            depth - 1'h1;
                
            end
        end//always
        
        
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                 dout  <= {DATA_WIDTH{1'b0}};
            end else begin
                 if (out_ld) dout <= dout_next;
            end
        end//always
        
//synthesis translate_off
//synopsys  translate_off
        always @(posedge clk)
        begin
            if(~reset)begin
                if (wr_en && ~rd_en && full) begin
                    $display("%t: ERROR: Attempt to write to full FIFO:FIFO size is %d. %m",$time,MAX_DEPTH);
                end
                /* verilator lint_off WIDTH */
                if (rd_en && !recieve_more_than_0 && IGNORE_SAME_LOC_RD_WR_WARNING == "NO") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                end
                if (rd_en && ~wr_en && !recieve_more_than_0 && IGNORE_SAME_LOC_RD_WR_WARNING == "YES") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                end
                /* verilator lint_on WIDTH */
            end //~reset
        end // always @ (posedge clk)
    
//synopsys  translate_on
//synthesis translate_on  




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
                 if (wr_en & ~rd_en) depth <=
//synthesis translate_off
//synopsys  translate_off
                            #1
//synopsys  translate_on
//synthesis translate_on  
                            depth + 1'h1;
                else if (~wr_en & rd_en) depth <=
//synthesis translate_off
//synopsys  translate_off
                            #1
//synopsys  translate_on
//synthesis translate_on  
                            depth - 1'h1;
                
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
       
//synthesis translate_off
//synopsys  translate_off
        always @(posedge clk)

        begin
            if(~reset)begin
                if (wr_en && ~rd_en && full) begin
                    $display("%t: ERROR: Attempt to write to full FIFO:FIFO size is %d. %m",$time,MAX_DEPTH);
                end
                /* verilator lint_off WIDTH */
                if (rd_en && !recieve_more_than_0 && IGNORE_SAME_LOC_RD_WR_WARNING == "NO") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                end
                if (rd_en && ~wr_en && !recieve_more_than_0 && IGNORE_SAME_LOC_RD_WR_WARNING == "YES") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                end
                /* verilator lint_on WIDTH */
            end// ~reset
        end // always @ (posedge clk)
   
//synopsys  translate_on
//synthesis translate_on  
endmodule   


// /**********************************

//             fifo

// *********************************/


// module fifo  #(
//     parameter Dw = 72,//data_width
//     parameter B  = 10// buffer num
// )(
//     din,   
//     wr_en, 
//     rd_en, 
//     dout,  
//     full,
//     nearly_full,
//     empty,
//     reset,
//     clk
// );

 
//     function integer log2;
//       input integer number; begin   
//          log2=(number <=1) ? 1: 0;    
//          while(2**log2<number) begin    
//             log2=log2+1;    
//          end 	   
//       end   
//     endfunction // log2 

//     localparam  B_1 = B-1,
//                 Bw = log2(B),
//                 DEPTHw=log2(B+1);
//     localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];

//     input [Dw-1:0] din;     // Data in
//     input          wr_en;   // Write enable
//     input          rd_en;   // Read the next word

//     output reg [Dw-1:0]  dout;    // Data out
//     output         full;
//     output         nearly_full;
//     output         empty;

//     input          reset;
//     input          clk;



// reg [Dw-1       :   0] queue [B-1 : 0] /* synthesis ramstyle = "no_rw_check" */;
// reg [Bw- 1      :   0] rd_ptr;
// reg [Bw- 1      :   0] wr_ptr;
// reg [DEPTHw-1   :   0] depth;

// // Sample the data
// always @(posedge clk)
// begin
//    if (wr_en)
//       queue[wr_ptr] <= din;
//    if (rd_en)
//       dout <=
// //synthesis translate_off
// //synopsys  translate_off
//           #1
// //synopsys  translate_on
// //synthesis translate_on  
//           queue[rd_ptr];
// end

// always @(posedge clk)
// begin
//    if (reset) begin
//       rd_ptr <= {Bw{1'b0}};
//       wr_ptr <= {Bw{1'b0}};
//       depth  <= {DEPTHw{1'b0}};
//    end
//    else begin
//       if (wr_en) wr_ptr <= (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1;
//       if (rd_en) rd_ptr <= (rd_ptr==Bint)? {Bw{1'b0}} : rd_ptr + 1'b1;
//       if (wr_en & ~rd_en) depth <=
// //synthesis translate_off
// //synopsys  translate_off
//                    #1
// //synopsys  translate_on
// //synthesis translate_on  
//                    depth + 1'b1;
//       else if (~wr_en & rd_en) depth <=
// //synthesis translate_off
// //synopsys  translate_off
//                    #1
// //synopsys  translate_on
// //synthesis translate_on  
//                    depth - 1'b1;
//    end
// end

// //assign dout = queue[rd_ptr];
// assign full = depth == B;
// assign nearly_full = depth >= B-1;
// assign empty = depth == {DEPTHw{1'b0}};

// //synthesis translate_off
// //synopsys  translate_off
// always @(posedge clk)
// begin
//     if(~reset)begin
//        if (wr_en && depth == B && !rd_en)
//           $display(" %t: ERROR: Attempt to write to full FIFO: %m",$time);
//        if (rd_en && depth == {DEPTHw{1'b0}})
//           $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
//     end//~reset
// end
// //synopsys  translate_on
// //synthesis translate_on

// endmodule // fifo


