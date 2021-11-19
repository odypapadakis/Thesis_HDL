`timescale 1ns / 1ns   // <time_unit> / <time_precision>

// This is a testbench to test the functionality of the arbitration module.

/* Int this testbench, we are simulating 
*the Processor 		--> Pseudo_CPU 
*the Bus  			--> Pseudo_BUS
*the Bus Arbiter	--> Pseudo_Arbiter
*
* The purpose of this TestBench to determine wether the arbitration module can :
*	1) successfully isolate a core from the bus, based on the signals coming from the Aarbiter.
*	2) successfully forward the signals form the processor to the bus, and vice-versa
*	
*	To achieve the above some Pseudo elements are created, to play the part of: The bus, memory, arbiter 
*	
*	The processor is simulated by manuall driving signals in the initial block at the bottom of this testbench.
*/

module ArbitrationSubModule_Testbench;


reg heartbeat;
reg clk;
reg reset;


// Pseudo CPU signals -----------------------------


	// Data bus

		// Processor --> Arbitration Module
		reg 		tb_P_DataMem_Read;
		reg	[3:0]   tb_P_DataMem_Write;
		reg	[29:0]	tb_P_DataMem_Address;
		reg	[31:0]	tb_P_DataMem_Out;

		// Arbitration Module --> Processor
		wire	[31:0]	tb_P_DataMem_In;
		wire			tb_P_DataMem_Ready;


	//  Instruction Bus	

		// Processor --> Arbitration Module 	
		reg	[29:0]	tb_P_InstMem_Address;
		reg			tb_P_InstMem_Read;

		// Arbitration Module --> Processor		
		wire			tb_P_InstMem_Ready;
		wire	[31:0]	tb_P_InstMem_In;



// Pseudo BUS signals -----------------------------


	// Regarding the Data bus

		//	Bus --> Arbitration Module
		reg	[31:0]	tb_Bus_DataMem_In;		
		reg			tb_Bus_DataMem_Ready;	

		//	Arbitration Module --> Bus
		wire			tb_Bus_DataMem_Read;		
		wire	[3:0] 	tb_Bus_DataMem_Write;		
		wire	[29:0]	tb_Bus_DataMem_Address;	
		wire	[31:0]	tb_Bus_DataMem_Out;		


	// Regarding the Instruction Bus 

		//	Bus --> Arbitration Module     
		reg			tb_Bus_InstMem_Ready;   
		reg	[31:0]	tb_Bus_InstMem_In;		

		//	Arbitration Module -- > Bus		
		wire	[29:0]	tb_Bus_InstMem_Address;
		wire			tb_Bus_InstMem_Read;


// Pseudo Arbiter sinals --------------------------

	// Regarding the Data bus
		wire	tb_D_Bus_RQ;		 	
		reg		tb_D_Bus_GRANT;


	// Regarding the Instruction Bus        
		wire	tb_I_Bus_RQ;			 
		reg		tb_I_Bus_Arbiter_GRANT;  




ArbitrationSubModule uut(



//uut signals 			// Testbench signals


//Data Bus signal connections
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
	.I_Bus_GRANT			(tb_I_Bus_Arbiter_GRANT)


);



//   -----------------------   Instruction  stuff ----------------------------------------------------------------------------

reg [1:0] Pseudo_D_Arbiter_Current_State,Pseudo_D_Arbiter_Next_State ;

localparam	Pseudo_D_Arbiter_State_Idle 			= 2'b00 ;
localparam	Pseudo_D_Arbiter_State_RQ_HIGH 			= 2'b01 ;
localparam	Pseudo_D_Arbiter_State_RQ_LOW 			= 2'b10 ;
localparam	Pseudo_D_Arbiter_State_Wait_MEM_LOW 	= 2'b11 ;



//	Pseudo Instruction Arbiter Sequential always Block

always@(posedge clk or posedge reset) 
	if(reset)
		Pseudo_D_Arbiter_Current_State <= Pseudo_D_Arbiter_State_Idle ; // On reset, go to the Idle state
	else
		Pseudo_D_Arbiter_Current_State <= Pseudo_D_Arbiter_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Instruction Arbiter combinational always Block
always@(*)
begin
	case(Pseudo_D_Arbiter_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_D_Arbiter_State_Idle: 	
		begin
			tb_I_Bus_Arbiter_GRANT = 1'b0; // The bus is busy , therefore the arbiter drives the grant signal low.

			// If there is a request  and memory is ready
			if( (tb_I_Bus_RQ == 1'b1)  && (tb_Bus_InstMem_Ready == 1'b0) )  
				#50 Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_RQ_HIGH;
			else
				Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_D_Arbiter_State_RQ_HIGH:
		begin
			#50  tb_I_Bus_Arbiter_GRANT = 1'b1;

			if(tb_I_Bus_RQ == 1'b0)
				begin
					#50 Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_RQ_LOW  ;
				end
			else
				Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_RQ_HIGH;	
			end
//------------------------------------------------------------------------------------------
	Pseudo_D_Arbiter_State_RQ_LOW:
		begin	
			#50  tb_I_Bus_Arbiter_GRANT = 1'b0;
			#50  Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_Idle  ;
					
		end
//------------------------------------------------------------------------------------------
	// Pseudo_D_Arb_State_Wait_MEM_LOW:
	// 	begin	
	// 		if(tb_Bus_InstMem_Ready == 1'b0)
	// 			begin
	// 				#50 I_Arb_State = I_Arb_State_Idle  ;
	// 			end		
	// 	end
//------------------------------------------------------------------------------------------
	default:
		begin
			Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_Idle ;
			tb_I_Bus_Arbiter_GRANT = 1'b0;
		end

	endcase	

end



reg [1:0] Pseudo_D_Memory_Current_State,Pseudo_D_Memory_Next_State ;

localparam	Pseudo_D_Memory_State_Idle 			= 2'b00 ;
localparam	Pseudo_D_Memory_State_Read_HIGH 		= 2'b01 ;
//localparam	Pseudo_D_Memory_State_Wait_MEM_LOW 	= 2'b11 ;



//	Pseudo Instruction Memory Sequential always Block

always@(posedge clk or posedge reset) 
	if(reset)
		Pseudo_D_Memory_Current_State <= Pseudo_D_Memory_State_Idle ; // On reset, go to the Idle state
	else
		Pseudo_D_Memory_Current_State <= Pseudo_D_Memory_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Instruction Memory combinational always Block
always@(*)
begin
	case(Pseudo_D_Memory_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_D_Memory_State_Idle: 	
		begin
			// When Idle Drive the Instruction Bus with 001 
			#50 tb_Bus_InstMem_In = 32'd1;

			// And show that the data is not valid 
			#25 tb_Bus_InstMem_Ready = 0'b0;


			// When the read signal goes high
			if( (tb_Bus_InstMem_Read == 1'b1) )
				#50 Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Read_HIGH;
			else
				Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_D_Memory_State_Read_HIGH:
		begin
			// Add 4 to the Address and return it as data
			#50 tb_Bus_InstMem_In = tb_Bus_InstMem_Address + 32'd4;

			// Raise the ready signal, to inform that the data being served is valid
			#50 tb_Bus_InstMem_Ready = 1'b1;

			// When the read signal goes low move on to Idle
			if(tb_Bus_InstMem_Read == 1'b0)
				begin
					#50 Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle  ;
				end
			else
				Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Read_HIGH;	
			end
//------------------------------------------------------------------------------------------
	default:
		begin
			Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle ;
		end

	endcase	

end







//   -----------------------   Data  stuff ----------------------------------------------------------------------------

reg [1:0] Pseudo_D_Arbiter_Current_State,Pseudo_D_Arbiter_Next_State ;

localparam	Pseudo_D_Arbiter_State_Idle 			= 2'b00 ;
localparam	Pseudo_D_Arbiter_State_RQ_HIGH 			= 2'b01 ;
localparam	Pseudo_D_Arbiter_State_RQ_LOW 			= 2'b10 ;
localparam	Pseudo_D_Arbiter_State_Wait_MEM_LOW 	= 2'b11 ;



//	Pseudo Data Arbiter Sequential always Block

always@(posedge clk or posedge reset) 
	if(reset)
		Pseudo_D_Arbiter_Current_State <= Pseudo_D_Arbiter_State_Idle ; // On reset, go to the Idle state
	else
		Pseudo_D_Arbiter_Current_State <= Pseudo_D_Arbiter_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Data Arbiter combinational always Block
always@(*)
begin
	case(Pseudo_D_Arbiter_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_D_Arbiter_State_Idle: 	
		begin
			tb_D_Bus_Arbiter_GRANT = 1'b0; // The bus is busy , therefore the arbiter drives the grant signal low.

			// If there is a request  and memory is ready
			if( (tb_D_Bus_RQ == 1'b1)  && (tb_Bus_DataMem_Ready == 1'b0) )  
				#50 Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_RQ_HIGH;
			else
				Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_D_Arbiter_State_RQ_HIGH:
		begin
			#50  tb_I_Bus_Arbiter_GRANT = 1'b1;

			if(tb_I_Bus_RQ == 1'b0)
				begin
					#50 Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_RQ_LOW  ;
				end
			else
				Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_RQ_HIGH;	
			end
//------------------------------------------------------------------------------------------
	Pseudo_D_Arbiter_State_RQ_LOW:
		begin	
			#50  tb_I_Bus_Arbiter_GRANT = 1'b0;
			#50  Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_Idle  ;
					
		end
//------------------------------------------------------------------------------------------
	// Pseudo_D_Arb_State_Wait_MEM_LOW:
	// 	begin	
	// 		if(tb_Bus_InstMem_Ready == 1'b0)
	// 			begin
	// 				#50 I_Arb_State = I_Arb_State_Idle  ;
	// 			end		
	// 	end
//------------------------------------------------------------------------------------------
	default:
		begin
			Pseudo_D_Arbiter_Next_State = Pseudo_D_Arbiter_State_Idle ;
			tb_I_Bus_Arbiter_GRANT = 1'b0;
		end

	endcase	

end



reg [1:0] Pseudo_D_Memory_Current_State,Pseudo_D_Memory_Next_State ;

localparam	Pseudo_D_Memory_State_Idle 			= 2'b00 ;
localparam	Pseudo_D_Memory_State_Read_HIGH 		= 2'b01 ;
//localparam	Pseudo_D_Memory_State_Wait_MEM_LOW 	= 2'b11 ;



//	Pseudo Instruction Memory Sequential always Block

always@(posedge clk or posedge reset) 
	if(reset)
		Pseudo_D_Memory_Current_State <= Pseudo_D_Memory_State_Idle ; // On reset, go to the Idle state
	else
		Pseudo_D_Memory_Current_State <= Pseudo_D_Memory_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Instruction Memory combinational always Block
always@(*)
begin
	case(Pseudo_D_Memory_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_D_Memory_State_Idle: 	
		begin
			// When Idle Drive the Instruction Bus with 001 
			#50 tb_Bus_InstMem_In = 32'd1;

			// And show that the data is not valid 
			#25 tb_Bus_InstMem_Ready = 0'b0;


			// When the read signal goes high
			if( (tb_Bus_InstMem_Read == 1'b1) )
				#50 Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Read_HIGH;
			else
				Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_D_Memory_State_Read_HIGH:
		begin
			// Add 4 to the Address and return it as data
			#50 tb_Bus_InstMem_In = tb_Bus_InstMem_Address + 32'd4;

			// Raise the ready signal, to inform that the data being served is valid
			#50 tb_Bus_InstMem_Ready = 1'b1;

			// When the read signal goes low move on to Idle
			if(tb_Bus_InstMem_Read == 1'b0)
				begin
					#50 Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle  ;
				end
			else
				Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Read_HIGH;	
			end
//------------------------------------------------------------------------------------------
	default:
		begin
			Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle ;
		end

	endcase	

end














initial		// Initialization initial block 
	begin
		$display("Starting Simulation ");

		heartbeat = 0;
		clk = 0;
		reset = 1;

		// The defaults when idle shall be he following

		// For the instruction Bus
		tb_P_InstMem_Address	= 'h1;
		tb_P_InstMem_Read		= 1'b0; 

		// For the Data Bus
		tb_P_DataMem_Read 		= 1'b0;
		tb_P_DataMem_Write 		= 4'd0;

		tb_P_DataMem_Address 	= 29'h0001;
		tb_P_DataMem_Out 		= 32'h0001;


		// System is running
		#100 reset = 0;



	end

initial		// Instruction Initial block
	begin
		
		#100;

		// Processor wants the Instruction at address 5
		#200 tb_P_InstMem_Address	= 29'd5;	
		#50 tb_P_InstMem_Read = 1'b1;

		// Processor no longer need the instruction
		#500 tb_P_InstMem_Read = 1'b0;
		
	end


initial	// Data Initial block
	begin
		
		#100;

		#200 tb_P_DataMem_Address	= 29'd4;
		#100 tb_P_DataMem_Out		= 32'd3;
		#100 tb_P_DataMem_Write		= 4'b1111;
	end


// Clock does clock things
always #50 clk = !clk;
	
	// This is a diagnostic signal that serves no purpose 
always #300 heartbeat = !heartbeat;	

endmodule