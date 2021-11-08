`timescale 1ns / 1ps // <time_unit> / <time_precision>

// This is a testbench to test the functionality of the arbitration module.

/* In this testbench, we are simulating the processor, the bus and the Bus Arbiter.
* The purpose of this TB to determine wether the arbitration module can successfully
* isolate a core from the bus, based on the signals coming from the Arbiter.
*
*/

module ArbitrationSubModule_Testbench;

// Data Memory Interface  ; these signals will be connected the DATA BUS

		//	Bus --> Arbitration Module
		reg	[31:0]	tb_Bus_DataMem_In;		
		reg			tb_Bus_DataMem_Ready;		


		// Processor --> Arbitration Module
		reg 		tb_P_DataMem_Read;
		reg	[3:0]   tb_P_DataMem_Write;
		reg	[29:0]	tb_P_DataMem_Address;
		reg	[31:0]	tb_P_DataMem_Out;



		// Arbitration Module --> Processor
		wire	[31:0]	tb_P_DataMem_In;
		wire			tb_P_DataMem_Ready;


		//	Arbitration Module --> Bus
		wire			tb_Bus_DataMem_Read;		
		wire	[3:0] 	tb_Bus_DataMem_Write;		
		wire	[29:0]	tb_Bus_DataMem_Address;	
		wire	[31:0]	tb_Bus_DataMem_Out;		



	
	// Instruction Memory Interface    ; these signals will connected to  the INSTRUCTION BUS
		
		//	Bus --> Arbitration Module
		reg			tb_Bus_InstMem_Ready;
		reg	[31:0]	tb_Bus_InstMem_In;		

		// Processor --> Arbitration Module
		reg	[29:0]	tb_P_InstMem_Address;
		reg			tb_P_InstMem_Read;


		// Arbitration Module --> Bus
		wire			tb_P_InstMem_Ready;
		wire	[31:0]	tb_P_InstMem_In;

		//	Arbitration Module -- > Bus
		wire	[29:0]	tb_Bus_InstMem_Address;
		wire			tb_Bus_InstMem_Read;


			// Signals to\from the Arbiter	
		
		// Data Signaling

		wire	tb_D_Bus_RQ;		 	// Request to use the Data bus
		reg		tb_D_Bus_GRANT;        // The Data bus is ours to use

		// Instruction Signaling
		wire	tb_I_Bus_RQ;			 // Request to use the Instruction bus
		reg		tb_I_Bus_GRANT;       // The instruction bus is ours to use





ArbitrationSubModule uut(

	//Data Bus signal connections

		//uut signals 			// Testbench signal
	.Bus_DataMem_In			(tb_Bus_DataMem_In),
	.Bus_DataMem_Ready		(tb_Bus_DataMem_Ready),

	.P_DataMem_Read			(tb_P_DataMem_Read),
	.P_DataMem_Write		(tb_P_DataMem_Write	),
	.P_DataMem_Address		(tb_P_DataMem_Address),
	.P_DataMem_Out			(tb_P_DataMem_Out),

	.P_DataMem_In			(tb_P_DataMem_In),
	.P_DataMem_Ready		(tb_P_DataMem_Ready),

	.Bus_DataMem_Read		(tb_Bus_DataMem_Read),
	.Bus_DataMem_Write		(tb_Bus_DataMem_Write),
	.Bus_DataMem_Address	(tb_Bus_DataMem_Address),
	.Bus_DataMem_Out		(tb_Bus_DataMem_Out),

	.D_Bus_RQ				(tb_D_Bus_RQ),
	.D_Bus_GRANT			(tb_D_Bus_GRANT),

	//Instruction Bus signal connections

	.Bus_InstMem_Ready		(tb_Bus_InstMem_Ready),
	.Bus_InstMem_In			(tb_Bus_InstMem_In),

	.P_InstMem_Address		(tb_P_InstMem_Address),
	.P_InstMem_Read			(tb_P_InstMem_Read),

	.P_InstMem_Ready		(tb_P_InstMem_Ready),
	.P_InstMem_In			(tb_P_InstMem_In),

	.Bus_InstMem_Address	(tb_Bus_InstMem_Address),
	.Bus_InstMem_Read		(tb_Bus_InstMem_Read),

	.I_Bus_RQ				(tb_I_Bus_RQ),
	.I_Bus_GRANT			(tb_I_Bus_GRANT)


);


// The goals of the testbench are as follows:
/*
1) Verify that the arbitration submodule successfully isolates the processor from the buses
	when it has not received a Grant signal

2) Verify that the arbitration submodule succesfully forwards the signals from/to the buses
	and the processor, when it has received a Grant signal

3) Verify that the arbitration submodule succesfully groups the requests from the processor
	and forwards them to the arbiter, as a single request signal for each bus.


initial 		// Data initial block
	begin

		//Bus --> Arbitration Module
		tb_Bus_DataMem_In		= 'd63;	
		tb_Bus_DataMem_Ready	= 0;

		// Processor --> Arbitration Module
		tb_P_DataMem_Read		= 0;	
		tb_P_DataMem_Write		= 0;	
		tb_P_DataMem_Address	= 'd31;		
		tb_P_DataMem_Out		= 'd127;

		tb_D_Bus_GRANT 			= 0;	


		#100 tb_P_DataMem_Read		<= 1;
		#50 tb_D_Bus_GRANT 	<= 1'b1;
		#100 tb_P_DataMem_Read		<= 0;		
		#50 tb_D_Bus_GRANT 	<= 1'b0;




		#100 tb_P_DataMem_Write <= 4'b0001;
		#50 tb_D_Bus_GRANT 	<= 1'b1;
		#50 tb_D_Bus_GRANT 	<= 1'b0;		
		#100 tb_P_DataMem_Write <= 4'b0000;

		#100 tb_P_DataMem_Write <= 4'b0010;
		#100 tb_P_DataMem_Write <= 4'b0000;

		#100 tb_P_DataMem_Write <= 4'b0100;
		#50 tb_D_Bus_GRANT 	<= 1'b1;
		#50 tb_D_Bus_GRANT 	<= 1'b0;		
		#100 tb_P_DataMem_Write <= 4'b0000;

		#100 tb_P_DataMem_Write <= 4'b1000;
		#100 tb_P_DataMem_Write <= 4'b0000;

		#100 tb_P_DataMem_Read	<= 1'b1;

		#50 tb_D_Bus_GRANT 	<= 1'b1;
		#50 tb_D_Bus_GRANT 	<= 1'b0;

	end


initial		// Instruction initial block
	begin

	//Bus --> Arbitration Module
	tb_Bus_InstMem_Ready 	= 1'b0;
	tb_Bus_InstMem_In 		= 'd1023;


	// Processor --> Arbitration Module
	tb_P_InstMem_Address	= 'd2047;
	tb_P_InstMem_Read		= 1'b0;

	tb_I_Bus_GRANT			=1'b0;

	tb_P_InstMem_Read		= 1'b1;
	tb_P_InstMem_Read		= 1'b0;



	#100 tb_I_Bus_GRANT	<= 1'b1;
	#100 tb_I_Bus_GRANT	<= 1'b0;

	#100 tb_I_Bus_GRANT	<= 1'b1;

	#100 tb_P_InstMem_Read	<= 1'b1;
	#100 tb_P_InstMem_Read	<= 1'b0;

	#100 tb_I_Bus_GRANT	<= 1'b0;

	#100 tb_I_Bus_GRANT	<= 1'b1;

	#100 tb_Bus_InstMem_Ready	<= 1'b1;
	#100 tb_Bus_InstMem_Ready	<= 1'b0;

	#100 tb_I_Bus_GRANT	<= 1'b0;


	#100 tb_I_Bus_GRANT	<= 1'b1;
	#100 tb_I_Bus_GRANT	<= 1'b0;
	#100 tb_Bus_InstMem_Ready	<= 1'b1;


	#100 tb_Bus_InstMem_Ready	<= 1'b0;




	#100 tb_I_Bus_GRANT	<= 1'b1;
	#100 tb_I_Bus_GRANT	<= 1'b0;



	end



endmodule;