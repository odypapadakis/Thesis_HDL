`timescale 1ns / 1ps

//`default_nettype none asdf
			
/*
  * File			: BusArbiter.v
  * Project				: Univeristy of Patras, Computer engineering & informatics dpt.
  *								Design of a multicore system based on the mips32 processor.
  * Creator(s)	: 	Odysseas Papadakis	
  *
  * Description	:	This is a Bus arbiter.
  *								This Arbiter handles the arbitration of a Memory Bus and an Instruction bus.
  *								Two identical Moore FSMs work to perform the arbitration, one for each bus.
  *								The algorithm that is implemented, is round-robin with rotating priority.
  *								Some explanation:
  *													 	- On each clock cycle, all processors are checked for bus usage requests ( sequentially ).
  *														- What changes ( rotates ) is the order with which the processors are checked 
  *														for requests.
  *														- After each cycle, the order rotates, in order to ensure that all processors will have the chance to be number 1 
  *															
  *														
*/


module BusArbiter(
	clock, 
	reset,

	DataMem_Ready,
	InstMem_Ready,

	I_Bus_RQ,
	I_Bus_GRANT,

	D_Bus_RQ,
	D_Bus_GRANT,

	DataMem_Read,
	DataMem_Write,
	DataMem_Address,
	DataMem_Out,

	InstMem_Address,
	InstMem_Read
	);

	input		clock;
	input		reset;
	input		DataMem_Ready;		// This signal is monitored to ensure memory hanshake happens correctly
	input		InstMem_Ready;		// This signal is monitored to ensure memory hanshake happens correctly


	// DATA Bus control signals
		// Arbiter <-- Arbitration module 
			input		[3:0] D_Bus_RQ;
		// Arbiter -->Arbitration module
			output reg		[3:0] D_Bus_GRANT;

	//Instruction Bus control signals
		// Arbiter <-- Arbitration module 
			input		[3:0] I_Bus_RQ;
		// Arbiter -->Arbitration module	
			output reg  	[3:0] I_Bus_GRANT;	


	// Data Bus outputs ( Will be driven to zero when idle, to HIGH-Z When Bus is in use)
	output reg			DataMem_Read	;
	output reg 	[3:0] 	DataMem_Write	;
	output reg 	[29:0]	DataMem_Address	;
	output reg 	[31:0]	DataMem_Out		;

	// Instruction Bus outputs ( Will be driven to zero when idle, to HIGH-Z When Bus is in use)
	output reg 	[29:0]	InstMem_Address	;
	output reg 			InstMem_Read	;





// Instruction BUS arbiter REGISTERS -----------------------------------
integer I_i; // This is a parameter used to expand replicated logic

// Memory with 4 address of 2 bit wide words  each

reg [1:0] I_P_register [3:0]; // This holds a queue of processors

reg [1:0] I_P_Active; // This registers stores which processor is active


reg [3:0]	I_state;		//The  INSTRUCTION FSM state register

reg I_RQ;  // This register shows if a request is to be served




// Data BUS arbiter REGISTERS -----------------------------------

integer D_i; // This is a parameter used to expand replicated logic

// Memory with 4 address of 2 bit wide words  each
reg [1:0] D_P_register [3:0]; // This holds a queue of processors

reg [1:0] D_P_Active; // This registers stores which processor is active


reg [3:0]	D_state;		//The  INSTRUCTION FSM state register

reg D_RQ;  // This register shows if a request is to be served



// The Instruction FSM states 

localparam	I_state_IDLE 									= 0;
localparam	I_state_give_bus							= 1;
localparam	I_state_wait_for_mem_HIGH			= 2;
localparam	I_state_wait_for_REQ_LOW			= 3;
localparam	I_state_wait_for_mem_LOW_END	= 4;

// The Data FSM states 
localparam	D_state_IDLE									= 0;
localparam	D_state_give_bus							= 1;
localparam	D_state_wait_for_mem_HIGH			= 2;
localparam	D_state_wait_for_REQ_LOW			= 3;
localparam	D_state_wait_for_mem_LOW_END	= 4;




// 	Instruction Pointer register  always block  BEGINS--------------------------------------------------
//	This mechanism cyclically shifts the processor id's for a rotating priority checking mechanism 

always@(posedge clock or negedge reset)
	 begin
	 	if(reset)
	 		begin
		 		for (I_i = 0 ; I_i <= 3 ; I_i = I_i+1 ) 	// on reset set core 0 at the highest priority point
			 		begin
			 			I_P_register[I_i] <= I_i;			
			 		end
			 	// I_P_register[0] = 'd0;	
		 		// I_P_register[1] = 'd1;
		 		// I_P_register[2] = 'd2;
		 		// I_P_register[3] = 'd3;
		 	end
	 	else
		 	begin
		 		if(I_RQ == 1'd0)  // Keep cycling while there is no request being serviced
			 		begin
			 			for (I_i = 0; I_i < 3; I_i = I_i+1)		
				 		begin
				 			I_P_register[I_i] <= I_P_register[I_i+1];
				 		end	
			 		I_P_register[3] <= I_P_register[0];
			 		// I_P_register[0] <= I_P_register[1];	
			 		// I_P_register[1] <= I_P_register[2];
			 		// I_P_register[2] <= I_P_register[3];
			 		// I_P_register[3] <= I_P_register[0];
			 		end
		 		

		 	end


	 end
// 	Instruction Pointer register  always block ENDS  -----------------------------------------------------




// 	Data Pointer register  always block  BEGINS  ----------------------------------------------------------
//	This mechanism cyclically shifts the processor id's for a rotating priority checking mechanism 

always@(posedge clock or negedge reset)
	 begin
	 	if(reset)
	 		begin
		 		for (D_i = 0 ; D_i <= 3 ; D_i = D_i+1 ) 	// on reset set core 0 at the highest priority point
			 		begin
			 			D_P_register[D_i] <= D_i;			
			 		end
			 	// D_P_register[0] = 'd0;	
		 		// D_P_register[1] = 'd1;
		 		// D_P_register[2] = 'd2;
		 		// D_P_register[3] = 'd3;
		 	end
	 	else
		 	begin
		 		if(D_RQ == 1'd0)  // Keep cycling while there is no request being serviced
			 		begin
			 			for (D_i = 0; D_i < 3; D_i = D_i+1)		
					 		begin
					 			D_P_register[D_i] <= D_P_register[D_i+1];
					 		end	
				 		D_P_register[3] <= D_P_register[0];
				 		// D_P_register[0] <= D_P_register[1];	
				 		// D_P_register[1] <= D_P_register[2];
				 		// D_P_register[2] <= D_P_register[3];
				 		// D_P_register[3] <= D_P_register[0];
			 		end
		 		

		 	end


	 end

// 	Data Pointer register  always block  ENDS ---------------------------------------------------------------















// Instruction Arbiter main  always block  BEGINS  --------------------------------------------------------

// The first position (position 0) is considered to be the highest priority position.

// Once a request from a core has been detected, the Active core register is given the value of the processor
// to be serviced.
// The flag I_RQ is driven HIGH to indicate that the servicing process has started


always@(posedge clock or posedge reset)
	begin

		if(reset)
		 	begin

		 		I_P_Active <=2'b00;
		 		I_state <= I_state_IDLE;
				I_RQ <= 1'b0;		 		
		 	end
		else
		 	begin
		 		if(	I_RQ == 1'b0	)  
			 		begin
				 			 if ( I_Bus_RQ[ I_P_register[0] ]  	== 1'b1 )   // First check the processor at position 0 
				 			 begin
				 			 	// I_Bus_GRANT[ I_P_register[0] ] 	<= 1'b1;
				 			 	I_P_Active <= I_P_register[0];
				 			 	I_RQ <= 1'b1;
				 			 end
				 		else if ( I_Bus_RQ[ I_P_register[1] ]  	== 1'b1 )	// Then check the processor at position 1
				 			 begin
				 			 	// I_Bus_GRANT[ I_P_register[1] ] 	<= 1'b1;
				 			 	I_P_Active <= I_P_register[1];
				 			 	I_RQ <= 1'b1;
				 			 end

				 		else if ( I_Bus_RQ[ I_P_register[2] ]  	== 1'b1 )	// Then check the processor at position 2
				 			 begin
				 			 	// I_Bus_GRANT[ I_P_register[2] ] 	<= 1'b1;
				 			 	I_P_Active <= I_P_register[2];
				 			 	I_RQ <= 1'b1;
				 			 end

				 		else if ( I_Bus_RQ[ I_P_register[3] ]  	== 1'b1 ) 	// etc etc etc
				 			 begin
				 			 	// I_Bus_GRANT[ I_P_register[3] ] 	<= 1'b1;
				 			 	I_P_Active <= I_P_register[3];
				 			 	I_RQ <= 1'b1;
				 			 end	
				 	end	
			end
	end



// Instruction Arbiter main  always block  ENDS  ------------------------------------------------------




// Data Arbiter main  always block  BEGINS  --------------------------------------------------------------

// The first position (position 0) is considered to be the highest priority position.

// Once a request from a core has been detected, the Active core register is given the value of the processor
// to be serviced.
// The flag D_RQ is driven HIGH to indicate that the servicing process has started


always@(posedge clock or posedge reset)
	begin

		if(reset)

		 	begin

		 		D_P_Active <=2'b00;
		 		D_state <= D_state_IDLE;
				D_RQ <= 1'b0;		 		
		 	end

		else

		 	begin
		 		if(	D_RQ == 1'b0	)  
			 		begin
				 			 if ( D_Bus_RQ[ D_P_register[0] ]  	== 1'b1 )   // First check the processor at position 0 
				 			 $display("Checking for requests in position 0")
				 			 $display("Which contains processor %d",)
				 			 begin
				 			 	// D_Bus_GRANT[ D_P_register[0] ] 	<= 1'b1;
				 			 	D_P_Active <= D_P_register[0];
				 			 	D_RQ <= 1'b1;
				 			 end
				 		else if ( D_Bus_RQ[ D_P_register[1] ]  	== 1'b1 )	// Then check the processor at position 1
				 			 begin
				 			 	// D_Bus_GRANT[ D_P_register[1] ] 	<= 1'b1;
				 			 	D_P_Active <= D_P_register[1];
				 			 	D_RQ <= 1'b1;
				 			 end

				 		else if ( D_Bus_RQ[ D_P_register[2] ]  	== 1'b1 )	// Then check the processor at position 2
				 			 begin
				 			 	// D_Bus_GRANT[ D_P_register[2] ] 	<= 1'b1;
				 			 	D_P_Active <= D_P_register[2];
				 			 	D_RQ <= 1'b1;
				 			 end

				 		else if ( D_Bus_RQ[ D_P_register[3] ]  	== 1'b1 ) 	// etc etc etc
				 			 begin
				 			 	// D_Bus_GRANT[ D_P_register[3] ] 	<= 1'b1;
				 			 	D_P_Active <= D_P_register[3];
				 			 	D_RQ <= 1'b1;
				 			 end	
				 	end	
			end
	end



// Data Arbiter main  always block  ENDS  ------------------------------------------------------------------------------











		 
//		Instruction FSM for memory handshake always block begins     -------------------------------------------------

always@( posedge clock or posedge reset  )					// asynchronous Reset
	begin
		//// $display("Instruction work:");					// The fsm goes beyond the idle state from input from the main always block
		if( reset )
			begin

		 		I_Bus_GRANT <= 4'b0000;				
				InstMem_Address	<=	30'b0;
				InstMem_Read	<=	1'b0;
				I_state <= I_state_IDLE;

			end
		else
			begin
				case(I_state)									


					I_state_IDLE:    							//(IDLE STATE)
								begin
									I_Bus_GRANT <= 4'b0000;
									InstMem_Address	<=	30'b0;			// Drive the Bus low
									InstMem_Read	<=	1'b0;			// Drive the Bus low
									if(I_RQ == 1'b1)								// This means that a request has gone up
										I_state <= I_state_give_bus;	// And that the processor that  will use 
																					// the bus has been decided
								end


					// I_state_wait_for_mem_LOW_BEGIN: // state 1  XXX not used
					// 			begin
									
					// 				if(InstMem_Ready == 1'b0)
					// 					begin
											
					// 						I_state <= I_state_give_bus;
					// 					end			
					// 			end


					I_state_give_bus:	
								begin
									InstMem_Address	<=	30'bz;			//Stop driving the bus
									InstMem_Read	<=	1'bz;			//Stop driving the bus										
									I_Bus_GRANT [I_P_Active] <= 1'b1;		// Let the processor drive the bus							
									I_state <= I_state_wait_for_mem_HIGH;
								end	

					I_state_wait_for_mem_HIGH:	 // state 3						// Go through the step in the handshake
								begin
									
									if(InstMem_Ready == 1'b1)
										begin
											I_state <= I_state_wait_for_REQ_LOW;
										end
								end	

					I_state_wait_for_REQ_LOW:	// state 4
								begin
									
									if(I_Bus_RQ[I_P_Active] == 1'b0)
										
										I_state <= I_state_wait_for_mem_LOW_END;
								end

					I_state_wait_for_mem_LOW_END:	 // state5
								begin
									
									if( InstMem_Ready == 1'b0 )
										begin
											I_state <= I_state_IDLE;
											I_RQ <= 1'b0;
										end
										
								end
				endcase	
			end				
	end

//		Instruction FSM for memory handshake always block ENDS     ------------------------------------------------------


//		Data FSM for memory handshake always block begins     -------------------------------------------------------------

always@( posedge clock or posedge reset  )					// asynchronous Reset
	begin
		//// $display("Instruction work:");					// The fsm goes beyond the idle state from input from the main always block
		if( reset )
			begin

		 		D_Bus_GRANT <= 4'b0000;				
				InstMem_Address	<=	30'b0;
				InstMem_Read	<=	1'b0;
				D_state <= D_state_IDLE;

			end
		else
			begin
				
				case(D_state)									


					D_state_IDLE:    							//(IDLE STATE)
								begin
									D_Bus_GRANT <= 4'b0000;
									InstMem_Address	<=	30'b0;			// Drive the Bus low
									InstMem_Read	<=	1'b0;			// Drive the Bus low
									if(D_RQ == 1'b1)								// This means that a request has gone up
										D_state <= D_state_give_bus;	// And that the processor that  will use 
																					// the bus has been decided
								end


					// D_state_wait_for_mem_LOW_BEGIN: // state 1  XXX not used
					// 			begin
									
					// 				if(InstMem_Ready == 1'b0)
					// 					begin
											
					// 						D_state <= D_state_give_bus;
					// 					end			
					// 			end


					D_state_give_bus:	
								begin
									InstMem_Address	<=	30'bz;			//Stop driving the bus
									InstMem_Read	<=	1'bz;			//Stop driving the bus										
									D_Bus_GRANT [D_P_Active] <= 1'b1;		// Let the processor drive the bus							
									D_state <= D_state_wait_for_mem_HIGH;
								end	

					D_state_wait_for_mem_HIGH:	 // state 3						// Go through the step in the handshake
								begin
									
									if(InstMem_Ready == 1'b1)
										begin
											D_state <= D_state_wait_for_REQ_LOW;
										end
								end	

					D_state_wait_for_REQ_LOW:	// state 4
								begin
									
									if(D_Bus_RQ[D_P_Active] == 1'b0)
										
										D_state <= D_state_wait_for_mem_LOW_END;
								end

					D_state_wait_for_mem_LOW_END:	 // state5
								begin
									
									if( InstMem_Ready == 1'b0 )
										begin
											D_state <= D_state_IDLE;
											D_RQ <= 1'b0;
										end
										
								end
				endcase	
			end				
	end

//		Data FSM for memory handshake always block ENDS     ------------------------------------------------------------------




















endmodule

	// // Rotate register increase
	// always@(posedge clock)
	// begin

	// end


	// The Round robin arbiter logic
	// always@(posdege clock)
	// begin
	// 	if (I_P_register[0])
	// end



	// 	// The  GRANT registers control which core has control of the bus. 
	// 	// At any point in time, only 1 bit of each register  should be HIGH

	// reg	[P_Count:0] D_Bus_GRANT;		
	// reg [P_Count:0] I_Bus_GRANT;

	

	// // Instruction FSM states are listed here

	// localparam	I_state_Check_RQ 				= 0;			// Scans the BUS_RQ bit for each processor
	// localparam	I_state_wait_for_mem_LOW_BEGIN 	= 1;			// This state is present to ensure that the memory is idle 
	// localparam	I_state_give_bus				= 2;
	// localparam	I_state_wait_for_mem_HIGH 		= 3;
	// localparam	I_state_wait_for_REQ_LOW		= 4;
	// localparam	I_state_wait_for_mem_LOW_END  	= 5;
	// //localparam	I_state_IDLE 					= 6;  // Diagnostic

	// reg [3:0]	I_state;		//The  INSTRUCTION FSM state register


	// // DATA FSM states are listed here

	// localparam	D_state_Check_RQ 				= 0;			// Scans the BUS_RQ bit for each processor
	// localparam	D_state_wait_for_mem_LOW_BEGIN 	= 1;			// This state is present to ensure that the memory is idle 
	// localparam	D_state_give_bus				= 2;
	// localparam	D_state_wait_for_mem_HIGH 		= 3;
	// localparam	D_state_wait_for_REQ_LOW		= 4;
	// localparam	D_state_wait_for_mem_LOW_END  	= 5;
	// //localparam	D_state_IDLE 					= 6;  // Diagnostic

	// reg [3:0]	D_state;		//The  DATA FSM state register

	// 	// The indexes used to traverse the  cores
	//  reg [P_enum_bits-1:0] D_i;		
	//  reg [P_enum_bits-1:0] I_i;

	// task incrementD;
	// 	begin
	// 		if ( D_i < P_Count)  // for 4 cores, cores 0,1,2,3 are checked
	// 			begin
	// 				// $display("D_i++");
	// 				D_i <= D_i+1	;								
	// 			end
	// 		else
	// 			begin
	// 				// $display("Reset D_i");
	// 				D_i<= 0;	
	// 			end	

	// 	end
	// endtask
		
	// task incrementI;
	// 	begin
	// 		if ( I_i < P_Count)  
	// 			begin
	// 				// $display("Ι_i++");
	// 				I_i <= I_i+1	;								
	// 			end
	// 		else
	// 			begin
	// 				// $display("Reset Ι_i");
	// 				I_i<= 0;	
	// 			end	

	// 	end		
	// endtask




// //				 Data FSM always block begins
// //----------------------------------------------------------------------------------------------------------------
	

// 	always@( posedge clock  or posedge reset  )					// asynchronous Reset
// 	begin
// 		//// $display("Data work:");
// 		if( reset )
// 			begin
				
// 				D_i <= {P_enum_bits{1'b0}};
// 				D_Bus_GRANT <= {P_Count{1'b0}};
// 				D_state <= D_state_Check_RQ;
// 				DataMem_Read	<=	1'b0;	
// 				DataMem_Write	<=	4'b0;
// 				DataMem_Address	<=	30'b0;
// 				DataMem_Out		<=	32'b0;
				
// 			end
// 		else
// 			begin
// 				case(D_state)									

// //					D_state_IDLE:    							//(IDLE STATE diagnostic)
// //								begin
// //									// $display("Data IDLE and i -->%d ",D_i);
// //									D_Bus_GRANT <= 0;	
// //									if( D_Bus_RQ != 4'b0000 )	
// //									D_state <= D_state_Check_RQ;	
// //								end


// 					D_state_Check_RQ : // state 0
// 								begin
// 									// $display("Checking D_i-->%d ",D_i);
// 									if(D_Bus_RQ[D_i] == 1'b1 )			// Bus is given to a core
// 										begin
// 											DataMem_Read	<=	1'bz;	// Bus left to be driven by core
// 											DataMem_Write	<=	4'bz;
// 											DataMem_Address	<=	30'bz;
// 											DataMem_Out		<=	32'bz;

// 											// $display("Reguest from core %d ",D_i);
// 											D_state <= D_state_wait_for_mem_LOW_BEGIN;
// 										end									
// 									else
// 									 	begin
// 											incrementD;
// 										end
// 								end	

// 					D_state_wait_for_mem_LOW_BEGIN: // state 1
// 								begin
// 									// $display("Waiting for DataMem to be LOW to begin");
// 									if(DataMem_Ready == 1'b0)
// 										begin
// 											 $display("MEM dropped, BUS IS BUSY");
// 											D_state <= D_state_give_bus;
// 										end
// 								end				
					
// 					D_state_give_bus:	// state 2
// 								begin
// 									// $display("Bus given to %d",D_i);
// 									D_Bus_GRANT[D_i] <= 1;	
// 									D_state <= D_state_wait_for_mem_HIGH;
// 								end	

// 					D_state_wait_for_mem_HIGH:	 // state 3
// 								begin
// 									// $display("Waiting for mem HIGH");
// 									if(DataMem_Ready == 1'b1)
// 										begin
// 											D_state <= D_state_wait_for_REQ_LOW;
// 										end
// 								end		
	

// 					D_state_wait_for_REQ_LOW:	// state 4
// 								begin
// 									// $display("Waiting for REQ to drop");
// 									if(D_Bus_RQ[D_i] == 1'b0)
// 										// $display("REQ dropped");
// 										D_state <= D_state_wait_for_mem_LOW_END;
// 								end							
// 					D_state_wait_for_mem_LOW_END:	 // state5
// 								begin
// 									// $display("Waiting for MEM to drop again");
// 									if(DataMem_Ready == 1'b0)	// Bus is removed from circulation
// 										begin
// 											// $display("MEM dropped - transaction complete");
// 											incrementD;
// 											D_Bus_GRANT <= {P_Count{1'b0}};
// 											D_state <= D_state_Check_RQ;
// 											DataMem_Read	<=	1'b0;			// Bus is driven to zero to avoid floating i
// 											DataMem_Write	<=	4'b0;			// inputs to memory
// 											DataMem_Address	<=	30'b0;
// 											DataMem_Out		<=	32'b0;
// 										end
										
// 								end
// 				endcase
// 			end
// 	end
// //----------------------------------------------------------------------------------------------------------------
// //				 Data FSM always block ends






//				OLD OLD OLD  Instruction FSM always block begins
//----------------------------------------------------------------------------------------------------------------

// always@( posedge clock  or posedge reset  )					// asynchronous Reset
// 	begin
// 		//// $display("Instruction work:");
// 		if( reset )
// 			begin
// 				I_i <= 0;
// 				I_Bus_GRANT <= {P_enum_bits{1'b0}} ;
// 				I_state <= I_state_Check_RQ;
// 				InstMem_Address	<=	30'b0;
// 				InstMem_Read	<=	1'b0;
// 			end
// 		else
// 			begin
// 				case(I_state)									

// //					I_state_IDLE:    							//(IDLE STATE)
// //								begin
// //									// $display("Insruction IDLE and i -->%d ",I_i);
// //									I_Bus_GRANT <= 4'b0000;	
// //									if( I_Bus_RQ != 4'b0000 )	
// //									I_state <= I_state_Check_RQ;	
// //								end


// 					I_state_Check_RQ : // state 0
// 								begin
// 									// $display("Checking I_i-->%d ",I_i);
// 									if(I_Bus_RQ[I_i] == 1'b1 )
// 										begin
// 											InstMem_Address	<=	30'bz;	
// 											InstMem_Read	<=	1'bz;
// 											// $display("Reguest from core %d ",I_i);
// 											I_state <= I_state_wait_for_mem_LOW_BEGIN;
// 										end									
// 									else
// 									 	begin
// 											incrementI;
// 										end
// 								end	

// 					I_state_wait_for_mem_LOW_BEGIN: // state 1
// 								begin
// 									// $display("Waiting for DataMem to be LOW to begin");
// 									if(InstMem_Ready == 1'b0)
// 										begin
// 											// $display("MEM dropped, begining bus usage");
// 											I_state <= I_state_give_bus;
// 										end
// 								end				
					
// 					I_state_give_bus:	// state 2
// 								begin
// 									// $display("Bus given to %d",I_i);
// 									I_Bus_GRANT[I_i] <= 1;	
// 									I_state <= I_state_wait_for_mem_HIGH;
// 								end	

// 					I_state_wait_for_mem_HIGH:	 // state 3
// 								begin
// 									// $display("Waiting for mem HIGH");
// 									if(InstMem_Ready == 1'b1)
// 										begin
// 											I_state <= I_state_wait_for_REQ_LOW;
// 										end
// 								end		
	

// 					I_state_wait_for_REQ_LOW:	// state 4
// 								begin
// 									// $display("Waiting for REQ to drop");
// 									if(I_Bus_RQ[I_i] == 1'b0)
// 										// $display("REQ dropped");
// 										I_state <= I_state_wait_for_mem_LOW_END;
// 								end							
// 					I_state_wait_for_mem_LOW_END:	 // state5
// 								begin
// 									// $display("Waiting for MEM to drop again");
// 									if(InstMem_Ready == 1'b0)
// 										begin
// 											// $display("MEM dropped");
// 											incrementI;
// 											I_Bus_GRANT <= 4'b0000;
// 											I_state <= I_state_Check_RQ;
// 											InstMem_Address	<=	30'b0;
// 											InstMem_Read	<=	1'b0;
// 										end
										
// 								end
// 				endcase
// 			end
// 	end
// //----------------------------------------------------------------------------------------------------------------
// //				 Instruction FSM always block ends


