`timescale 1ns / 1ps

module Bus_testbench	;
	
	// Signals to the bus

	reg [31:0]	tb_Mem_DataMem_In			;
	reg			tb_Mem_DataMem_Ready		;

	reg			Arb_M_0_DataMem_Read 		;
	reg			Arb_M_1_DataMem_Read 		;
	reg			Arb_M_2_DataMem_Read 		;
	reg			Arb_M_3_DataMem_Read 		;

	reg	[3:0]   Arb_M_0_DataMem_Write 		;
	reg	[3:0]   Arb_M_1_DataMem_Write 		;
	reg	[3:0]   Arb_M_2_DataMem_Write 		;
	reg	[3:0]   Arb_M_3_DataMem_Write	 	;

	reg	[29:0]	Arb_M_0_DataMem_Address 	;
	reg	[29:0]	Arb_M_1_DataMem_Address 	;
	reg	[29:0]	Arb_M_2_DataMem_Address 	;
	reg	[29:0]	Arb_M_3_DataMem_Address 	;
	
	reg	[31:0]	Arb_M_0_DataMem_Out 		;
	reg	[31:0]	Arb_M_1_DataMem_Out 		;
	reg	[31:0]	Arb_M_2_DataMem_Out 		;
	reg	[31:0]	Arb_M_3_DataMem_Out 		;







	//Signals from the bus

	wire [31:0]	tb_Arb_M_0_DataMem_In	;
	wire [31:0]	tb_Arb_M_1_DataMem_In	;
	wire [31:0]	tb_Arb_M_2_DataMem_In	;
	wire [31:0]	tb_Arb_M_3_DataMem_In	;
	wire 		tb_Arb_M_DataMem_Ready	[3:0]	;


	Bus uut(
		.Mem_DataMem_In			(tb_Mem_DataMem_In		)		,
		.Mem_DataMem_Ready		(tb_Mem_DataMem_Ready	)		,	
		.Arb_M_0_DataMem_In 	(tb_Arb_M_0_DataMem_In	)	 	,
		.Arb_M_1_DataMem_In 	(tb_Arb_M_1_DataMem_In	)	 	,
		.Arb_M_2_DataMem_In 	(tb_Arb_M_2_DataMem_In	)	 	,
		.Arb_M_3_DataMem_In 	(tb_Arb_M_3_DataMem_In	)	 	,
		.Arb_M_DataMem_Ready	(tb_Arb_M_DataMem_Ready	)



		)	;

	initial 
		begin
		#10 tb_Mem_DataMem_In = 32'd0;		
		#10	tb_Mem_DataMem_Ready = 1'b0;

		#10 tb_Mem_DataMem_In = 32'd1;		
		#10	tb_Mem_DataMem_Ready = 1'b1;


		
		end

endmodule