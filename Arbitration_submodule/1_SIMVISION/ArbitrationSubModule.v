`timescale 1ns / 1ps

/*
* File			: ArbitrationSubModule.v
* Project 		: Univeristy of Patras, Computer engineering & informatics dept.
*			 	  Design of a multicore system based on the mips32 processor.
* Creator(s)	: Odysseas Papadakis	
*
* Description: 
*				
*				An arbitration submodule stands between each processor and the system buses ( Data and Instruction )
*				Its job is to either isolate the processor from the bus, or connect it to the bus
*
*				The logic is the following : 
*
*				When no R/W signals are HIGH from the processor, the outputs of the module touching the Bus are set to HIGH-Z.
*				Additionally the outputs connected to the processor are all LOW. Indicating that there is no data for the 
*				processor to Grab. 
*				(we can call this the idle state)
*
*				When any R/W signal goes HIGH from the processor, the Arbitration module sends a Bus Request (Bus_RQ)
*				to the Bus Arbiter , for the corresponding Bus.
*				(we can call this the request_sent state)
*
*				Once the Bus Arbiter sets Bus_Grant to HIGH,  the BUS is ours. 
*				The outputs of the processor are allowed to drive the Bus. Additionally the inputs of the processor
*				are allowed to be driven by the bus.
*				(we can call this the bus_connected state )
*
*				
*				Once the Bus Arbiter sets Bus_Grant to LOW,  the processor is disconnected from the bus.
*				We return to the idle state
*
*
*
*
*
*/

module ArbitrationSubModule(

// Data Memory Interface	---------------------------------------------------

	//	Bus Signals 

		//	Bus --> Arbitration SubModule
		input	[31:0]	Bus_DataMem_In,		//	( Memory Content Signal )
		input			Bus_DataMem_Ready,	//	( Memory Control Signal )

		//	Arbitration SubModule --> Bus		( Memory Control Signals )
		output			Bus_DataMem_Read,		
		output	[3:0] 	Bus_DataMem_Write,		
		output	[29:0]	Bus_DataMem_Address,	
		output	[31:0]	Bus_DataMem_Out,		


	//	Processor Signals

		// Processor --> Arbitration SubModule  	( Memory Control Signals )
		input 			P_DataMem_Read,
		input	[3:0]   P_DataMem_Write,
		input	[29:0]	P_DataMem_Address,
		input	[31:0]	P_DataMem_Out,

		// Arbitration SubModule --> Processor
		output	[31:0]	P_DataMem_In,		//	( Memory Content Signal )
		output			P_DataMem_Ready,	//	( Memory Control Signal )


	//	Arbiter Signals

		// Bus Arbiter --> Arbitration SubModule
		input	D_Bus_GRANT,   
		// Arbitration SubModule --> Bus Arbiter
		output	D_Bus_RQ,		 	


// Instruction Memory Interface  ------------------------------------------------  

	//	Bus Signals


		//	Bus --> Arbitration SubModule
		input			Bus_InstMem_Ready,
		input	[31:0]	Bus_InstMem_In,

		//	Arbitration SubModule --> Bus
		output	[29:0]	Bus_InstMem_Address,
		output			Bus_InstMem_Read,

	//	Processor Signals	

		// Processor --> Arbitration SubModule
		input	[29:0]	P_InstMem_Address,
		input			P_InstMem_Read,

		// Arbitration SubModule --> Processor
		output			P_InstMem_Ready,
		output	[31:0]	P_InstMem_In,


	//	Arbiter Signals

		 
		//Bus Arbiter --> Arbitration SubModule
		input	I_Bus_GRANT,  

		// Arbitration SubModule --> Bus Arbiter
		output	I_Bus_RQ   
		
	);  


	      
	// Instruction Memory Interface Assignments  ---------------------------------------------------------------

		//Arbitration SubModule --> Bus Arbiter

			
	  	assign I_Bus_RQ = P_InstMem_Read ; // When the processor wants an instruction, request the Instruction bus from the Bus Arbiter 
		
		//Arbitration SubModule --> Instruction Bus
	  	assign Bus_InstMem_Read		= 	(I_Bus_GRANT) ? P_InstMem_Read			: 1'bz;  // When Grant is LOW, set the outputs to HIGH-Z
	  	assign Bus_InstMem_Address 	= 	(I_Bus_GRANT) ? P_InstMem_Address		: 30'bz; // To avoid contamination of the Bus

	  	//Arbitration SubModule --> Processor
	  	
	  	assign P_InstMem_Ready		= 	(I_Bus_GRANT) ? Bus_InstMem_Ready 		: 1'b0;	 // When Grant is LOW, Tell the processor: Instruction is not ready

	  	assign P_InstMem_In 		=	(I_Bus_GRANT) ? Bus_InstMem_In			: 32'b0; // When Grant is LOW, show zeros to the processor						 





	 // Data memory Interface Assignments  --------------------------------------------------------------------

	 	//Arbitration SubModule --> Bus Arbiter
	 		// When the processor wants some Data, request the Data bus from the Bus Arbiter
	 	assign D_Bus_RQ = ( P_DataMem_Read | P_DataMem_Write[3] | P_DataMem_Write[2] | P_DataMem_Write[1] | P_DataMem_Write[0]);

	 	//Arbitration SubModule --> Data Bus
	 		
	 		
		assign Bus_DataMem_Read			= 	(D_Bus_GRANT) ? P_DataMem_Read 		: 1'bz;  // When Grant is LOW, set the signals to HIGH-Z
		assign Bus_DataMem_Write		= 	(D_Bus_GRANT) ? P_DataMem_Write		: 4'bz;	 // To avoid contamination of the Bus
		assign Bus_DataMem_Address		= 	(D_Bus_GRANT) ? P_DataMem_Address 	: 30'bz; // When Grant is HIGH, forward the values to the bus
		assign Bus_DataMem_Out			= 	(D_Bus_GRANT) ? P_DataMem_Out 		: 32'bz; // 

	 	//Arbitration SubModule --> Processor
	 		
		assign P_DataMem_Ready 			=	(D_Bus_GRANT) ? Bus_DataMem_Ready	: 1'b0;  // When Grant is LOW, Tell the processor memory is not ready
		assign P_DataMem_In 			= 	(D_Bus_GRANT) ? Bus_DataMem_In		: 32'b0; // When Grant is LOW, show zeros to the processor
		

endmodule

