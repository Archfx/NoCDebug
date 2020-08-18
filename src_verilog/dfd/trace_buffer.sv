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
`timescale   1ns/1ps

module trace_buffer #(
    parameter Fpay     =   32,
    parameter TB_Depth =   512
    )   
    (
        din,     // Data in
        wr_en,   // Write enable
        rd_en,   // Read the buffer using JTaG
        dout,    // Data out
        reset,
        clk
        // ssa_rd
    );

   
    // function integer log2;
    //   input integer number; begin   
    //      log2=(number <=1) ? 1: 0;    
    //      while(2**log2<number) begin    
    //         log2=log2+1;    
    //      end 	   
    //   end   
    // endfunction // log2 
    
    // localparam      Fw      =   2+V+Fpay,   //flit width
    //                 BV      =   B   *   V,

    
    
    input  [Fpay-1      :0]   din;     // Data in
    // input  [V-1       :0]   vc_num_wr;//write vertual channel   
    // input  [V-1       :0]   vc_num_rd;//read vertual channel    
    input                   wr_en;   // Write enable
    input                   rd_en;   // Read the next word
    output [Fpay-1       :0]  dout;    // Data out
    // output [V-1        :0]  vc_not_empty;
    input                   reset;
    input                   clk;
    // input  [V-1        :0]  ssa_rd;
    
    // localparam BVw              =   log2(BV),
    //            Bw               =   (B==1)? 1 : log2(B),
    //            Vw               =  (V==1)? 1 : log2(V),
    //            DEPTHw           =   Bw+1,
    //            BwV              =   Bw * V,
    //            BVwV             =   BVw * V,
    //            RAM_DATA_WIDTH   =   Fw - V;
               
         
               
    wire  [Fpay-1     :   0] fifo_ram_din;
    wire  [Fpay-1     :   0] fifo_ram_dout;
    wire  wr;
    wire  rd;
    reg   [TB_Depth-1            :   0] depth;
    
    
    // assign fifo_ram_din = {din[Fw-1 :   Fw-2],din[Fpay-1        :   0]};
    // assign dout = {fifo_ram_dout[Fpay+1:Fpay],{V{1'bX}},fifo_ram_dout[Fpay-1        :   0]};    
    assign fifo_ram_din = din;
    assign dout = fifo_ram_dout;    
    // assign  wr  =   (wr_en)?  vc_num_wr : {V{1'b0}};
    // assign  rd  =   (rd_en)?  vc_num_rd : ssa_rd;

genvar i;



generate 

    reg [TB_Depth-1      :   0] rd_ptr;
    reg [TB_Depth-1     :   0] wr_ptr;
    
    
    
    
    // wire [BwV-1    :    0]  rd_ptr_array;
    // wire [BwV-1    :    0]  wr_ptr_array;
    // wire [Bw-1     :    0]  vc_wr_addr;
    // wire [Bw-1     :    0]  vc_rd_addr; 
    // wire [Vw-1     :    0]  wr_select_addr;
    // wire [Vw-1     :    0]  rd_select_addr; 
    // wire [Bw+Vw-1  :    0]  wr_addr;
    // wire [Bw+Vw-1  :    0]  rd_addr;
    
    




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
        .wr_en          (wr_en),
        .rd_en          (rd_en),
        .clk            (clk),
        .rd_data        (fifo_ram_dout)
    );  


        
        // assign  vc_not_empty  =   (depth > 0);
    
    
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

        //synthesis translate_off
        //synopsys  translate_off
    
        // always @(posedge clk) begin
        //     if(~reset)begin
        //         if (wr && (depth == B) && !rd)
        //             $display("%t: ERROR: Attempt to write to full FIFO:FIFO size is %d. %m",$time,B);
        //         /* verilator lint_off WIDTH */
        //         if (rd && (depth == {DEPTHw{1'b0}} &&  SSA_EN !="YES"  ))
        //             $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
        //         if (rd && !wr && (depth == {DEPTHw{1'b0}} &&  SSA_EN =="YES" ))
        //             $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
        //         /* verilator lint_on WIDTH */
          
        //     end//~reset      
        // end//always
        //synopsys  translate_on
        //synthesis translate_on
        
    endgenerate   



endmodule 






