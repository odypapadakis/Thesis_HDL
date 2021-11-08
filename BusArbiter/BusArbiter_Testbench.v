`timescale 1ns / 1ps

// This is a testbench to test the functionality of the bus arbiter.


module BusArbiter_testbench;

// Testbench clock, reset
reg T_clock;
reg T_reset;


//	Arbitration Submodule --> Bus arbiter
reg [3:0] T_D_Bus_RQ;
reg [3:0] T_I_Bus_RQ;

//	Bus arbiter --> Arbitration Submodule
wire [3:0] T_D_Bus_Grant;
wire [3:0] T_I_Bus_Grant;


// Memory System --> Bus/Bus Arbiter
reg T_DataMem_Ready;

// Bus Arbiter --> Bus
wire 	 	  	T_DataMem_Read		;
wire	[3:0] 	T_DataMem_Write 	;
wire 	[29:0]	T_DataMem_Address	;	
wire 	[31:0]	T_DataMem_Out		;


// Memory System --> Bus/Bus Arbiter
reg T_InsMem_Ready;

// Bus Arbiter --> Bus
wire 	[29:0]	T_InstMem_Address	;
wire 			T_InstMem_Read		;

BusArbiter uut (
	.clock		(T_clock	),
	.reset		(T_reset	),

	.D_Bus_RQ		(T_D_Bus_RQ	),	
	.I_Bus_RQ		(T_I_Bus_RQ	),

	.D_Bus_GRANT	(T_D_Bus_Grant	),
	.I_Bus_GRANT	(T_I_Bus_Grant	),

	.DataMem_Ready 	(T_DataMem_Ready	),	
	.DataMem_Read	(T_DataMem_Read		),
	.DataMem_Write	(T_DataMem_Write 	),
	.DataMem_Address(T_DataMem_Address	),	
	.DataMem_Out	(T_DataMem_Out		),	



	.InstMem_Ready 	(T_InsMem_Ready),
	.InstMem_Address(T_InstMem_Address	),	
	.InstMem_Read	(T_InstMem_Read		)
	
	
);





//endtask



always 
#10 T_clock = !T_clock;



always
	begin
			if(T_reset)
				begin
					T_DataMem_Ready <= 1'b0; 
				end
			else if(	(T_D_Bus_Grant != 4'b0000)	&&	(T_D_Bus_RQ != 4'b0000) 	)      // A request is up, and the bus has been given to a core
				begin
					#20 T_DataMem_Ready <= 1'b1;  	
				end
			else if (	(T_D_Bus_Grant == 4'b0000)	&&	(T_D_Bus_RQ != 4'b0000)		)
				begin
					#5 T_DataMem_Ready <= 1'b0;	
				end
			else if( (T_D_Bus_Grant != 4'b0000) && (T_D_Bus_RQ == 4'b0000)			)
				begin
					#5 T_DataMem_Ready <= 1'b0;	
				end	
			else 	if(		(T_D_Bus_Grant == 4'b0000) && (T_D_Bus_RQ == 4'b0000)	)
				begin  
					#5 T_DataMem_Ready <= 1'b0;
				end
		#1;
	end



//	genvar c;
//	
//	for (c = 0; c < 5 ; c = c +1)
//	begin
//		always	
//			begin
//	
//				/*
//				//#($urandom_range(10,20)) T_D_Bus_RQ[a] <= 1'b1;  // I'm a core, lalala, i want D_R/W
//				#100 T_D_Bus_RQ[3] <= 1'b1;
//	
//				while( T_D_Bus_Grant[3] == 1'b0 )
//	
//				//#($urandom_range(10,20)) T_D_Bus_RQ[a] <= 1'b0;
//	
//				#100 T_D_Bus_RQ[3] <= 1'b0;
//				*/
//				if( T_D_Bus_RQ[c] == 1'b1 )
//					begin
//						$display("I wanna D R/W");
//						
//						while(T_D_Bus_Grant[c] == 1'b0 )
//							begin
//								#10;
//							end
//	
//						$display("Bus is mine");
//	
//						while(T_DataMem_Ready == 1'b0)
//							begin
//								#10;
//							end
//						
//						$display("My data is ready!");
//	
//						#150 T_D_Bus_RQ[c] <= 1'b0;		// 3 has copied data
//						$display("Transaction completed");	
//	
//					end
//					#1;
//			end
//	end



always	
		begin

			/*
			//#($urandom_range(10,20)) T_D_Bus_RQ[a] <= 1'b1;  // I'm a core, lalala, i want D_R/W
			#100 T_D_Bus_RQ[3] <= 1'b1;

			while( T_D_Bus_Grant[3] == 1'b0 )

			//#($urandom_range(10,20)) T_D_Bus_RQ[a] <= 1'b0;

			#100 T_D_Bus_RQ[3] <= 1'b0;
			*/
			if( T_D_Bus_RQ[0] == 1'b1 )
				begin
					//$display("I wanna D R/W");
					
					while(T_D_Bus_Grant[0] == 1'b0 )
						begin
							#10;
						end



						/// This is where the core puts the address memory etc on the bus
					//$display("Bus is mine");

					while(T_DataMem_Ready == 1'b0)
						begin
							#10;
						end
					
					//$display("My data is ready!");

					#150 T_D_Bus_RQ[0] <= 1'b0;		// 3 has copied data
					//$display("Transaction completed");	
				#1;		
				end
				#1;
		end

always	
		begin

			/*
			//#($urandom_range(10,20)) T_D_Bus_RQ[a] <= 1'b1;  // I'm a core, lalala, i want D_R/W
			#100 T_D_Bus_RQ[3] <= 1'b1;

			while( T_D_Bus_Grant[3] == 1'b0 )

			//#($urandom_range(10,20)) T_D_Bus_RQ[a] <= 1'b0;

			#100 T_D_Bus_RQ[3] <= 1'b0;
			*/
			if( T_D_Bus_RQ[1] == 1'b1 )
				begin
					//$display("I wanna D R/W");
					
					while(T_D_Bus_Grant[1] == 1'b0 )
						begin
							#1;
						end

					//$display("Bus is mine");

					while(T_DataMem_Ready == 1'b0)
						begin
							#1;
						end
					
					//$display("My data is ready!");

					#15 T_D_Bus_RQ[1] <= 1'b0;		// 3 has copied data
					//$display("Transaction completed");	
				#1;		
				end
				#1;
		end







// The first core is assumed to be core number 1

initial
	begin
	
 
		#10	T_DataMem_Ready <= 0;
		#10	T_InsMem_Ready <= 0;
		#10	T_clock <= 0;
		#10	T_D_Bus_RQ <= 4'b0000;  // 
		#10	T_I_Bus_RQ <= 4'b0000;  // 
		#10	T_reset <= 1;





	
		$display(" --------  Test begins  ------------------");
		#100 T_reset <= 0;  

		#500;
		#100 T_D_Bus_RQ <= 4'b0001;

		#200 T_D_Bus_RQ <= 4'b0010;
		#1500;
		$display(" --------  Test ENDS  ------------------");
		$finish;
		/*
		//#500 T_DataMem_Ready <= 1'b1;


		//#200 T_D_Bus_RQ <= 4'b0000;

		//#300 T_DataMem_Ready <= 1'b0;

		//#50 T_DataMem_Ready <= 1'b1;


		//RQ(1);
		//#200 T_DataMem_Ready <= 1'b1;


		//	#100 T_D_Bus_RQ <= 4'b0001;	// A request from core 0 is placed
		//	#100 T_D_Bus_RQ = 4'b0010;	// A request from core 1 is placed	
		//	#100 T_D_Bus_RQ = 4'b0100;	// A request from core 2is placed
		//	#100 T_D_Bus_RQ = 4'b1000;	// A request from core 3 is placed




		#1000 T_D_Bus_RQ <= 4'b0010;	// A request from core 1 is placed
		#100 T_DataMem_Ready <= 1'b1;	// Data is ready on the Data BUS
		#100 T_D_Bus_RQ <= 4'b0000;		//Core Has taken the Data
		#100 T_DataMem_Ready <= 1'b0;	// Transaction Complete0


		#100 T_D_Bus_RQ <= 4'b0001;	// A request from core 0 is place0
		#100 T_D_Bus_RQ <= 4'b0011;	// A request from core 1 is placed //--0
		#100 T_DataMem_Ready <= 1'b1;	// Data is ready on the Data BUS
		#100 T_D_Bus_RQ <= 4'b0010;		//Core0 Has taken the Data		//---
		#100 T_DataMem_Ready <= 1'b0;	// Transaction Complete0
		#200 T_DataMem_Ready <= 1'b1;	// Data is ready on the Data BUS
		#100 T_D_Bus_RQ <= 4'b0000;		//Core Has taken the Data
		#100 T_DataMem_Ready <= 1'b0;	// Transaction Completed

		//	#15 Mem_Ready = 1;
		//	#30 Mem_Ready = 0;
		//	#15 RQ = 2'd2;
		//	#15 RQ = 2'd2;


		*/

	end

endmodule