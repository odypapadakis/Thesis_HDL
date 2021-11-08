`timescale 1ns / 1ps

//`default_nettype none
			
/*
  * File			: BusArbiter.v
  * Project 		: Univeristy of Patras, Computer engineering & informatics dpt.
  *			 	 		Design of a multicore system based on the mips32 processor.
  * Creator(s)	: 	Odysseas Papadakis	
  *
  * Description	: 	This bus Arbiter  performs a Round robin arbitration tactic.
  *					Two separate Finite state machines are described. They are the same FSM, 
  *					one handles the DATA Read/Write requests and the other the instruction 
  *					Read requests
*/





 	//How many processors 
 	parameter Number_of_cores = 4;


parameter P_Count = Number_of_cores -1 ;	

	//The number of bits required to enumerate all processors			
parameter P_enum_bits = $clog2(Number_of_cores);  





module BusArbiter(
	clock, 
	reset,

	DataMem_Ready,  // The arbiter needs to probe the mem_ready signals to know when the
		   			//	transfer has been completed
	InstMem_Ready,	

	I_Bus_RQ,
	I_Bus_GRANT,

	D_Bus_RQ,
	D_Bus_GRANT,

		// The following outputs are driven to zero when the bus is idle to avoid a floating bus
	DataMem_Read,
	DataMem_Write,
	DataMem_Address,
	DataMem_Out,

	InstMem_Address,
	InstMem_Read
	);

	input		clock;
	input		reset;
	input		DataMem_Ready;
	input		InstMem_Ready;


	// DATA Bus control signals
		// Arbiter <-- Arbitration module 
			input		[P_Count:0] D_Bus_RQ;
		// Arbiter -->Arbitration module
			output 		[P_Count:0] D_Bus_GRANT;

	//Instruction Bus control signals
		// Arbiter <-- Arbitration module 
			input		[P_Count:0] I_Bus_RQ;
		// Arbiter -->Arbitration module	
			output  	[P_Count:0] I_Bus_GRANT;	


	output reg			DataMem_Read	;
	output reg 	[3:0] 	DataMem_Write	;
	output reg 	[29:0]	DataMem_Address	;
	output reg 	[31:0]	DataMem_Out		;

	output reg 	[29:0]	InstMem_Address	;
	output reg 			InstMem_Read	;





		// The  GRANT registers control which core has control of the bus. 
		// At any point in time, only 1 bit of each register  should be HIGH

	reg	[P_Count:0] D_Bus_GRANT;		
	reg [P_Count:0] I_Bus_GRANT;

	

	// Instruction FSM states are listed here

	localparam	I_state_Check_RQ 				= 0;			// Scans the BUS_RQ bit for each processor
	localparam	I_state_wait_for_mem_LOW_BEGIN 	= 1;			// This state is present to ensure that the memory is idle 
	localparam	I_state_give_bus				= 2;
	localparam	I_state_wait_for_mem_HIGH 		= 3;
	localparam	I_state_wait_for_REQ_LOW		= 4;
	localparam	I_state_wait_for_mem_LOW_END  	= 5;
	//localparam	I_state_IDLE 					= 6;  // Diagnostic

	reg [3:0]	I_state;		//The  INSTRUCTION FSM state register


	// DATA FSM states are listed here

	localparam	D_state_Check_RQ 				= 0;			// Scans the BUS_RQ bit for each processor
	localparam	D_state_wait_for_mem_LOW_BEGIN 	= 1;			// This state is present to ensure that the memory is idle 
	localparam	D_state_give_bus				= 2;
	localparam	D_state_wait_for_mem_HIGH 		= 3;
	localparam	D_state_wait_for_REQ_LOW		= 4;
	localparam	D_state_wait_for_mem_LOW_END  	= 5;
	//localparam	D_state_IDLE 					= 6;  // Diagnostic

	reg [3:0]	D_state;		//The  DATA FSM state register

		// The indexes used to traverse the  cores
	 reg [P_enum_bits-1:0] D_i;		
	 reg [P_enum_bits-1:0] I_i;

	task incrementD;
		begin
			if ( D_i < P_Count)  // for 4 cores, cores 0,1,2,3 are checked
				begin
					// $display("D_i++");
					D_i <= D_i+1	;								
				end
			else
				begin
					// $display("Reset D_i");
					D_i<= 0;	
				end	

		end
	endtask
		
	task incrementI;
		begin
			if ( I_i < P_Count)  
				begin
					// $display("Ι_i++");
					I_i <= I_i+1	;								
				end
			else
				begin
					// $display("Reset Ι_i");
					I_i<= 0;	
				end	

		end		
	endtask




//				 Data FSM always block begins
//----------------------------------------------------------------------------------------------------------------
	

	always@( posedge clock  or posedge reset  )					// asynchronous Reset
	begin
		//// $display("Data work:");
		if( reset )
			begin
				
				D_i <= {P_enum_bits{1'b0}};
				D_Bus_GRANT <= {P_Count{1'b0}};
				D_state <= D_state_Check_RQ;
				DataMem_Read	<=	1'b0;	
				DataMem_Write	<=	4'b0;
				DataMem_Address	<=	30'b0;
				DataMem_Out		<=	32'b0;
				
			end
		else
			begin
				case(D_state)									

//					D_state_IDLE:    							//(IDLE STATE diagnostic)
//								begin
//									// $display("Data IDLE and i -->%d ",D_i);
//									D_Bus_GRANT <= 0;	
//									if( D_Bus_RQ != 4'b0000 )	
//									D_state <= D_state_Check_RQ;	
//								end


					D_state_Check_RQ : // state 0
								begin
									// $display("Checking D_i-->%d ",D_i);
									if(D_Bus_RQ[D_i] == 1'b1 )			// Bus is given to a core
										begin
											DataMem_Read	<=	1'bz;	// Bus left to be driven by core
											DataMem_Write	<=	4'bz;
											DataMem_Address	<=	30'bz;
											DataMem_Out		<=	32'bz;

											// $display("Reguest from core %d ",D_i);
											D_state <= D_state_wait_for_mem_LOW_BEGIN;
										end									
									else
									 	begin
											incrementD;
										end
								end	

					D_state_wait_for_mem_LOW_BEGIN: // state 1
								begin
									// $display("Waiting for DataMem to be LOW to begin");
									if(DataMem_Ready == 1'b0)
										begin
											 $display("MEM dropped, BUS IS BUSY");
											D_state <= D_state_give_bus;
										end
								end				
					
					D_state_give_bus:	// state 2
								begin
									// $display("Bus given to %d",D_i);
									D_Bus_GRANT[D_i] <= 1;	
									D_state <= D_state_wait_for_mem_HIGH;
								end	

					D_state_wait_for_mem_HIGH:	 // state 3
								begin
									// $display("Waiting for mem HIGH");
									if(DataMem_Ready == 1'b1)
										begin
											D_state <= D_state_wait_for_REQ_LOW;
										end
								end		
	

					D_state_wait_for_REQ_LOW:	// state 4
								begin
									// $display("Waiting for REQ to drop");
									if(D_Bus_RQ[D_i] == 1'b0)
										// $display("REQ dropped");
										D_state <= D_state_wait_for_mem_LOW_END;
								end							
					D_state_wait_for_mem_LOW_END:	 // state5
								begin
									// $display("Waiting for MEM to drop again");
									if(DataMem_Ready == 1'b0)	// Bus is removed from circulation
										begin
											// $display("MEM dropped - transaction complete");
											incrementD;
											D_Bus_GRANT <= {P_Count{1'b0}};
											D_state <= D_state_Check_RQ;
											DataMem_Read	<=	1'b0;			// Bus is driven to zero to avoid floating i
											DataMem_Write	<=	4'b0;			// inputs to memory
											DataMem_Address	<=	30'b0;
											DataMem_Out		<=	32'b0;
										end
										
								end
				endcase
			end
	end
//----------------------------------------------------------------------------------------------------------------
//				 Data FSM always block ends






//				 Instruction FSM always block begins
//----------------------------------------------------------------------------------------------------------------

always@( posedge clock  or posedge reset  )					// asynchronous Reset
	begin
		//// $display("Instruction work:");
		if( reset )
			begin
				I_i <= 0;
				I_Bus_GRANT <= {P_enum_bits{1'b0}} ;
				I_state <= I_state_Check_RQ;
				InstMem_Address	<=	30'b0;
				InstMem_Read	<=	1'b0;
			end
		else
			begin
				case(I_state)									

//					I_state_IDLE:    							//(IDLE STATE)
//								begin
//									// $display("Insruction IDLE and i -->%d ",I_i);
//									I_Bus_GRANT <= 4'b0000;	
//									if( I_Bus_RQ != 4'b0000 )	
//									I_state <= I_state_Check_RQ;	
//								end


					I_state_Check_RQ : // state 0
								begin
									// $display("Checking I_i-->%d ",I_i);
									if(I_Bus_RQ[I_i] == 1'b1 )
										begin
											InstMem_Address	<=	30'bz;	
											InstMem_Read	<=	1'bz;
											// $display("Reguest from core %d ",I_i);
											I_state <= I_state_wait_for_mem_LOW_BEGIN;
										end									
									else
									 	begin
											incrementI;
										end
								end	

					I_state_wait_for_mem_LOW_BEGIN: // state 1
								begin
									// $display("Waiting for DataMem to be LOW to begin");
									if(InstMem_Ready == 1'b0)
										begin
											// $display("MEM dropped, begining bus usage");
											I_state <= I_state_give_bus;
										end
								end				
					
					I_state_give_bus:	// state 2
								begin
									// $display("Bus given to %d",I_i);
									I_Bus_GRANT[I_i] <= 1;	
									I_state <= I_state_wait_for_mem_HIGH;
								end	

					I_state_wait_for_mem_HIGH:	 // state 3
								begin
									// $display("Waiting for mem HIGH");
									if(InstMem_Ready == 1'b1)
										begin
											I_state <= I_state_wait_for_REQ_LOW;
										end
								end		
	

					I_state_wait_for_REQ_LOW:	// state 4
								begin
									// $display("Waiting for REQ to drop");
									if(I_Bus_RQ[I_i] == 1'b0)
										// $display("REQ dropped");
										I_state <= I_state_wait_for_mem_LOW_END;
								end							
					I_state_wait_for_mem_LOW_END:	 // state5
								begin
									// $display("Waiting for MEM to drop again");
									if(InstMem_Ready == 1'b0)
										begin
											// $display("MEM dropped");
											incrementI;
											I_Bus_GRANT <= 4'b0000;
											I_state <= I_state_Check_RQ;
											InstMem_Address	<=	30'b0;
											InstMem_Read	<=	1'b0;
										end
										
								end
				endcase
			end
	end
//----------------------------------------------------------------------------------------------------------------
//				 Instruction FSM always block ends



endmodule



