/**********************************************************************
**	File:  trace_buffer.sv created based on the implementation flit_buffer.sv
**    
**	Description: 
**	Input buffer module. All VCs located in the same router 
**	input port share one single FPGA BRAM 
**
**************************************************************/

/****************************

     trace_buffer

*****************************/
`define DUMP_ENABLE
`timescale   1ns/1ps

module trace_buffer #(
    parameter Fpay     =   32,
    parameter TB_Depth =   512
    )   
    (
        din,     // Data in
        wr,   // Write enable
        rd,   // Read the buffer using JTaG
        dout,    // Data out
        reset,
        clk
        // ssa_rd
    );
    
    
    input  [Fpay-1      :0]   din;     // Data in  
    input                   wr;   // Write enable
    input                   rd;   // Read the next word
    output [Fpay-1       :0]  dout;    // Data out
    input                   reset;
    input                   clk;
    // input  [V-1        :0]  ssa_rd;
    
    wire  [Fpay-1     :   0] fifo_ram_din;
    wire  [Fpay-1     :   0] fifo_ram_dout;
    // wire  wr;
    // wire  rd;
    reg   [TB_Depth-1            :   0] depth;
    
    
    // assign fifo_ram_din = {din[Fw-1 :   Fw-2],din[Fpay-1        :   0]};
    // assign dout = {fifo_ram_dout[Fpay+1:Fpay],{V{1'bX}},fifo_ram_dout[Fpay-1        :   0]};    
    assign fifo_ram_din = din;
    assign dout = fifo_ram_dout;    
    // assign  wr  =   wr_en;
    // assign  rd  =   rd_en;//)?  vc_num_rd : ssa_rd;
    integer trace_dump;

    initial begin
        trace_dump = $fopen("trace_dump.txt","w");
         $fwrite(trace_dump,"%s \n","Start");
    end

    reg [TB_Depth-1      :   0] rd_ptr;
    reg [TB_Depth-1     :   0] wr_ptr;

    fifo_ram    #(
        .DATA_WIDTH (Fpay),
        .ADDR_WIDTH (TB_Depth),
        .SSA_EN("NO")       
    )
    the_queue
    (
        .wr_data        (fifo_ram_din), 
        .wr_addr        (wr_ptr),
        .rd_addr        (rd_ptr),
        .wr_en          (wr),
        .rd_en          (rd),
        .clk            (clk),
        .rd_data        (fifo_ram_dout)
    );   
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_ptr   <= {TB_Depth{1'b0}};
            wr_ptr   <= {TB_Depth{1'b0}};
            depth    <= {TB_Depth{1'b0}};
        end
        else begin
            if (wr) wr_ptr <= wr_ptr + 1'h1;
            if (rd) rd_ptr <= rd_ptr + 1'h1;
            if (wr & ~rd) depth <=
            //synthesis translate_off
            //synopsys  translate_off
                #1
            //synopsys  translate_on
            //synthesis translate_on
                depth + 1'h1;
            else if (~wr & rd) depth <=
            //synthesis translate_off
            //synopsys  translate_off
                #1
            //synopsys  translate_on
            //synthesis translate_on
                depth - 1'h1;
        end//else

            
    end//always  

`ifdef DUMP_ENABLE
    // Dumping buffer input values to files
    always @(posedge clk) begin
        if (wr) begin  
            $display("writing");    
            $fwrite(trace_dump,"%h \n",din);
        end
    end
`endif
endmodule 

interface trace ();
	logic [31:0]    signal;
	logic           trigger;

    modport SRC  (output trigger, output signal);
    modport DST (input trigger, input signal);
endinterface

// module trace_handler #(
//     parameter Fpay     =   32,
//     parameter Tile_num =   4
//     )   
//     (
//         din_0,din_1,din_2,din_3,din_4,
//         wr_0, wr_1, wr_2, wr_3,wr_4,
//         ip_select,
//         wr_en,   
//         dout, 
//         reset,
//         clk
//     );

//     input [Tile_num-1 : 0] ip_select;
//     input wr_0, wr_1, wr_2, wr_3,wr_4;
//     input [Fpay-1:0] din_0,din_1,din_2,din_3,din_4;
//     input reset;
//     input clk;
//     output wr_en;
//     output [Fpay-1:0] dout;

//     assign wr_en =  (ip_select==4'b0001)? wr_0 : ((ip_select==4'b0010)? wr_1 : ((ip_select==4'b0100)? wr_2 : ((ip_select==4'b1000)? wr_3 : ((ip_select==4'b1111)? wr_4 : wr_4) ))); //wr_0 || wr_1 || wr_2 || wr_3;
//     assign dout = (ip_select==4'b0001)? din_0 : ((ip_select==4'b0010)? din_1 : ((ip_select==4'b0100)? din_2 : ((ip_select==4'b1000)? din_3 : ((ip_select==4'b1111)? din_4 : din_4) )));

//     always @(posedge clk) begin
//         if (wr_4) begin
//             $display("traceHandler triggered");
//             $display("%b,%b,%b,%b,%b",wr_0,wr_1,wr_2,wr_3,wr_4);
//         end
//     end


// endmodule  

// module trace_generator #(
//     parameter Fpay     =   32,
//     parameter Tile_num =   4
//     )   
//     (
//         trigger_length,
//         trace_signal_in,
//         trigger,
//         wr_en,   
//         dout, 
//         reset,
//         clk
//     );

//     input [4 : 0] trigger_length;
//     input trigger;
//     input [31:0] trace_signal_in;
//     input reset;
//     input clk;
//     output reg wr_en;
//     output reg [31:0] dout;

//     reg [4:0] counter=5'b0; //Counter for trace length calculation
//     reg [31:0] residue;
//     reg [4:0] residue_length;
//     reg residue_fill_flag=1'b0;
//     int i,j,k,l;
//     reg [2:0] timer=1'b0;
    
//     // assign wr_en = trigger? 1'b1 : 1'b0;
//     // assign dout = 32'(trace_signal_in);
//     always @(*) begin
//         if (trigger && (counter+trigger_length < Fpay)) begin
//             for (j=0; j < (trigger_length); j++) begin
//                 dout[counter+j]<=trace_signal_in[j];
//             end
//             // dout[trigger_length - 1 + counter : counter]<= trace_signal[trigger_length-1: 0];
//             counter <= counter+trigger_length;
//             wr_en<=1'b0;
//             // dout<=32'(trace_signal_in);
//         end
//         // if (trigger) begin
//         //     wr_en <= trigger;
//         //     dout<=32'(trace_signal_in);
//         //     $display("triggered");
//         // end
//         else if (trigger) begin
//             for (i=0; i < (trigger_length-counter); i++) begin
//                 dout[counter+i]<=trace_signal_in[i];
//             end
//             // dout[trigger_length - 1 + counter: counter]<= trace_signal[trigger_length-1-counter: 0];
//             for (k=0; k < (counter); k++) begin
//                 residue[k]<=trace_signal_in[k];
//             end
//             // residue[counter-1: 0] <= trace_signal[counter-1: 0];
//             residue_length <= (5'b11111 - counter);
//             residue_fill_flag<=1'b1;
//             wr_en<=1'b1;
//         end
//         if (residue_fill_flag) begin
//             for (l=0; l < (residue_length); l++) begin
//                 dout[l]<=residue[l];
//             end
//             // dout[residue_length - 1 : 0]<= residue[counter-1: 0];
//             counter <= residue_length;
//             residue_fill_flag <=1'b0;
//             residue_length<=5'b0;
//             wr_en<=1'b0;
//         end
//         if (counter == 5'b11111) begin
//             wr_en<=1'b1;
//             counter<=1'b0;
//         end


//     end


// endmodule






