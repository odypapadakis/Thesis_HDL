`timescale 1ns / 1ps

// This is a testbench to test the functionality of the bus arbiter.


module BusArbiter_testbench;

// Testbench clock, reset
reg tb_clock;
reg tb_reset;


//	Arbitration Submodule --> Bus arbiter
// reg [3:0] tb_D_Bus_RQ;
reg [3:0] tb_I_Bus_RQ;

//	Bus arbiter --> Arbitration Submodule
// wire [3:0] tb_D_Bus_Grant;
wire [3:0] tb_I_Bus_Grant;




// Memory System --> Bus/Bus Arbiter
reg tb_DataMem_Ready;

// Bus Arbiter --> Bus
wire 	 	  	tb_DataMem_Read		;
wire	[3:0] 	tb_DataMem_Write 	;
wire 	[29:0]	tb_DataMem_Address	;	
wire 	[31:0]	tb_DataMem_Out		;


// Memory System --> Bus/Bus Arbiter
reg tb_InsMem_Ready;

// Bus Arbiter --> Bus 
wire 	[29:0]	tb_InstMem_Address	;
wire 			tb_InstMem_Read		;




BusArbiter uut (
	.clock		(tb_clock	),
	.reset		(tb_reset	),

	.D_Bus_RQ		(tb_D_Bus_RQ	),	
	.I_Bus_RQ		(tb_I_Bus_RQ	),

	.D_Bus_GRANT	(tb_D_Bus_Grant	),
	.I_Bus_GRANT	(tb_I_Bus_Grant	),

	.DataMem_Ready 	(tb_DataMem_Ready	),	
	.DataMem_Read	(tb_DataMem_Read	),
	.DataMem_Write	(tb_DataMem_Write 	),
	.DataMem_Address(tb_DataMem_Address	),	
	.DataMem_Out	(tb_DataMem_Out		),	



	.InstMem_Ready 	(tb_InsMem_Ready),
	.InstMem_Address(tb_InstMem_Address	),	
	.InstMem_Read	(tb_InstMem_Read		)
	
	
);





//endtask


// pseudo Memory FSM STARTS --------------------------------------------------

// pseudo Memoery needs
/*
	Inputs:
		tb_Bus_InstMem_Read				// Read signal from processor(BUS)
		tb_Bus_InstMem_Address			// The address the processor ( BUS ) wants to read from 
	Outputs:
		tb_Bus_InstMem_Ready			// Ready signal to processor ( BUS )
		tb_Bus_InstMem_In				// Data to processor	( BUS )
*/



reg [1:0] Mem_State;
localparam	Mem_State_Idle 			    = 0;
localparam	Mem_State_Request_placed 	= 1;
localparam	Mem_State_Data_ready 		= 2;
localparam	Mem_State_Data_read 		= 3;



always@(posedge tb_clock or posedge tb_reset)
begin
	if (tb_reset)
		begin
			tb_Bus_InstMem_Ready 	= 1'b0;		// Ready signal to processor ( BUS )
			tb_Bus_InstMem_In 		= 'h0000;  	// Data to processor	( BUS )
			Mem_State = Mem_State_Idle;
		end
	else
	begin
		case(Mem_State)
						
					Mem_State_Idle:
					begin
						tb_Bus_InstMem_Ready 	= 1'b0;		//
						tb_Bus_InstMem_In 		= 'hFFFF;   // Drive the data bus with FFFs while idle
						if(tb_Bus_InstMem_Read == 1'b1)
							Mem_State = Mem_State_Request_placed;

					end

					Mem_State_Request_placed:
					begin

						#100 tb_Bus_InstMem_In = tb_Bus_InstMem_Address + 1 ;  // Return the address +1 as data 
						#100 tb_Bus_InstMem_Ready 	= 1'b1;	
						Mem_State = Mem_State_Data_ready ;
					end

					Mem_State_Data_ready:
					begin
						#50 if(tb_Bus_InstMem_Read == 1'b0)
							Mem_State = Mem_State_Data_read;

					end

					Mem_State_Data_read:
					begin
						tb_Bus_InstMem_Ready 	= 1'b0;
						Mem_State =	Mem_State_Idle;
					end

		endcase

	end	

end

// pseudo Memory FSM ENDS --------------------------------------------------





always 
#10 tb_clock = !tb_clock;

initial
begin
#10 tb_clock = 0;


#10 tb_reset = 1;


#150 tb_reset = 0;


#50 	tb_I_Bus_RQ = 4'b0011;

#200 	tb_I_Bus_RQ = 4'b0011;

#200 tb_I_Bus_RQ = 4'b0001;

end

// always
// 	begin
// 			if(tb_reset)
// 				begin
// 					tb_DataMem_Ready <= 1'b0; 
// 				end
// 			else if(	(tb_D_Bus_Grant != 4'b0000)	&&	(tb_D_Bus_RQ != 4'b0000) 	)      // A request is up, and the bus has been given to a core
// 				begin
// 					#20 tb_DataMem_Ready <= 1'b1;  	
// 				end
// 			else if (	(tb_D_Bus_Grant == 4'b0000)	&&	(tb_D_Bus_RQ != 4'b0000)		)
// 				begin
// 					#5 tb_DataMem_Ready <= 1'b0;	
// 				end
// 			else if( (tb_D_Bus_Grant != 4'b0000) && (tb_D_Bus_RQ == 4'b0000)			)
// 				begin
// 					#5 tb_DataMem_Ready <= 1'b0;	
// 				end	
// 			else 	if(		(tb_D_Bus_Grant == 4'b0000) && (tb_D_Bus_RQ == 4'b0000)	)
// 				begin  
// 					#5 tb_DataMem_Ready <= 1'b0;
// 				end
// 		#1;
// 	end



//	genvar c;
//	
//	for (c = 0; c < 5 ; c = c +1)
//	begin
//		always	
//			begin
//	
//				/*
//				//#($urandom_range(10,20)) tb_D_Bus_RQ[a] <= 1'b1;  // I'm a core, lalala, i want D_R/W
//				#100 tb_D_Bus_RQ[3] <= 1'b1;
//	
//				while( tb_D_Bus_Grant[3] == 1'b0 )
//	
//				//#($urandom_range(10,20)) tb_D_Bus_RQ[a] <= 1'b0;
//	
//				#100 tb_D_Bus_RQ[3] <= 1'b0;
//				*/
//				if( tb_D_Bus_RQ[c] == 1'b1 )
//					begin
//						$display("I wanna D R/W");
//						
//						while(tb_D_Bus_Grant[c] == 1'b0 )
//							begin
//								#10;
//							end
//	
//						$display("Bus is mine");
//	
//						while(tb_DataMem_Ready == 1'b0)
//							begin
//								#10;
//							end
//						
//						$display("My data is ready!");
//	
//						#150 tb_D_Bus_RQ[c] <= 1'b0;		// 3 has copied data
//						$display("Transaction completed");	
//	
//					end
//					#1;
//			end
//	end



// always	
// 		begin

// 			/*
// 			//#($urandom_range(10,20)) tb_D_Bus_RQ[a] <= 1'b1;  // I'm a core, lalala, i want D_R/W
// 			#100 tb_D_Bus_RQ[3] <= 1'b1;

// 			while( tb_D_Bus_Grant[3] == 1'b0 )

// 			//#($urandom_range(10,20)) tb_D_Bus_RQ[a] <= 1'b0;

// 			#100 tb_D_Bus_RQ[3] <= 1'b0;
// 			*/
// 			if( tb_D_Bus_RQ[0] == 1'b1 )
// 				begin
// 					//$display("I wanna D R/W");
					
// 					while(tb_D_Bus_Grant[0] == 1'b0 )
// 						begin
// 							#10;
// 						end



// 						/// This is where the core puts the address memory etc on the bus
// 					//$display("Bus is mine");

// 					while(tb_DataMem_Ready == 1'b0)
// 						begin
// 							#10;
// 						end
					
// 					//$display("My data is ready!");

// 					#150 tb_D_Bus_RQ[0] <= 1'b0;		// 3 has copied data
// 					//$display("Transaction completed");	
// 				#1;		
// 				end
// 				#1;
// 		end

// always	
// 		begin

			
// 			//#($urandom_range(10,20)) tb_D_Bus_RQ[a] <= 1'b1;  // I'm a core, lalala, i want D_R/W
// 			#100 tb_D_Bus_RQ[3] <= 1'b1;

// 			while( tb_D_Bus_Grant[3] == 1'b0 )

// 			//#($urandom_range(10,20)) tb_D_Bus_RQ[a] <= 1'b0;

// 			#100 tb_D_Bus_RQ[3] <= 1'b0;
			
// 			if( tb_D_Bus_RQ[1] == 1'b1 )
// 				begin
// 					//$display("I wanna D R/W");
					
// 					while(tb_D_Bus_Grant[1] == 1'b0 )
// 						begin
// 							#1;
// 						end

// 					//$display("Bus is mine");

// 					while(tb_DataMem_Ready == 1'b0)
// 						begin
// 							#1;
// 						end
					
// 					//$display("My data is ready!");

// 					#15 tb_D_Bus_RQ[1] <= 1'b0;		// 3 has copied data
// 					//$display("Transaction completed");	
// 				#1;		
// 				end
// 				#1;
// 		end







// // The first core is assumed to be core number 1

// initial
// 	begin
	
 
// 		#10	tb_DataMem_Ready <= 0;
// 		#10	tb_InsMem_Ready <= 0;
// 		#10	tb_clock <= 0;
// 		#10	tb_D_Bus_RQ <= 4'b0000;  // 
// 		#10	tb_I_Bus_RQ <= 4'b0000;  // 
// 		#10	tb_reset <= 1;





	
// 		$display(" --------  Test begins  ------------------");
// 		#100 tb_reset <= 0;  

// 		#500;
// 		#100 tb_D_Bus_RQ <= 4'b0001;

// 		#200 tb_D_Bus_RQ <= 4'b0010;
// 		#1500;
// 		$display(" --------  Test ENDS  ------------------");
// 		$finish;
		/*
		//#500 tb_DataMem_Ready <= 1'b1;


		//#200 tb_D_Bus_RQ <= 4'b0000;

		//#300 tb_DataMem_Ready <= 1'b0;

		//#50 tb_DataMem_Ready <= 1'b1;


		//RQ(1);
		//#200 tb_DataMem_Ready <= 1'b1;


		//	#100 tb_D_Bus_RQ <= 4'b0001;	// A request from core 0 is placed
		//	#100 tb_D_Bus_RQ = 4'b0010;	// A request from core 1 is placed	
		//	#100 tb_D_Bus_RQ = 4'b0100;	// A request from core 2is placed
		//	#100 tb_D_Bus_RQ = 4'b1000;	// A request from core 3 is placed




		#1000 tb_D_Bus_RQ <= 4'b0010;	// A request from core 1 is placed
		#100 tb_DataMem_Ready <= 1'b1;	// Data is ready on the Data BUS
		#100 tb_D_Bus_RQ <= 4'b0000;		//Core Has taken the Data
		#100 tb_DataMem_Ready <= 1'b0;	// Transaction Complete0


		#100 tb_D_Bus_RQ <= 4'b0001;	// A request from core 0 is place0
		#100 tb_D_Bus_RQ <= 4'b0011;	// A request from core 1 is placed //--0
		#100 tb_DataMem_Ready <= 1'b1;	// Data is ready on the Data BUS
		#100 tb_D_Bus_RQ <= 4'b0010;		//Core0 Has taken the Data		//---
		#100 tb_DataMem_Ready <= 1'b0;	// Transaction Complete0
		#200 tb_DataMem_Ready <= 1'b1;	// Data is ready on the Data BUS
		#100 tb_D_Bus_RQ <= 4'b0000;		//Core Has taken the Data
		#100 tb_DataMem_Ready <= 1'b0;	// Transaction Completed

		//	#15 Mem_Ready = 1;
		//	#30 Mem_Ready = 0;
		//	#15 RQ = 2'd2;
		//	#15 RQ = 2'd2;


		*/

	// end

endmodule