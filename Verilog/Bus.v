
`timescale 1ns / 1ps

/*
* File			: Bus.sv
* Project 		: Univeristy of Patras, Computer engineering & informatics dept.
*			 	  Design of a multicore system based on the mips32 processor.
* Creator(s)	: Odysseas Papadakis	
*
* Description: 
*				This module describes the BUS, onto which the cores, 
*				arbitration modules and the arbiter are attached.
*				It is essentially a passthrough, that has been created for
*				code segmentation. 
*				The Bus is split into a Data and an Instruction BUS.
*				
*
*
*
*/


module Bus(

		// DATA BUS

			
			//Memory System --> Bus
			input	[31:0]	Mem_DataMem_In,
			input			Mem_DataMem_Ready,
			
			 
			//Arbitration Modules --> Bus
			input 			Arb_M_0_DataMem_Read 		,
			input 			Arb_M_1_DataMem_Read 		,
			input 			Arb_M_2_DataMem_Read 		,
			input 			Arb_M_3_DataMem_Read 		,

			input	[3:0]   Arb_M_0_DataMem_Write 	,
			input	[3:0]   Arb_M_1_DataMem_Write 	,
			input	[3:0]   Arb_M_2_DataMem_Write 	,
			input	[3:0]   Arb_M_3_DataMem_Write 	,

			input	[29:0]	Arb_M_0_DataMem_Address 	,
			input	[29:0]	Arb_M_1_DataMem_Address 	,
			input	[29:0]	Arb_M_2_DataMem_Address 	,
			input	[29:0]	Arb_M_3_DataMem_Address 	,

			input	[31:0]	Arb_M_0_DataMem_Out 		,
			input	[31:0]	Arb_M_1_DataMem_Out 		,
			input	[31:0]	Arb_M_2_DataMem_Out 		,
			input	[31:0]	Arb_M_3_DataMem_Out 		,




			
			// Bus Arbiter --> Bus
			input 			Bus_arbiter_DataMem_Read	,
			input	[3:0]   Bus_arbiter_DataMem_Write	,
			input	[29:0]	Bus_arbiter_DataMem_Address	,
			input	[31:0]	Bus_arbiter_DataMem_Out 	,


			
			// Bus--> Memory System
			output			Mem_DataMem_Read,		
			output	[3:0] 	Mem_DataMem_Write,		
			output	[29:0]	Mem_DataMem_Address,	
			output	[31:0]	Mem_DataMem_Out,
	
	

			
			// Bus --> Arbitration Modules
			output		[31:0]	Arb_M_0_DataMem_In 	 	,
			output		[31:0]	Arb_M_1_DataMem_In 	 	,
			output		[31:0]	Arb_M_2_DataMem_In 	 	,
			output		[31:0]	Arb_M_3_DataMem_In 	 	,	
			
			output				Arb_M_0_DataMem_Ready	,	 
			output				Arb_M_1_DataMem_Ready	,
			output				Arb_M_2_DataMem_Ready	,
			output				Arb_M_3_DataMem_Ready	,

			
			// Bus --> Bus Arbiter
			output				Bus_arbiter_DataMem_Ready


		// INSTRUCTION BUS

			//  Arbitration Modules --> Bus
			input	[29:0]	Arb_M_0_InstMem_Address 	,
			input	[29:0]	Arb_M_1_InstMem_Address 	,
			input	[29:0]	Arb_M_2_InstMem_Address 	,
			input	[29:0]	Arb_M_3_InstMem_Address 	,

			input			Arb_M_0_InstMem_Read 		,
			input			Arb_M_1_InstMem_Read 		,
			input			Arb_M_2_InstMem_Read 		,
			input			Arb_M_3_InstMem_Read 		,

			// Bus Arbiter --> Bus
			input	[29:0]	Bus_arbiter_InstMem_Address 	,
			input			Bus_arbiter_InstMem_Read 		,

			//  Bus --> Memory System  
			output	[29:0]	Mem_InstMem_Address			,	
			output			Mem_InstMem_Read			,


			//   Memory System --> Bus
			input			Mem_InstMem_Ready			,
			input	[31:0]	Mem_InstMem_In				,

			//  Bus -->Arbitration Modules
			output			Arb_M_0_InstMem_Ready 		,
			output			Arb_M_1_InstMem_Ready 		,
			output			Arb_M_2_InstMem_Ready 		,
			output			Arb_M_3_InstMem_Ready 		,

			output	[31:0]	Arb_M_0_InstMem_In 			,
			output	[31:0]	Arb_M_1_InstMem_In 			,
			output	[31:0]	Arb_M_2_InstMem_In 			,
			output	[31:0]	Arb_M_3_InstMem_In 			,

			// Bus --> Bus Arbiter
			output 			Mem_InstMem_Ready
	);

			//Data bus assignments

			
		assign  Mem_DataMem_Read	=	Arb_M_0_DataMem_Read		;
		assign  Mem_DataMem_Read	=	Arb_M_1_DataMem_Read		;
		assign  Mem_DataMem_Read	=	Arb_M_2_DataMem_Read		;
		assign  Mem_DataMem_Read	=	Arb_M_3_DataMem_Read		;

		assign  Mem_DataMem_Write	=	Arb_M_0_DataMem_Write		;
		assign  Mem_DataMem_Write	=	Arb_M_1_DataMem_Write		;
		assign  Mem_DataMem_Write	=	Arb_M_2_DataMem_Write		;
		assign  Mem_DataMem_Write	=	Arb_M_3_DataMem_Write		;

		assign  Mem_DataMem_Address	=	Arb_M_0_DataMem_Address		;
		assign  Mem_DataMem_Address	=	Arb_M_1_DataMem_Address		;
		assign  Mem_DataMem_Address	=	Arb_M_2_DataMem_Address		;
		assign  Mem_DataMem_Address	=	Arb_M_3_DataMem_Address		;
	
		assign  Mem_DataMem_Out		=	Arb_M_0_DataMem_Out			;
		assign  Mem_DataMem_Out		=	Arb_M_1_DataMem_Out			;
		assign  Mem_DataMem_Out		=	Arb_M_2_DataMem_Out			;
		assign  Mem_DataMem_Out		=	Arb_M_3_DataMem_Out			;	


		assign		Arb_M_0_DataMem_In	=	Mem_DataMem_In			;
		assign		Arb_M_1_DataMem_In	=	Mem_DataMem_In			;
		assign		Arb_M_2_DataMem_In	=	Mem_DataMem_In			;
		assign		Arb_M_3_DataMem_In	=	Mem_DataMem_In			;


		assign	Arb_M_0_DataMem_Ready		=	Mem_DataMem_Ready	;
		assign	Arb_M_1_DataMem_Ready		=	Mem_DataMem_Ready	;
		assign	Arb_M_2_DataMem_Ready		=	Mem_DataMem_Ready	;
		assign	Arb_M_3_DataMem_Ready		=	Mem_DataMem_Ready	;




		// Instruction bus assignments

			
		assign	Mem_InstMem_Address	=	Arb_M_0_InstMem_Address	 ;
		assign	Mem_InstMem_Address	=	Arb_M_1_InstMem_Address	 ;
		assign	Mem_InstMem_Address	=	Arb_M_2_InstMem_Address	 ;
		assign	Mem_InstMem_Address	=	Arb_M_3_InstMem_Address	 ;			
		

		assign  Mem_InstMem_Read	=	Arb_M_0_InstMem_Read		;
		assign  Mem_InstMem_Read	=	Arb_M_1_InstMem_Read		;
		assign  Mem_InstMem_Read	=	Arb_M_2_InstMem_Read		;
		assign  Mem_InstMem_Read	=	Arb_M_3_InstMem_Read		;



		assign	Arb_M_0_InstMem_Ready		=	Mem_InstMem_Ready	;
		assign	Arb_M_1_InstMem_Ready		=	Mem_InstMem_Ready	;
		assign	Arb_M_2_InstMem_Ready		=	Mem_InstMem_Ready	;
		assign	Arb_M_3_InstMem_Ready		=	Mem_InstMem_Ready	;


		assign	Arb_M_0_InstMem_In		=	Mem_InstMem_In		;
		assign	Arb_M_1_InstMem_In		=	Mem_InstMem_In		;
		assign	Arb_M_2_InstMem_In		=	Mem_InstMem_In		;
		assign	Arb_M_3_InstMem_In		=	Mem_InstMem_In		;



endmodule
