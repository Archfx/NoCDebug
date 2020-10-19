`timescale	 1ns/1ps
module mor1k_16Soc (
	clk,
	reset ,
	processors_en
);
 

//NoC parameters
 	localparam TOPOLOGY="MESH";
 	localparam T1=4;
 	localparam T2=4;
 	localparam T3=1;
 	localparam V=2;
 	localparam B=4;
 	localparam Fpay=32;
 	localparam ROUTE_NAME="XY";
 	localparam MIN_PCK_SIZE=2;
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
 
	 //Parameter setting for mor1k_tile  located in tile: 4 
 
	 //Parameter setting for mor1k_tile  located in tile: 5 
 
	 //Parameter setting for mor1k_tile  located in tile: 6 
 
	 //Parameter setting for mor1k_tile  located in tile: 7 
 
	 //Parameter setting for mor1k_tile  located in tile: 8 
 
	 //Parameter setting for mor1k_tile  located in tile: 9 
 
	 //Parameter setting for mor1k_tile  located in tile: 10 
 
	 //Parameter setting for mor1k_tile  located in tile: 11 
 
	 //Parameter setting for mor1k_tile  located in tile: 12 
 
	 //Parameter setting for mor1k_tile  located in tile: 13 
 
	 //Parameter setting for mor1k_tile  located in tile: 14 
 
	 //Parameter setting for mor1k_tile  located in tile: 15 
 
 
//IO
	input	clk,reset;
 	 input processors_en; 
	

	localparam
		NE = 16,
		NR = 16,
		RAw = 4,
		EAw = 4,
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
    
	// Trace
    wire trigger,trigger_0,trigger_1,trigger_2,trigger_3,trigger_4,trigger_5,trigger_6,trigger_7,trigger_8,trigger_9,trigger_10,trigger_11,trigger_12,trigger_13,trigger_14,trigger_15,trigger_NOC;
    wire [31:0] trace,trace_0,trace_1,trace_2,trace_3,trace_4,trace_5,trace_6,trace_7,trace_8,trace_9,trace_10,trace_11,trace_12,trace_13,trace_14,trace_15,trace_NOC;  

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
		.clk(noc_clk) ,
        .trigger(trigger_NOC),
        .trace(trace_NOC)
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
		.ni_current_e_addr(4'd0) , 
		.ni_current_r_addr(4'd0) , 
		.ni_flit_in(ni_flit_in[0]) , 
		.ni_flit_in_wr(ni_flit_in_wr[0]) , 
		.ni_flit_out(ni_flit_out[0]) , 
		.ni_flit_out_wr(ni_flit_out_wr[0]),
        .trigger(trigger_0),
        .trace(trace_0)  
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
		.ni_current_e_addr(4'd1) , 
		.ni_current_r_addr(4'd1) , 
		.ni_flit_in(ni_flit_in[1]) , 
		.ni_flit_in_wr(ni_flit_in_wr[1]) , 
		.ni_flit_out(ni_flit_out[1]) , 
		.ni_flit_out_wr(ni_flit_out_wr[1]),
        .trigger(trigger_1),
        .trace(trace_1) 
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
		.ni_current_e_addr(4'd2) , 
		.ni_current_r_addr(4'd2) , 
		.ni_flit_in(ni_flit_in[2]) , 
		.ni_flit_in_wr(ni_flit_in_wr[2]) , 
		.ni_flit_out(ni_flit_out[2]) , 
		.ni_flit_out_wr(ni_flit_out_wr[2]),
        .trigger(trigger_2),
        .trace(trace_2)  
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
		.ni_current_e_addr(4'd3) , 
		.ni_current_r_addr(4'd3) , 
		.ni_flit_in(ni_flit_in[3]) , 
		.ni_flit_in_wr(ni_flit_in_wr[3]) , 
		.ni_flit_out(ni_flit_out[3]) , 
		.ni_flit_out_wr(ni_flit_out_wr[3]),
        .trigger(trigger_3),
        .trace(trace_3)  
	);
 

 // Tile:4 (4)
   	mor1k_tile #(
 		.CORE_ID(4),
		.SW_LOC("../sw/tile4") ,
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
	)the_mor1k_tile_4(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[4]) , 
		.ni_credit_out(ni_credit_out[4]) , 
		.ni_current_e_addr(4'd4) , 
		.ni_current_r_addr(4'd4) , 
		.ni_flit_in(ni_flit_in[4]) , 
		.ni_flit_in_wr(ni_flit_in_wr[4]) , 
		.ni_flit_out(ni_flit_out[4]) , 
		.ni_flit_out_wr(ni_flit_out_wr[4]),
        .trigger(trigger_4),
        .trace(trace_4)  
	);
 

 // Tile:5 (5)
   	mor1k_tile #(
 		.CORE_ID(5),
		.SW_LOC("../sw/tile5") ,
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
	)the_mor1k_tile_5(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[5]) , 
		.ni_credit_out(ni_credit_out[5]) , 
		.ni_current_e_addr(4'd5) , 
		.ni_current_r_addr(4'd5) , 
		.ni_flit_in(ni_flit_in[5]) , 
		.ni_flit_in_wr(ni_flit_in_wr[5]) , 
		.ni_flit_out(ni_flit_out[5]) , 
		.ni_flit_out_wr(ni_flit_out_wr[5]),
        .trigger(trigger_5),
        .trace(trace_5)  
	);
 

 // Tile:6 (6)
   	mor1k_tile #(
 		.CORE_ID(6),
		.SW_LOC("../sw/tile6") ,
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
	)the_mor1k_tile_6(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[6]) , 
		.ni_credit_out(ni_credit_out[6]) , 
		.ni_current_e_addr(4'd6) , 
		.ni_current_r_addr(4'd6) , 
		.ni_flit_in(ni_flit_in[6]) , 
		.ni_flit_in_wr(ni_flit_in_wr[6]) , 
		.ni_flit_out(ni_flit_out[6]) , 
		.ni_flit_out_wr(ni_flit_out_wr[6]),
        .trigger(trigger_6),
        .trace(trace_6)  
	);
 

 // Tile:7 (7)
   	mor1k_tile #(
 		.CORE_ID(7),
		.SW_LOC("../sw/tile7") ,
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
	)the_mor1k_tile_7(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[7]) , 
		.ni_credit_out(ni_credit_out[7]) , 
		.ni_current_e_addr(4'd7) , 
		.ni_current_r_addr(4'd7) , 
		.ni_flit_in(ni_flit_in[7]) , 
		.ni_flit_in_wr(ni_flit_in_wr[7]) , 
		.ni_flit_out(ni_flit_out[7]) , 
		.ni_flit_out_wr(ni_flit_out_wr[7]),
        .trigger(trigger_7),
        .trace(trace_7)  
	);
 

 // Tile:8 (8)
   	mor1k_tile #(
 		.CORE_ID(8),
		.SW_LOC("../sw/tile8") ,
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
	)the_mor1k_tile_8(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[8]) , 
		.ni_credit_out(ni_credit_out[8]) , 
		.ni_current_e_addr(4'd8) , 
		.ni_current_r_addr(4'd8) , 
		.ni_flit_in(ni_flit_in[8]) , 
		.ni_flit_in_wr(ni_flit_in_wr[8]) , 
		.ni_flit_out(ni_flit_out[8]) , 
		.ni_flit_out_wr(ni_flit_out_wr[8]),
        .trigger(trigger_8),
        .trace(trace_8)  
	);
 

 // Tile:9 (9)
   	mor1k_tile #(
 		.CORE_ID(9),
		.SW_LOC("../sw/tile9") ,
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
	)the_mor1k_tile_9(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[9]) , 
		.ni_credit_out(ni_credit_out[9]) , 
		.ni_current_e_addr(4'd9) , 
		.ni_current_r_addr(4'd9) , 
		.ni_flit_in(ni_flit_in[9]) , 
		.ni_flit_in_wr(ni_flit_in_wr[9]) , 
		.ni_flit_out(ni_flit_out[9]) , 
		.ni_flit_out_wr(ni_flit_out_wr[9]),
        .trigger(trigger_9),
        .trace(trace_9)  
	);
 

 // Tile:10 (10)
   	mor1k_tile #(
 		.CORE_ID(10),
		.SW_LOC("../sw/tile10") ,
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
	)the_mor1k_tile_10(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[10]) , 
		.ni_credit_out(ni_credit_out[10]) , 
		.ni_current_e_addr(4'd10) , 
		.ni_current_r_addr(4'd10) , 
		.ni_flit_in(ni_flit_in[10]) , 
		.ni_flit_in_wr(ni_flit_in_wr[10]) , 
		.ni_flit_out(ni_flit_out[10]) , 
		.ni_flit_out_wr(ni_flit_out_wr[10]),
        .trigger(trigger_10),
        .trace(trace_10)  
	);
 

 // Tile:11 (11)
   	mor1k_tile #(
 		.CORE_ID(11),
		.SW_LOC("../sw/tile11") ,
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
	)the_mor1k_tile_11(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[11]) , 
		.ni_credit_out(ni_credit_out[11]) , 
		.ni_current_e_addr(4'd11) , 
		.ni_current_r_addr(4'd11) , 
		.ni_flit_in(ni_flit_in[11]) , 
		.ni_flit_in_wr(ni_flit_in_wr[11]) , 
		.ni_flit_out(ni_flit_out[11]) , 
		.ni_flit_out_wr(ni_flit_out_wr[11]),
        .trigger(trigger_11),
        .trace(trace_11)  
	);
 

 // Tile:12 (12)
   	mor1k_tile #(
 		.CORE_ID(12),
		.SW_LOC("../sw/tile12") ,
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
	)the_mor1k_tile_12(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[12]) , 
		.ni_credit_out(ni_credit_out[12]) , 
		.ni_current_e_addr(4'd12) , 
		.ni_current_r_addr(4'd12) , 
		.ni_flit_in(ni_flit_in[12]) , 
		.ni_flit_in_wr(ni_flit_in_wr[12]) , 
		.ni_flit_out(ni_flit_out[12]) , 
		.ni_flit_out_wr(ni_flit_out_wr[12]),
        .trigger(trigger_12),
        .trace(trace_12)  
	);
 

 // Tile:13 (13)
   	mor1k_tile #(
 		.CORE_ID(13),
		.SW_LOC("../sw/tile13") ,
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
	)the_mor1k_tile_13(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[13]) , 
		.ni_credit_out(ni_credit_out[13]) , 
		.ni_current_e_addr(4'd13) , 
		.ni_current_r_addr(4'd13) , 
		.ni_flit_in(ni_flit_in[13]) , 
		.ni_flit_in_wr(ni_flit_in_wr[13]) , 
		.ni_flit_out(ni_flit_out[13]) , 
		.ni_flit_out_wr(ni_flit_out_wr[13]),
        .trigger(trigger_13),
        .trace(trace_13)  
	);
 

 // Tile:14 (14)
   	mor1k_tile #(
 		.CORE_ID(14),
		.SW_LOC("../sw/tile14") ,
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
	)the_mor1k_tile_14(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[14]) , 
		.ni_credit_out(ni_credit_out[14]) , 
		.ni_current_e_addr(4'd14) , 
		.ni_current_r_addr(4'd14) , 
		.ni_flit_in(ni_flit_in[14]) , 
		.ni_flit_in_wr(ni_flit_in_wr[14]) , 
		.ni_flit_out(ni_flit_out[14]) , 
		.ni_flit_out_wr(ni_flit_out_wr[14]),
        .trigger(trigger_14),
        .trace(trace_14)  
	);
 

 // Tile:15 (15)
   	mor1k_tile #(
 		.CORE_ID(15),
		.SW_LOC("../sw/tile15") ,
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
	)the_mor1k_tile_15(
 
		.source_clk_in(clk) , 
		.cpu_cpu_en(processors_en) , 
		.source_reset_in(reset) , 
		.uart_RxD_din_sim( ) , 
		.uart_RxD_ready_sim( ) , 
		.uart_RxD_wr_sim( ) , 
		.ni_credit_in(ni_credit_in[15]) , 
		.ni_credit_out(ni_credit_out[15]) , 
		.ni_current_e_addr(4'd15) , 
		.ni_current_r_addr(4'd15) , 
		.ni_flit_in(ni_flit_in[15]) , 
		.ni_flit_in_wr(ni_flit_in_wr[15]) , 
		.ni_flit_out(ni_flit_out[15]) , 
		.ni_flit_out_wr(ni_flit_out_wr[15]),
        .trigger(trigger_15),
        .trace(trace_15)  
	);

	assign trigger = (trigger_0|trigger_1|trigger_2|trigger_3|trigger_4|trigger_5|trigger_6|trigger_7|trigger_8|trigger_9|trigger_10|trigger_11|trigger_12|trigger_13|trigger_14|trigger_15|trigger_NOC);
	assign trace = trigger_NOC? trace_NOC : (trigger_0? trace_0 : (trigger_1? trace_1 :(trigger_2? trace_2 : (trigger_3? trace_3: (trigger_4? trace_4: (trigger_5? trace_5: (trigger_6? trace_6: (trigger_7? trace_7: (trigger_8? trace_8: (trigger_9? trace_9: (trigger_10? trace_10: (trigger_11? trace_11: (trigger_12? trace_12: (trigger_13? trace_13: (trigger_14? trace_14: trace_15)))))))))))))));

	trace_buffer #(
    	.Fpay (32),
    	.TB_Depth(512)
	)  the_trace_buffer (
        .trace(trace),     // Data in
        .trigger(trigger),   // Write enable
        .rd(),   // Read the buffer using JTaG
        .dout(),    // Data out
        .reset(reset),
        .clk(clk)
        // ssa_rd
    );

 
endmodule
