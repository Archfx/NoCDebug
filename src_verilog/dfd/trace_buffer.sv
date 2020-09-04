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
        trace,     // Data in
        trigger,   // Write enable
        rd,   // Read the buffer using JTaG
        dout,    // Data out
        reset,
        clk
        // ssa_rd
    );
    
    
    input  [Fpay-1      :0]   trace;     // Data in  
    input                   trigger;   // Write enable
    input                   rd;   // Read the next word
    output [Fpay-1       :0]  dout;    // Data out
    input                   reset;
    input                   clk;
    // input  [V-1        :0]  ssa_rd;
    
    wire  [Fpay-1     :   0] fifo_ram_din;
    wire  [Fpay-1     :   0] fifo_ram_dout;
    // wire  trigger;
    // wire  rd;
    reg   [TB_Depth-1            :   0] depth;
    
    
    // assign fifo_ram_din = {trace[Fw-1 :   Fw-2],trace[Fpay-1        :   0]};
    // assign dout = {fifo_ram_dout[Fpay+1:Fpay],{V{1'bX}},fifo_ram_dout[Fpay-1        :   0]};    
    assign fifo_ram_din = trace;
    assign dout = fifo_ram_dout;    
    // assign  trigger  =   wr_en;
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
        .wr_en          (trigger),
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
            if (trigger) wr_ptr <= wr_ptr + 1'h1;
            if (rd) rd_ptr <= rd_ptr + 1'h1;
            if (trigger & ~rd) depth <=
            //synthesis translate_off
            //synopsys  translate_off
                #1
            //synopsys  translate_on
            //synthesis translate_on
                depth + 1'h1;
            else if (~trigger & rd) depth <=
            //synthesis translate_off
            //synopsys  translate_off
                #1
            //synopsys  translate_on
            //synthesis translate_on
                depth - 1'h1;
        end//else

            
    end//always  

    always@(*) begin
        if (trigger) begin 
            $display("trace_buff %d, trace %b",trigger,trace);
            $fwrite(trace_dump,"%h \n",trace);
        end
    end

// // `ifdef DUMP_ENABLE
//     // Dumping buffer input values to files
//     always @(posedge trigger) begin
//         // if (trigger) begin  
//             $display("writing");    
//             $fwrite(trace_dump,"%h \n",trace);
//         // end
//     end
// // `endif
endmodule 






