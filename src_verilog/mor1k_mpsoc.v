`timescale	 1ns/1ps
module mor1k_mpsoc (
	clk,
	reset ,
	processors_en
);
 

//NoC parameters
 	localparam TOPOLOGY="MESH";
 	localparam T1=2;
 	localparam T2=2;
 	localparam T3=1;
 	localparam V=2;
 	localparam B=4;
 	localparam Fpay=32;
 	localparam ROUTE_NAME="XY";
 	localparam MIN_PCK_SIZE=8;
 	localparam SSA_EN="NO";
 	localparam CONGESTION_INDEX=3;
 	localparam ESCAP_VC_MASK=2'b01;
 	localparam VC_REALLOCATION_TYPE="NONATOMIC";
 	localparam COMBINATION_TYPE="COMB_NONSPEC";
 	localparam MUX_TYPE="BINARY";
 	localparam C=2;
 	localparam DEBUG_EN=0;
 	localparam ADD_PIPREG_AFTER_CROSSBAR=1'b0;
 	localparam FIRST_ARBITER_EXT_P_EN=1;
 	localparam SWA_ARBITER_TYPE="RRA";
 	localparam WEIGHTw=4;
 	localparam AVC_ATOMIC_EN=0;
 	localparam Cn_0=2'b01;
 	localparam Cn_1=2'b10;
 	localparam CLASS_SETTING={Cn_1,Cn_0};
   	localparam  CVw=(C==0)? V : C * V;
 
//functions	
	function integer log2;
		input integer number; begin   
			log2=0;    
			while(2**log2<number) begin    
				log2=log2+1;    
			end    
	end   
	endfunction // log2 
    
	 

	
				
	 
//SOC parameters
 
	 //Parameter setting for mor1k_tile  located in tile: 0 
 
	 //Parameter setting for mor1k_tile  located in tile: 1 
 
	 //Parameter setting for mor1k_tile  located in tile: 2 
 
	 //Parameter setting for mor1k_tile  located in tile: 3 
 
 
//IO
	input	clk,reset;
 	 input processors_en; 
	

	localparam
		NE = 4,
		NR = 4,
		RAw = 2,
		EAw = 2,
		Fw = 36,
		NEFw = NE * Fw,
		NEV = NE * V;

//NoC ports 
    // connection to NI modules               
	wire [Fw-1      :   0]  ni_flit_out                 [NE-1           :0];   
	wire [NE-1      :   0]  ni_flit_out_wr; 
	wire [V-1       :   0]  ni_credit_in                [NE-1           :0];
	wire [Fw-1      :   0]  ni_flit_in                  [NE-1           :0];   
	wire [NE-1      :   0]  ni_flit_in_wr;  
	wire [V-1       :   0]  ni_credit_out               [NE-1           :0];    
	
	//connection wire to NoC
	wire [NEFw-1    :   0]  flit_out_all;
	wire [NE-1      :   0]  flit_out_wr_all;
	wire [NEV-1     :   0]  credit_in_all;
	wire [NEFw-1    :   0]  flit_in_all;
	wire [NE-1      :   0]  flit_in_wr_all;  
	wire [NEV-1     :   0]  credit_out_all;
	
	wire 					noc_clk,noc_reset; 

	wire  [31 : 0] tile0bus,tile1bus,tile2bus,tile3bus,nocbus;
	wire  trigger_0,trigger_1,trigger_2,trigger_3,trigger_noc;
	wire trigger_wr;
	wire trace_rd;
	wire [31:0] trace_in;
	wire [31:0] trace_out;
	  
    
//NoC
 	noc #(
 .TOPOLOGY(TOPOLOGY),
 .T1(T1),
 .T2(T2),
 .T3(T3),
 .V(V),
 .B(B),
 .Fpay(Fpay),
 .ROUTE_NAME(ROUTE_NAME),
 .MIN_PCK_SIZE(MIN_PCK_SIZE),
 .SSA_EN(SSA_EN),
 .CONGESTION_INDEX(CONGESTION_INDEX),
 .ESCAP_VC_MASK(ESCAP_VC_MASK),
 .VC_REALLOCATION_TYPE(VC_REALLOCATION_TYPE),
 .COMBINATION_TYPE(COMBINATION_TYPE),
 .MUX_TYPE(MUX_TYPE),
 .C(C),
 .DEBUG_EN(DEBUG_EN),
 .ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
 .FIRST_ARBITER_EXT_P_EN(FIRST_ARBITER_EXT_P_EN),
 .SWA_ARBITER_TYPE(SWA_ARBITER_TYPE),
 .WEIGHTw(WEIGHTw),
 .AVC_ATOMIC_EN(AVC_ATOMIC_EN),
 .CLASS_SETTING(CLASS_SETTING),
 .CVw(CVw)

	)
	the_noc
	(
 		.flit_out_all(flit_out_all) ,
		.flit_out_wr_all(flit_out_wr_all) ,
		.credit_in_all(credit_in_all) ,
		.flit_in_all(flit_in_all) ,
		.flit_in_wr_all(flit_in_wr_all) ,
		.credit_out_all(credit_out_all) ,
		.reset(noc_reset) ,
		.clk(noc_clk),
		.trace_signal(nocbus) ,
		.trigger(trigger_noc)

	);

 	
	clk_source  src 	(
		.clk_in(clk),
		.clk_out(noc_clk),
		.reset_in(reset),
		.reset_out(noc_reset)
	);    
 	

//NoC port assignment
  genvar IP_NUM;
  generate 
    for (IP_NUM=0;   IP_NUM<NE; IP_NUM=IP_NUM+1) begin :endp
          
            assign  ni_flit_in      [IP_NUM] =   flit_out_all    [(IP_NUM+1)*Fw-1    : IP_NUM*Fw];   
            assign  ni_flit_in_wr   [IP_NUM] =   flit_out_wr_all [IP_NUM]; 
            assign  credit_in_all   [(IP_NUM+1)*V-1 : IP_NUM*V]     =   ni_credit_out   [IP_NUM];  
            assign  flit_in_all     [(IP_NUM+1)*Fw-1    : IP_NUM*Fw]    =   ni_flit_out     [IP_NUM];
            assign  flit_in_wr_all  [IP_NUM] =   ni_flit_out_wr  [IP_NUM];
            assign  ni_credit_in    [IP_NUM] =   credit_out_all  [(IP_NUM+1)*V-1 : IP_NUM*V];
            
    end
endgenerate

 

 // Tile:0 (0)
   	mor1k_tile #(
 		.CORE_ID(0),
		.SW_LOC("../sw/tile0") ,
		.ni_B(B) ,
		.ni_C(C) ,
		.ni_DEBUG_EN(DEBUG_EN) ,
		.ni_EAw(EAw) ,
		.ni_Fpay(Fpay) ,
		.ni_RAw(RAw) ,
		.ni_ROUTE_NAME(ROUTE_NAME) ,
		.ni_T1(T1) ,
		.ni_T2(T2) ,
		.ni_T3(T3) ,
		.ni_TOPOLOGY(TOPOLOGY) ,
		.ni_V(V) 
	)the_mor1k_tile_0(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[0]) , 
		.ni_credit_out(ni_credit_out[0]) , 
		.ni_current_e_addr(2'd0) , 
		.ni_current_r_addr(2'd0) , 
		.ni_flit_in(ni_flit_in[0]) , 
		.ni_flit_in_wr(ni_flit_in_wr[0]) , 
		.ni_flit_out(ni_flit_out[0]) , 
		.ni_flit_out_wr(ni_flit_out_wr[0]) ,
		.trace_signal(tile0bus) ,
		.trace_trigger(trigger_0)
	);
 

 // Tile:1 (1)
   	mor1k_tile #(
 		.CORE_ID(1),
		.SW_LOC("../sw/tile1") ,
		.ni_B(B) ,
		.ni_C(C) ,
		.ni_DEBUG_EN(DEBUG_EN) ,
		.ni_EAw(EAw) ,
		.ni_Fpay(Fpay) ,
		.ni_RAw(RAw) ,
		.ni_ROUTE_NAME(ROUTE_NAME) ,
		.ni_T1(T1) ,
		.ni_T2(T2) ,
		.ni_T3(T3) ,
		.ni_TOPOLOGY(TOPOLOGY) ,
		.ni_V(V) 
	)the_mor1k_tile_1(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[1]) , 
		.ni_credit_out(ni_credit_out[1]) , 
		.ni_current_e_addr(2'd1) , 
		.ni_current_r_addr(2'd1) , 
		.ni_flit_in(ni_flit_in[1]) , 
		.ni_flit_in_wr(ni_flit_in_wr[1]) , 
		.ni_flit_out(ni_flit_out[1]) , 
		.ni_flit_out_wr(ni_flit_out_wr[1]) ,
		.trace_signal(tile1bus),
		.trace_trigger(trigger_1)
	);
 

 // Tile:2 (2)
   	mor1k_tile #(
 		.CORE_ID(2),
		.SW_LOC("../sw/tile2") ,
		.ni_B(B) ,
		.ni_C(C) ,
		.ni_DEBUG_EN(DEBUG_EN) ,
		.ni_EAw(EAw) ,
		.ni_Fpay(Fpay) ,
		.ni_RAw(RAw) ,
		.ni_ROUTE_NAME(ROUTE_NAME) ,
		.ni_T1(T1) ,
		.ni_T2(T2) ,
		.ni_T3(T3) ,
		.ni_TOPOLOGY(TOPOLOGY) ,
		.ni_V(V) 
	)the_mor1k_tile_2(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[2]) , 
		.ni_credit_out(ni_credit_out[2]) , 
		.ni_current_e_addr(2'd2) , 
		.ni_current_r_addr(2'd2) , 
		.ni_flit_in(ni_flit_in[2]) , 
		.ni_flit_in_wr(ni_flit_in_wr[2]) , 
		.ni_flit_out(ni_flit_out[2]) , 
		.ni_flit_out_wr(ni_flit_out_wr[2]) ,
		.trace_signal(tile2bus),
		.trace_trigger(trigger_2)
	);
 

 // Tile:3 (3)
   	mor1k_tile #(
 		.CORE_ID(3),
		.SW_LOC("../sw/tile3") ,
		.ni_B(B) ,
		.ni_C(C) ,
		.ni_DEBUG_EN(DEBUG_EN) ,
		.ni_EAw(EAw) ,
		.ni_Fpay(Fpay) ,
		.ni_RAw(RAw) ,
		.ni_ROUTE_NAME(ROUTE_NAME) ,
		.ni_T1(T1) ,
		.ni_T2(T2) ,
		.ni_T3(T3) ,
		.ni_TOPOLOGY(TOPOLOGY) ,
		.ni_V(V) 
	)the_mor1k_tile_3(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[3]) , 
		.ni_credit_out(ni_credit_out[3]) , 
		.ni_current_e_addr(2'd3) , 
		.ni_current_r_addr(2'd3) , 
		.ni_flit_in(ni_flit_in[3]) , 
		.ni_flit_in_wr(ni_flit_in_wr[3]) , 
		.ni_flit_out(ni_flit_out[3]) , 
		.ni_flit_out_wr(ni_flit_out_wr[3]) ,
		.trace_signal(tile3bus),
		.trace_trigger(trigger_3)
	);

	assign trigger_wr = (trigger_0 | trigger_1 | trigger_2 | trigger_3 | trigger_noc)? 1'b1: 1'b0; //(trigger_0)? wr_0 : ((trigger_1)? wr_1 : ((trigger_2)? wr_2 : ((trigger_3)? wr_3 : ((trigger_4)? wr_4 : wr_4) ))); //wr_0 || wr_1 || wr_2 || wr_3;
    assign trace_in = (trigger_0)? tile0bus : ((trigger_1)? tile1bus : ((trigger_2)? tile2bus : ((trigger_3)? tile3bus : ((trigger_noc)? nocbus : 32'd0) )));

	// initial begin
    //     trigger_wr <= 1'b0;
    //     trace_in <= 32'b0;
    // end
    // always @(*) begin
    //     trigger_wr <= (trigger_0 | trigger_1 | trigger_2 | trigger_3 | trigger_noc);
        
    //     case ({trigger_0 , trigger_1 , trigger_2 , trigger_3 , trigger_noc})
    //         5'b10000  : trace_in <= tile0bus;
    //         5'b01000  : trace_in <= tile1bus;
    //         5'b00100  : trace_in <= tile2bus;
	// 		5'b00010  : trace_in <= tile3bus;
    //         5'b00001  : trace_in <= nocbus;

    //         default : trace_in <= 32'b0; 
    //     endcase
    // end

	trace_buffer #(
        .Fpay(32),
        .TB_Depth(512)
     )
     the_tb
     (
        .din(trace_in),     // Data in
        .wr(trigger_wr),   // Write enable
        .rd(trace_rd),   // Read the next word
        .dout(trace_out),    // Data out
        .reset(reset),
        .clk(clk)
    ); 

	// trace_handler #(
    // 	.Fpay(32),
    // 	.Tile_num(4)
    // )
	// the_tb_handler   
    // (
    //     .din_0(tile0bus),
    //     .din_1(tile1bus),
    //     .din_2(tile2bus),
    //     .din_3(tile3bus),
	// 	.din_4(nocbus),
    //     .wr_0(trigger_0),
	// 	.wr_1(trigger_1),
	// 	.wr_2(trigger_2), 
	// 	.wr_3(trigger_3),
	// 	.wr_4(trigger_noc),
    //     .ip_select(4'b1111),
    //     .wr_en(tb_in_wr),   
    //     .dout(flit_in), 
    //     .reset(reset),
    //     .clk(clk)
    // );
	integer trace_dump;

	initial begin
        trace_dump = $fopen("trace_dump_mpsoc.txt","w");
         $fwrite(trace_dump,"%s \n","Start");
    end
	
	always @(*) begin
		// if (trigger_0 | trigger_1 | trigger_2 | trigger_3 | trigger_noc) begin
            // trigger_wr = (trigger_0 | trigger_1 | trigger_2 | trigger_3 | trigger_noc);
            if (trigger_0) begin
				// trace_in <= tile0bus; 
				// trigger_wr <= trigger_0 ;
				$display("%d-soc-0",trigger_wr);
				$display("%d-soc-0",trace_in);
				$display("writing");    
            	$fwrite(trace_dump,"%h \n",trace_in);
			end 
            else if (trigger_1) begin
				// trace_in <= tile1bus ;
				// trigger_wr <= trigger_1 ;
				$display("%d-soc-1",trigger_wr);
				$display("%d-soc-1",trace_in);
				$display("writing");    
            	$fwrite(trace_dump,"%h \n",trace_in);
			end
            else if (trigger_2) begin
				// trace_in <= tile2bus ;
				// trigger_wr <= trigger_2 ;
				$display("%d-soc-2",trigger_wr);
				$display("%d-soc-2",trace_in);
				$display("writing");    
            	$fwrite(trace_dump,"%h \n",trace_in);
			end
			else if (trigger_3) begin
				// trace_in <= tile3bus ;
				// trigger_wr <= trigger_2 ;
				$display("%d-soc-3",trigger_wr);
				$display("%d-soc-3",trace_in);
				$display("writing");    
            	$fwrite(trace_dump,"%h \n",trace_in);
			end 
			else if (trigger_noc) begin
				// trace_in <= nocbus ;
				// trigger_wr <= trigger_noc ;
				$display("%d-soc-noc",trigger_wr);
				$display("%d-soc-noc",trace_in);
				$display("writing");    
            	$fwrite(trace_dump,"%h \n",trace_in);
			end 
    

			//  $display("%d-trigger_wr",trigger_wr);
			// $display("%d-soc",trace_in);
            // $display("%d,%d, %d",trigger_0 , trigger_1,trigger_2);
			// $display("%d,%d,%d",trace_signal_0,trace_signal_1, trace_signal_2);
		// end
		// else trigger_wr <= 1'b0;
	end
	
	// always @(*) begin
	// 	if (trigger_wr) begin
	// 		$display("%d,%d,%d,%d,%d",trigger_0 , trigger_1 , trigger_2 , trigger_3 , trigger_noc);
	// 		$display("%d,%d,%d,%d,%d",tile0bus , tile1bus , tile2bus , tile3bus , nocbus);
	// 	end
	// end

	
 
endmodule
