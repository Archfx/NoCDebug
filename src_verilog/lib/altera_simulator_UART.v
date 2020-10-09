/**************************************
* Module: simulator_UART
* Date:2017-06-13  
* Author: alireza     
*
* Description: A simple uart that display input characters on simulator terminal using $write command.
*              This module start wrting on terminal when the buffer becomes full or wait counter reach its limit. 
*              The buffer  perevents the conflict between multiple simulation UART messages 
*              Wait counter reset by each individual write on buffer
***************************************/




module  altera_simulator_UART #(
    parameter BUFFER_SIZE   =100,  
    parameter WAIT_COUNT    =1000
)(
    reset,
    clk,
    s_dat_i,
    s_sel_i,
    s_addr_i,  
    s_cti_i,
    s_stb_i,
    s_cyc_i,
    s_we_i,    
    s_dat_o,
    s_ack_o,
    
    //Read data from stdin
    RxD_din,
    RxD_wr,
    RxD_ready


);

    localparam
	Dw            =   32,
	M_Aw          =   32,
    TAGw          =   3,
    SELw          =   4;
  


    input reset,clk;
//wishbone slave interface signals
    input   [Dw-1       :   0]      s_dat_i;
    input   [SELw-1     :   0]      s_sel_i;
    input    			    s_addr_i;  
    input   [TAGw-1     :   0]      s_cti_i;
    input                           s_stb_i;
    input                           s_cyc_i;
    input                           s_we_i;
    
    output  reg [Dw-1       :   0]  s_dat_o;
    output  reg                     s_ack_o;

//Read data from stdin
    input [7:0]  RxD_din;
    input RxD_wr;
    output RxD_ready;
  

     wire s_ack_o_next    =   s_stb_i & (~s_ack_o);
     
    always @(posedge clk)begin 
        if( reset   )s_ack_o<=1'b0;
       else s_ack_o<=s_ack_o_next;
    end
     
     


endmodule



/**********************************

            fifo

*********************************/


module RxD_fifo  #(
    parameter Dw = 72,//data_width
    parameter B  = 10// buffer num
)(
    din,   
    wr_en, 
    rd_en, 
    dout,  
    full,
    nearly_full,
    empty,
    reset,
    clk
);

 
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam  B_1 = B-1,
                Bw = log2(B),
                DEPTHw=log2(B+1);
    localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];

    input [Dw-1:0] din;     // Data in
    input          wr_en;   // Write enable
    input          rd_en;   // Read the next word

    output reg [Dw-1:0]  dout;    // Data out
    output         full;
    output         nearly_full;
    output         empty;

    input          reset;
    input          clk;



reg [Dw-1       :   0] queue [B-1 : 0] /* synthesis ramstyle = "no_rw_check" */;
reg [Bw- 1      :   0] rd_ptr;
reg [Bw- 1      :   0] wr_ptr;
reg [DEPTHw-1   :   0] depth;

// Sample the data
always @(posedge clk)
begin
   if (wr_en)
      queue[wr_ptr] <= din;
   if (rd_en)
      dout <=queue[rd_ptr];
end

always @(posedge clk)
begin
   if (reset) begin
      rd_ptr <= {Bw{1'b0}};
      wr_ptr <= {Bw{1'b0}};
      depth  <= {DEPTHw{1'b0}};
   end
   else begin
      if (wr_en) wr_ptr <= (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1;
      if (rd_en) rd_ptr <= (rd_ptr==Bint)? {Bw{1'b0}} : rd_ptr + 1'b1;
      if (wr_en & ~rd_en) depth <= depth + 1'b1;
      else if (~wr_en & rd_en) depth <= depth - 1'b1;
   end
end

//assign dout = queue[rd_ptr];
assign full = depth == B;
assign nearly_full = depth >= B-1;
assign empty = depth == {DEPTHw{1'b0}};



endmodule // fifo


