`timescale 1ns / 1ps


/*
* File			: Top.v
* Project 		: Univeristy of Patras, Computer engineering & informatics dept.
*			 	  Design of a multicore system based on the mips32 processor.
* Creator(s)	: Odysseas Papadakis	
*
* Description: 
*				This module instantiates : 
*				The bus (INST and DATA ),
*				the bus Arbiter ,
*				the arbitration Modules,  
*				the cores
*				the wiring that connects the above
*				It attaches each core to an arbitration module, 
*				 
*				 each arbitration module to the bus and the arbiter
*				
*
*
*
*/

module Top(

	input clock,
	input reset,
    input  [19:0] Interrupts,         //5 x4 g hw interrupts
    input  [3:0] NMI,                 //1 x4 Non-maskable interrupt

    // Data Memory Interface

    input  [31:0] DataMem_In,
    input  DataMem_Ready,

    output			DataMem_Read,
    output [3:0]  	DataMem_Write,
    output [29:0] 	DataMem_Address,
    output [31:0] 	DataMem_Out,

    // Instruction Memory Interface

	input  			InstMem_Ready,  	
    input  [31:0]	InstMem_In,

	output [29:0]	InstMem_Address, 
	output 			InstMem_Read,


    output [27:0] IP 				//	7 x 4 Pending interrupts (diagnostic)
);	




	// wires connecting the Arbitration modules to the Arbiter

		wire	[3:0]	D_Bus_RQ;
		wire	[3:0]	D_Bus_GRANT;

		wire	[3:0]	I_Bus_RQ;
		wire	[3:0]	I_Bus_GRANT;		


	//	Wires connecting the Cores to the Arbitration Modules	(CA)
		//Data
		wire	[31:0] 	CA_DataMem_In		[3:0];
		wire			CA_DataMem_Ready	[3:0];
		wire			CA_DataMem_Read		[3:0];
		wire	[3:0]  	CA_DataMem_Write 	[3:0];
		wire	[29:0] 	CA_DataMem_Address	[3:0];
		wire	[31:0] 	CA_DataMem_Out		[3:0];

		//Instruction
		wire			CA_InstMem_Ready	[3:0];
		wire	[31:0] 	CA_InstMem_In		[3:0];
		wire	[29:0] 	CA_InstMem_Address	[3:0];
		wire			CA_InstMem_Read		[3:0];


	//	Wires connecting the arbitration modules to the bus	(AB)
		//Data
		wire	[31:0]	AB_DataMem_In		;//[3:0];
		wire			AB_DataMem_Ready	;//[3:0];
		wire			AB_DataMem_Read		;//[3:0];
		wire	[3:0]  	AB_DataMem_Write 	;//[3:0];
		wire	[29:0] 	AB_DataMem_Address	;//[3:0];
		wire	[31:0] 	AB_DataMem_Out		;//[3:0];

		//Instruction
		wire			AB_InstMem_Ready	;//[3:0];
		wire	[31:0] 	AB_InstMem_In		;//[3:0];
		wire			AB_InstMem_Read		;//[3:0];			
		wire	[29:0] 	AB_InstMem_Address	;//[3:0];







	Bus Bus_0(

		// DATA BUS

			// Data Signals coming from the Memory System
			.Mem_DataMem_In			(DataMem_In			),
			.Mem_DataMem_Ready		(DataMem_Ready		),

			// Data Signals coming from the Arbitration Modules
			.Arb_M_DataMem_Read		(AB_DataMem_Read	),
			.Arb_M_DataMem_Write	(AB_DataMem_Write 	),
			.Arb_M_DataMem_Address	(AB_DataMem_Address	),
			.Arb_M_DataMem_Out		(AB_DataMem_Out		),			

			// Data Signals going to the Memory System
			.Mem_DataMem_Read		(DataMem_Read		),
			.Mem_DataMem_Write		(DataMem_Write		),
			.Mem_DataMem_Address	(DataMem_Address	),
			.Mem_DataMem_Out		(DataMem_Out		),
	
			// Data Signals going to the Arbitration Modules
			.Arb_M_DataMem_In		(AB_DataMem_In		),
			.Arb_M_DataMem_Ready	(AB_DataMem_Ready	),

		// INSTRUCTION BUS

			// Instruction signals coming from the Arbitration Modules
			.Arb_M_InstMem_Read		(AB_InstMem_Read		),
			.Arb_M_InstMem_Address	(AB_InstMem_Address		),	

			// Instruction signals going to the Memory System
			.Mem_InstMem_Address		(InstMem_Address	),	
			.Mem_InstMem_Read		(InstMem_Read	),


			// Instruction signals coming from the Memory System
			.Mem_InstMem_Ready		(InstMem_Ready	),
			.Mem_InstMem_In			(InstMem_In	),

			// Instruction signals going to the Arbitration Modules
			.Arb_M_InstMem_Ready		(AB_InstMem_Ready	),
			.Arb_M_InstMem_In		(AB_InstMem_In		)


		);



	ArbitrationSubModule Arb_M_0(
		
		//Connections to/from the Arbiter

			.I_Bus_RQ				(I_Bus_RQ[0]),		
			.I_Bus_GRANT			(I_Bus_GRANT[0]),

			.D_Bus_RQ				(D_Bus_RQ[0]),		
			.D_Bus_GRANT			(D_Bus_GRANT[0]),

		// ---Data Memory Interface---

			//	Signals coming from the Bus
			.Bus_DataMem_In			(AB_DataMem_In		),		
			.Bus_DataMem_Ready		(AB_DataMem_Ready	),

			// Signals coming from the Processor
			.P_DataMem_Read			(CA_DataMem_Read	[0]),
			.P_DataMem_Write		(CA_DataMem_Write 	[0]),
			.P_DataMem_Address		(CA_DataMem_Address	[0]),
			.P_DataMem_Out			(CA_DataMem_Out		[0]),
	
			// Signals going to the Processor
			.P_DataMem_In			(CA_DataMem_In		[0]),
			.P_DataMem_Ready		(CA_DataMem_Ready	[0]),			

			//	Signals going to the Bus
			.Bus_DataMesteam_Read	(AB_DataMem_Read	),
			.Bus_DataMem_Write		(AB_DataMem_Write 	),	
			.Bus_DataMem_Address	(AB_DataMem_Address	),
			.Bus_DataMem_Out		(AB_DataMem_Out		),	
	

		// ---Instruction Memory Interface----	

			// Signals coming from the Processor
			.P_InstMem_Address		(CA_InstMem_Address	[0]),
			.P_InstMem_Read			(CA_InstMem_Read	[0]),

			//	Signals going to the Bus
			.Bus_InstMem_Address	(AB_InstMem_Address	),
			.Bus_InstMem_Read		(AB_InstMem_Read	),

			//	Signals coming from the Bus
			.Bus_InstMem_Ready		(AB_InstMem_Ready	),
			.Bus_InstMem_In			(AB_InstMem_In		),
	
			// Signals going to the Processor
			.P_InstMem_Ready		(CA_InstMem_Ready	[0]),
			.P_InstMem_In			(CA_InstMem_In		[0])
		
	

		);
	
	ArbitrationSubModule Arb_M_1(


		//Connections to the Arbiter
		.I_Bus_RQ				(I_Bus_RQ[1]),		
		.I_Bus_GRANT			(I_Bus_GRANT[1]),	
		.D_Bus_RQ				(D_Bus_RQ[1]),		
		.D_Bus_GRANT			(D_Bus_GRANT[1]),	

		// ---Data Memory Interface---

			//	Signals coming from the Bus
			.Bus_DataMem_In			(AB_DataMem_In		),		
			.Bus_DataMem_Ready		(AB_DataMem_Ready	),

			// Signals coming from the Processor
			.P_DataMem_Read			(CA_DataMem_Read	[1]),
			.P_DataMem_Write		(CA_DataMem_Write 	[1]),
			.P_DataMem_Address		(CA_DataMem_Address	[1]),
			.P_DataMem_Out			(CA_DataMem_Out		[1]),
	
			// Signals going to the Processor
			.P_DataMem_In			(CA_DataMem_In		[1]),
			.P_DataMem_Ready		(CA_DataMem_Ready	[1]),			

			//	Signals going to the Bus
			.Bus_DataMesteam_Read	(AB_DataMem_Read	),
			.Bus_DataMem_Write		(AB_DataMem_Write 	),	
			.Bus_DataMem_Address	(AB_DataMem_Address	),
			.Bus_DataMem_Out		(AB_DataMem_Out		),	
	

		// ---Instruction Memory Interface----	

			// Signals coming from the Processor
			.P_InstMem_Address		(CA_InstMem_Address	[1]),
			.P_InstMem_Read			(CA_InstMem_Read	[1]),

			//	Signals going to the Bus
			.Bus_InstMem_Address	(AB_InstMem_Address	),
			.Bus_InstMem_Read		(AB_InstMem_Read	),

			//	Signals coming from the Bus
			.Bus_InstMem_Ready		(AB_InstMem_Ready	),
			.Bus_InstMem_In			(AB_InstMem_In		),
	
			// Signals going to the Processor
			.P_InstMem_Ready		(CA_InstMem_Ready	[1]),
			.P_InstMem_In			(CA_InstMem_In		[1])

		);
	ArbitrationSubModule Arb_M_2(


		//Connections to the Arbiter
		.I_Bus_RQ				(I_Bus_RQ[2]),		
		.I_Bus_GRANT			(I_Bus_GRANT[2]),	
		.D_Bus_RQ				(D_Bus_RQ[2]),		
		.D_Bus_GRANT			(D_Bus_GRANT[2]),

		// ---Data Memory Interface---

			//	Signals coming from the Bus
			.Bus_DataMem_In			(AB_DataMem_In		),		
			.Bus_DataMem_Ready		(AB_DataMem_Ready	),

			// Signals coming from the Processor
			.P_DataMem_Read			(CA_DataMem_Read	[2]),
			.P_DataMem_Write		(CA_DataMem_Write 	[2]),
			.P_DataMem_Address		(CA_DataMem_Address	[2]),
			.P_DataMem_Out			(CA_DataMem_Out		[2]),
	
			// Signals going to the Processor
			.P_DataMem_In			(CA_DataMem_In		[2]),
			.P_DataMem_Ready		(CA_DataMem_Ready	[2]),			

			//	Signals going to the Bus
			.Bus_DataMesteam_Read	(AB_DataMem_Read	),
			.Bus_DataMem_Write		(AB_DataMem_Write 	),	
			.Bus_DataMem_Address	(AB_DataMem_Address	),
			.Bus_DataMem_Out		(AB_DataMem_Out		),	
	

		// ---Instruction Memory Interface----	

			// Signals coming from the Processor
			.P_InstMem_Address		(CA_InstMem_Address	[2]),
			.P_InstMem_Read			(CA_InstMem_Read	[2]),

			//	Signals going to the Bus
			.Bus_InstMem_Address	(AB_InstMem_Address	),
			.Bus_InstMem_Read		(AB_InstMem_Read	),

			//	Signals coming from the Bus
			.Bus_InstMem_Ready		(AB_InstMem_Ready	),
			.Bus_InstMem_In			(AB_InstMem_In		),
	
			// Signals going to the Processor
			.P_InstMem_Ready		(CA_InstMem_Ready	[2]),
			.P_InstMem_In			(CA_InstMem_In		[2])
		);
	ArbitrationSubModule Arb_M_3(


		//Connections to the Arbiter
		.I_Bus_RQ				(I_Bus_RQ[3]),		
		.I_Bus_GRANT			(I_Bus_GRANT[3]),	
		.D_Bus_RQ				(D_Bus_RQ[3]),		
		.D_Bus_GRANT			(D_Bus_GRANT[3]),

		// ---Data Memory Interface---

			//	Signals coming from the Bus
			.Bus_DataMem_In			(AB_DataMem_In		),		
			.Bus_DataMem_Ready		(AB_DataMem_Ready	),

			// Signals coming from the Processor
			.P_DataMem_Read			(CA_DataMem_Read	[3]),
			.P_DataMem_Write		(CA_DataMem_Write 	[3]),
			.P_DataMem_Address		(CA_DataMem_Address	[3]),
			.P_DataMem_Out			(CA_DataMem_Out		[3]),
	
			// Signals going to the Processor
			.P_DataMem_In			(CA_DataMem_In		[3]),
			.P_DataMem_Ready		(CA_DataMem_Ready	[3]),			

			//	Signals going to the Bus
			.Bus_DataMesteam_Read	(AB_DataMem_Read	),
			.Bus_DataMem_Write		(AB_DataMem_Write 	),	
			.Bus_DataMem_Address	(AB_DataMem_Address	),
			.Bus_DataMem_Out		(AB_DataMem_Out		),	
	

		// ---Instruction Memory Interface----	

			// Signals coming from the Processor
			.P_InstMem_Address		(CA_InstMem_Address	[3]),
			.P_InstMem_Read			(CA_InstMem_Read	[3]),

			//	Signals going to the Bus
			.Bus_InstMem_Address	(AB_InstMem_Address	),
			.Bus_InstMem_Read		(AB_InstMem_Read	),

			//	Signals coming from the Bus
			.Bus_InstMem_Ready		(AB_InstMem_Ready	),
			.Bus_InstMem_In			(AB_InstMem_In		),
	
			// Signals going to the Processor
			.P_InstMem_Ready		(CA_InstMem_Ready	[3]),
			.P_InstMem_In			(CA_InstMem_In		[3])
		);

	BusArbiter BusArbiter_0(
	.clock  				(clock),
	.reset					(reset),

	.I_Bus_RQ				(I_Bus_RQ),
	.I_Bus_GRANT			(I_Bus_GRANT),

	.D_Bus_RQ				(D_Bus_RQ),
	.D_Bus_GRANT			(D_Bus_GRANT)

	);



	Processor P0(
		//Connections to the outside
		.clock	 			(clock),
		.reset	 			(reset),
		.Interrups			(Interrupts[4:0]),		//5 gp hw interrupts
		.NMI				(NMI[0]),				//1  Non-maskable interrupt	
		.IP					(IP[7:0]),				//7  Pending interrupts (diagnostic)

		//Connections to the Arbitration Module 

		//Data
		.DataMem_In			(CA_DataMem_In		[0]	),
		.DataMem_Ready		(CA_DataMem_Ready	[0]	),
		.DataMem_Read		(CA_DataMem_Read	[0]	),	
		.DataMem_Write		(CA_DataMem_Write 	[0]	),			
		.DataMem_Address	(CA_DataMem_Address	[0]	),
		.DataMem_Out		(CA_DataMem_Out		[0]	),

		//Instruction
		.InstMem_Ready		(CA_InstMem_Ready	[0] ),
		.InstMem_In			(CA_InstMem_In		[0] ),		
		.InstMem_Address	(CA_InstMem_Address	[0] ),
		.InstMem_Read		(CA_InstMem_Read	[0] )

);		

	Processor P1(
		//Connections to the outside
		.clock	 			(clock),
		.reset	 			(reset),
		.Interrups			(Interrupts[9:5]),	//5 gp hw interrupts	
		.NMI				(NMI[1]),			//1  Non-maskable interrupt		
		.IP					(IP[13:8]),			//7  Pending interrupts (diagnostic)

		//Connections to the Arbitration Module 

		//Data
		.DataMem_In			(CA_DataMem_In		[1]	),
		.DataMem_Ready		(CA_DataMem_Ready	[1]	),
		.DataMem_Read		(CA_DataMem_Read	[1]	),	
		.DataMem_Write		(CA_DataMem_Write 	[1]	),			
		.DataMem_Address	(CA_DataMem_Address	[1]	),
		.DataMem_Out		(CA_DataMem_Out		[1]	),

		//Instruction
		.InstMem_Ready		(CA_InstMem_Ready	[1] ),
		.InstMem_In			(CA_InstMem_In		[1] ),		
		.InstMem_Address	(CA_InstMem_Address	[1] ),
		.InstMem_Read		(CA_InstMem_Read	[1] )

);	


	Processor P2(
		//Connections to the outside
		.clock	 			(clock),
		.reset	 			(reset),
		.Interrups			(Interrupts[14:10]),  	//5 gp hw interrupts															
		.NMI				(NMI[2]),				//1  Non-maskable interrupt	
		.IP					(IP[20:14]),				//7  Pending interrupts (diagnostic)

		//Connections to the Arbitration Module 

		//Data
		.DataMem_In			(CA_DataMem_In		[2]	),
		.DataMem_Ready		(CA_DataMem_Ready	[2]	),
		.DataMem_Read		(CA_DataMem_Read	[2]	),	
		.DataMem_Write		(CA_DataMem_Write 	[2]	),			
		.DataMem_Address	(CA_DataMem_Address	[2]	),
		.DataMem_Out		(CA_DataMem_Out		[2]	),

		//Instruction
		.InstMem_Ready		(CA_InstMem_Ready	[2] ),
		.InstMem_In			(CA_InstMem_In		[2] ),		
		.InstMem_Address	(CA_InstMem_Address	[2] ),
		.InstMem_Read		(CA_InstMem_Read	[2] )

);	


	Processor P3(
		//Connections to the outside
		.clock	 			(clock),
		.reset	 			(reset),
		.Interrups			(Interrupts[19:15]),	//5 gp hw interrupts
		.NMI				(NMI[3]),			//1  Non-maskable interrupt	
		.IP					(IP[27:21]),			//7  Pending interrupts (diagnostic)

		//Connections to the Arbitration Module 

		//Data
		.DataMem_In			(CA_DataMem_In		[3]	),
		.DataMem_Ready		(CA_DataMem_Ready	[3]	),
		.DataMem_Read		(CA_DataMem_Read	[3]	),	
		.DataMem_Write		(CA_DataMem_Write 	[3]	),			
		.DataMem_Address	(CA_DataMem_Address	[3]	),
		.DataMem_Out		(CA_DataMem_Out		[3]	),

		//Instruction
		.InstMem_Ready		(CA_InstMem_Ready	[3]),
		.InstMem_In			(CA_InstMem_In		[3]),		
		.InstMem_Address	(CA_InstMem_Address	[3]),
		.InstMem_Read		(CA_InstMem_Read	[3])

);		

endmodule