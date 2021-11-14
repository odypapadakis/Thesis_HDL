//`timescale 1ns / 1ps  // <time_unit>/<time_precision>  

/*
* File			: ArbitrationSubModule.v
* Project 		: Univeristy of Patras, Computer engineering & informatics dept.
*			 	  Design of a multicore system based on the mips32 processor.
* Creator(s)	: Odysseas Papadakis	
*
* Description: 
*				
*				An arbitration submodule stands between each processor and the system buses ( Data and Instruction ).
				The 2 buses of the system are shared by all the arbitration modules.
*	---DELETE	The two buses are independent of eachother and can therefore be used simultaneously.
*				
*
*				The modules job  is to either isolate the processor from the bus, or connect it to the bus.



			1) 	Initially, the arbitration module isolates its processor from the buses.
				The requests signals to the Arbiter are LOW ( D_Bus_RQ, I_Bus_RQ)
				At this point the inputs from the Arbiter should be LOW for both Grant signals ( D_Bus_GRANT, I_Bus_GRANT).
				It feeds zeroes to the inputs of the processor.

	----PROBLEM? ( are the zeroes being fed to the buses )
	----ANSWER	(no, the inputs from the buses are inputs to a MUX . Source :Synthesis)

				And puts the tri state buffers of its outputs facing the buses at HIGH-Z.
				Therefore the processor does not have access to the data being circulated on the bus 
				and the bus can not be driven by the processor.
*
*			2)	When a processor want to use a BUS, it raises one of the following signals to HIGH:
*				
*				(  For the Data Bus )
*				P_DataMem_Read
*				P_DataMem_Write
*				P_DataMem_Address
*				P_DataMem_Out

				( For the Instruction Bus )
				P_InstMem_Read
*				
				The module will in turn raise the appropriate signal to HIGH
				D_Bus_RQ - Goes HIGH to signal to the arbiter that the processor wants to use the Data Bus
				I_Bus_RQ - Goes HIGH to signal to the arbiter that the processor wants to use the Instruction Bus

				Then the module will wait for the Arbiter to give it the instruction to connect the processor to the bus

			3)	When the Arbiter drives the grant signal HIGH ( either for the data or the instruction bus)
				The arbitration module allows the bus from the data to drive the inputs of the processor
				and switches from showing HIGH-Z to the buses, to connecting the bus with the outputs of the processor.



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
	  	assign Bus_InstMem_Read		= 	(I_Bus_GRANT) ? P_InstMem_Read			: 1'bz;  // When Grant is LOW, set the bus outputs  to HIGH-Z
	  	assign Bus_InstMem_Address 	= 	(I_Bus_GRANT) ? P_InstMem_Address		: 30'bz; // To avoid contamination of the Bus

	  	//Arbitration SubModule --> Processor
	  	assign P_InstMem_Ready		= 	(I_Bus_GRANT) ? Bus_InstMem_Ready 		: 1'b0;	 // When Grant is LOW, Tell the processor: Instruction is not ready
	  	assign P_InstMem_In 		=	(I_Bus_GRANT) ? Bus_InstMem_In			: 32'b0; // When Grant is LOW, show zeros to the processor						 
	  	
	  	// POSSIBLE PROBLEM 
	  	// are we driving the bus to zero as well? or just the processor signals ?
	  	// See how it is synthesized, might need an inout port instead of input ( Bus_InstMem_In)
	  	// If the processor signal is muxed between BuS_InstMem_In and HIGH-Z, it's fine


	 // Data memory Interface Assignments  --------------------------------------------------------------------

	 	//Arbitration SubModule --> Bus Arbiter
	 	// When the processor wants some Data, request to use the Data bus from the Bus Arbiter
	 	assign D_Bus_RQ = ( P_DataMem_Read | P_DataMem_Write[3] | P_DataMem_Write[2] | P_DataMem_Write[1] | P_DataMem_Write[0]);


	 	//Arbitration SubModule --> Data Bus	
		assign Bus_DataMem_Read			= 	(D_Bus_GRANT) ? P_DataMem_Read 		: 1'bz;  // When Grant is LOW, show HIGH-Z to the bus
		assign Bus_DataMem_Write		= 	(D_Bus_GRANT) ? P_DataMem_Write		: 4'bz;	 // 
		assign Bus_DataMem_Address		= 	(D_Bus_GRANT) ? P_DataMem_Address 	: 30'bz; //  When Grant is HIGH, pass on the values	
		assign Bus_DataMem_Out			= 	(D_Bus_GRANT) ? P_DataMem_Out 		: 32'bz; // 	that the processsor outputs, to the bus


	 	//Arbitration SubModule --> Processor
		assign P_DataMem_Ready 			=	(D_Bus_GRANT) ? Bus_DataMem_Ready	: 1'b0;  // When Grant is LOW, Tell the processor memory is not ready
		assign P_DataMem_In 			= 	(D_Bus_GRANT) ? Bus_DataMem_In		: 32'b0; // When Grant is LOW, show zeros to the processor
		

endmodule

