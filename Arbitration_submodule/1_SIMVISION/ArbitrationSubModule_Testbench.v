`timescale 1ns / 1ns   // <time_unit> / <time_precision>

// This is a testbench to test the functionality of the arbitration module.

/* Int this testbench, we are simulating 
*the Processor 		--> Pseudo_CPU 
*the Bus  			--> Pseudo_BUS
*the Bus Arbiter	--> Pseudo_Arbiter
*
* The purpose of this TestBench to determine wether the rbitration module can successfully
* isolate a core from the bus, based on the signals coming from the Aarbiter.
*
* 
*/

module ArbitrationSubModule_Testbench;



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
		reg		tb_I_Bus_GRANT;  




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
	.I_Bus_GRANT			(tb_I_Bus_GRANT)


);


// initial 		// Data initial block
// 	begin


// 		//Bus --> Arbitration Module
// 		tb_Bus_DataMem_In		= 'd63;	
// 		tb_Bus_DataMem_Ready	= 0;

// 		// Processor --> Arbitration Module
// 		tb_P_DataMem_Read		= 0;	
// 		tb_P_DataMem_Write		= 0;	
// 		tb_P_DataMem_Address	= 'd31;		
// 		tb_P_DataMem_Out		= 'd127;

// 		tb_D_Bus_GRANT 			= 0;	


// 		#100 tb_P_DataMem_Read		<= 1;
// 		#50 tb_D_Bus_GRANT 	<= 1'b1;
// 		#100 tb_P_DataMem_Read		<= 0;		
// 		#50 tb_D_Bus_GRANT 	<= 1'b0;




// 		#100 tb_P_DataMem_Write <= 4'b0001;
// 		#50 tb_D_Bus_GRANT 	<= 1'b1;
// 		#50 tb_D_Bus_GRANT 	<= 1'b0;		
// 		#100 tb_P_DataMem_Write <= 4'b0000;

// 		#100 tb_P_DataMem_Write <= 4'b0010;
// 		#100 tb_P_DataMem_Write <= 4'b0000;

// 		#100 tb_P_DataMem_Write <= 4'b0100;
// 		#50 tb_D_Bus_GRANT 	<= 1'b1;
// 		#50 tb_D_Bus_GRANT 	<= 1'b0;		
// 		#100 tb_P_DataMem_Write <= 4'b0000;

// 		#100 tb_P_DataMem_Write <= 4'b1000;
// 		#100 tb_P_DataMem_Write <= 4'b0000;

// 		#100 tb_P_DataMem_Read	<= 1'b1;

// 		#50 tb_D_Bus_GRANT 	<= 1'b1;
// 		#50 tb_D_Bus_GRANT 	<= 1'b0;

// 	end


// pseudo Arbiter FSM STARTS --------------------------------------------------

// This FSM will simulate the bus arbiter. 
//	It will function as follows:

//	FSM state: I_Arb_State_Idle
//	It will initially set the bus as occupied, during which time we expect the arbitration submodule to 
//  be driving the outputs that are touching teh bus to HIGH-Z

//	After th pseudo arbiter has received a request for bus usage  from the arbitraion submodule, 
// 	it should grant the bus to the submodule after a randomized amount of time, simulating the possibility
//	thet the bus might be busy.
//	

reg [2:0] Pseudo_I_Arbiter_Current_State,Pseudo_I_Arbiter_Next_State ;

localparam	Pseudo_I_Arbiter_State_Idle 			= 0 ;
localparam	Pseudo_I_Arbiter_State_RQ_HIGH 			= 1 ;
localparam	Pseudo_I_Arbiter_State_RQ_LOW 			= 2 ;
localparam	Pseudo_I_Arbiter_State_Wait_MEM_LOW 	= 3 ;



//	Pseudo Instruction Arbiter Sequential always Block

always@(posedge clk or posedge reset) 
	if(~reset)
		Pseudo_I_Arbiter_Current_State <= Pseudo_I_Arbiter_State_Idle ; // On reset, go to the Idle state
	else
		Pseudo_I_Arbiter_Current_State <= Pseudo_I_Arbiter_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Instruction Arbiter combinational always Block
always@(*)
begin
	case(Pseudo_I_Arbiter_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_I_Arbiter_State_Idle: 	// The bus is busy , therefore the arbiter drives tha grant signal low.
		begin
			tb_I_Bus_GRANT = 1'b0;

			if( (tb_I_Bus_RQ == 1'b1) )// && (tb_Bus_InstMem_Ready == 1'b0) )
				#50 Pseudo_I_Arbiter_Next_State = Pseudo_I_Arbiter_State_RQ_HIGH;
			else
				Pseudo_I_Arbiter_Next_State = Pseudo_I_Arbiter_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_I_Arbiter_State_RQ_HIGH:
		begin
			#50  tb_I_Bus_GRANT = 1'b1;

			if(tb_I_Bus_RQ == 1'b0)
				begin
					#50 Pseudo_I_Arbiter_Next_State = Pseudo_I_Arbiter_State_RQ_LOW  ;
				end
			else
				Pseudo_I_Arbiter_Next_State = Pseudo_I_Arbiter_State_RQ_HIGH;	
			end
//------------------------------------------------------------------------------------------
	Pseudo_I_Arbiter_State_RQ_LOW:
		begin	
			#50  tb_I_Bus_GRANT = 1'b0;
			#50  Pseudo_I_Arbiter_Next_State = Pseudo_I_Arbiter_State_Idle  ;
					
		end
//------------------------------------------------------------------------------------------
	// Pseudo_I_Arb_State_Wait_MEM_LOW:
	// 	begin	
	// 		if(tb_Bus_InstMem_Ready == 1'b0)
	// 			begin
	// 				#50 I_Arb_State = I_Arb_State_Idle  ;
	// 			end		
	// 	end
//------------------------------------------------------------------------------------------
	default:
		begin
			Pseudo_I_Arbiter_Next_State = Pseudo_I_Arbiter_State_Idle ;
			tb_I_Bus_GRANT = 1'b0;
		end

	endcase	

end







// pseudo Arbiter FSM ENDS --------------------------------------------------

/*
// pseudo Memory FSM STARTS --------------------------------------------------

reg [1:0] Mem_State;
localparam	Mem_State_Idle 			    = 0;
localparam	Mem_State_Request_placed 	= 1;
localparam	Mem_State_Data_ready 		= 2;
localparam	Mem_State_Data_read 		= 3;



always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			tb_Bus_InstMem_Ready 	= 1'b0;	
			tb_Bus_InstMem_In 		= 'h0000;
			Mem_State = Mem_State_Idle;
		end
	else
	begin
		case(Mem_State)
						
					Mem_State_Idle:
					begin
						tb_Bus_InstMem_Ready 	= 1'b0;	
						tb_Bus_InstMem_In 		= 'hFFFF;
						if(tb_Bus_InstMem_Read == 1'b1)
							Mem_State = Mem_State_Request_placed;

					end

					Mem_State_Request_placed:
					begin

						#100 tb_Bus_InstMem_In = tb_Bus_InstMem_Address + 1 ;
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

*/


initial		// Instruction initial block
	begin
		$display("-----------------------------------------		Instruction initial block	-------------------------------");


		clk = 0;
		reset = 1;
		tb_P_InstMem_Address	= 'h0001;
		tb_P_InstMem_Read		= 1'b0; 

		#100 reset = 0;

		#50 tb_P_InstMem_Address	= 'hABB;	
		#10 tb_P_InstMem_Read = 1'b1;


		#1200 tb_P_InstMem_Read = 1'b0;
	end

always #50 clk = !clk;


endmodule