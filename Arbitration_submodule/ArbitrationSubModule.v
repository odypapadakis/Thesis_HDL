`timescale 1ns / 1ps // <time_unit> / <time_precision>

/*
* File			: ArbitrationSubModule.v
* Project 		: Design of a multicore system based on the mips32 processor.  
* Creator(s)	: Odysseas Papadakis	Univeristy of Patras, Computer engineering & informatics dept.
*
* Description	: 
*				
*					The arbitration submodule stands between each processor and the system buses.
*					It forwards requests from the processor to the bus arbiter
*					It Isolates or connects the processor to the system buses, based on input from the bus arbiter
*					A more detailed description follows.
*
*					With regard to the  Data bus, the arbitration submodule performs the following :
*					It Groups the 
*						P_DataMem_Read, 
*						P_DataMem_Write, 
*						P_DataMem_Address, 
*						P_DataMem_Out 
*					signals, into a single Data Bus usage request signal (D_Bus_RQ).
*
*					Whenever one of the original 4 signals goes HIGH ,meaning the processor wants to interact with the Data Bus,
*					the arbitration submodule sets D_Bus_RQ HIGH, to signal to the Bus Arbiter that the processor wants to use the 
*					Data Bus.
*
*					As long as the incoming from the processor signal "D_Bus_GRANT", remains LOW, the arbitration submodule keeps 
*					the processor isolated from the bus, via the usage of a tri-state buffer that has been set to HIGH-Z.
*					The processor is prevented from either driving the bus, or being driven by the bus.
*
*					When eventually "D_Bus_Grant" goes HIGH, the arbitration submodule allows
*					the signals of the processor to connect to the bus
*	
*					
*	test_comment
*/

module ArbitrationSubModule(
	// Signals to\from the Bus & the processor

		// Data Memory Interface  , these signals will be connected the DATA BUS and the data outputs of the processor

			//	Bus --> Arbitration SubModule
			input	[31:0]	Bus_DataMem_In,	
			input			Bus_DataMem_Ready,		

			// Processor --> Arbitration SubModule
			input 			P_DataMem_Read,
			input	[3:0]   P_DataMem_Write,
			input	[29:0]	P_DataMem_Address,
			input	[31:0]	P_DataMem_Out,

			// Arbitration SubModule --> Processor
			output	[31:0]	P_DataMem_In,
			output			P_DataMem_Ready,

			//	Arbitration SubModule --> Bus
			output			Bus_DataMem_Read,		
			output	[3:0] 	Bus_DataMem_Write,		
			output	[29:0]	Bus_DataMem_Address,	
			output	[31:0]	Bus_DataMem_Out,		

		// Instruction Memory Interface    , these signals will connected to  the INSTRUCTION BUS and the instruction outputs of the processor
			
			//	Bus --> Arbitration SubModule           
			input			Bus_InstMem_Ready,   
			input	[31:0]	Bus_InstMem_In,		

			// Processor --> Arbitration SubModule
			input	[29:0]	P_InstMem_Address,
			input			P_InstMem_Read,

			// Arbitration SubModule --> Processor
			output			P_InstMem_Ready,
			output	[31:0]	P_InstMem_In,

			//	Arbitration SubModule --> Bus
			output	[29:0]	Bus_InstMem_Address,
			output			Bus_InstMem_Read,

	// Signals to\from the Arbiter	
		
		// Data Bus 
			// Arbitration SubModule --> Bus Arbiter
			output	D_Bus_RQ,		 	// Request to use the Data bus
			// Bus Arbiter --> Arbitration SubModule
			input	D_Bus_GRANT,        // The Data bus is ours to use

		// Instruction Bus
			// Arbitration SubModule --> Bus Arbiter
			output	I_Bus_RQ,			 // Request to use the Instruction bus
			//Bus Arbiter --> Arbitration SubModule
			input	I_Bus_GRANT       // The instruction bus is ours to use
		
	);     
	      
	// Instruction Memory Interface   ---------------------------------------------------------------

		//Arbitration SubModule --> Bus Arbiter
			// When the processor wants to read instruction data, set the Instruction Bus Request to HIGH
	  	assign I_Bus_RQ = P_InstMem_Read ;  
		
		//Arbitration SubModule --> Instruction Bus
	  	assign Bus_InstMem_Read		= 	(I_Bus_GRANT) ? P_InstMem_Read			: 1'bz;
	  	assign Bus_InstMem_Address 	= 	(I_Bus_GRANT) ? P_InstMem_Address		: 30'bz;

	  	//Arbitration SubModule --> Processor
	  	assign P_InstMem_Ready		= 	(I_Bus_GRANT) ? Bus_InstMem_Ready 		: 1'b0;
	  	assign P_InstMem_In 		=	Bus_InstMem_In;





	 // Data memory Interface  --------------------------------------------------------------------

	 	//Arbitration SubModule --> Bus Arbiter
	 		// When the processor wants to read or write, generate a bus request
	 		// The data bus requests are grouped as a single data bus request signal
	 	assign D_Bus_RQ = ( P_DataMem_Read | P_DataMem_Write[3] | P_DataMem_Write[2] | P_DataMem_Write[1] | P_DataMem_Write[0]);

	 	//Arbitration SubModule --> Data Bus
	 		// If we have been given control of the bus, forward the data from the processor, on the bus
	 		// 	else set the outputs to HIGH-Z to avoid bus contamination.
		assign Bus_DataMem_Read			= 	(D_Bus_GRANT) ? P_DataMem_Read 		: 1'bz;
		assign Bus_DataMem_Write		= 	(D_Bus_GRANT) ? P_DataMem_Write		: 4'bz;
		assign Bus_DataMem_Address		= 	(D_Bus_GRANT) ? P_DataMem_Address 	: 30'bz;
		assign Bus_DataMem_Out			= 	(D_Bus_GRANT) ? P_DataMem_Out 		: 32'bz;

	 	//Arbitration SubModule --> Processor
	 		
		assign P_DataMem_Ready 			=	(D_Bus_GRANT) ? Bus_DataMem_Ready	: 1'b0;
		assign P_DataMem_In 			= 	(D_Bus_GRANT) ? Bus_DataMem_In		: 32'b0;

endmodule
