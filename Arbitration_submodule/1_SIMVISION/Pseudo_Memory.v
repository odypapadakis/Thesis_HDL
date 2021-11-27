`timescale 1ns / 1ns   // <time_unit> / <time_precision>


module Pseudo_Memory(

input clk;
input reset;


);




// Pseudo Instruction memory states

reg [1:0] Pseudo_I_Memory_Current_State,Pseudo_I_Memory_Next_State ;

localparam	Pseudo_I_Memory_State_Idle 				= 2'b00 ;
localparam	Pseudo_I_Memory_State_Read_HIGH 		= 2'b01 ;
//localparam	Pseudo_I_Memory_State_Wait_MEM_LOW 	= 2'b11 ;



//	Pseudo Instruction Memory Sequential always Block

always@(posedge clk or posedge reset) 
	if(reset)
		#1 Pseudo_I_Memory_Current_State <= Pseudo_I_Memory_State_Idle ; // On reset, go to the Idle state
	else
		#1 Pseudo_I_Memory_Current_State <= Pseudo_I_Memory_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Instruction Memory combinational always Block
always@(*)
begin
	case(Pseudo_I_Memory_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_I_Memory_State_Idle: 	
		begin
			// Show that the data is not valid 
			#5 tb_Bus_InstMem_Ready = 0'b0;

			//Idle 
			#5 tb_Bus_InstMem_In = 32'dx;

			// When the read signal goes high
			if( (tb_Bus_InstMem_Read == 1'b1) )
				#5 Pseudo_I_Memory_Next_State = Pseudo_I_Memory_State_Read_HIGH;
			else
				Pseudo_I_Memory_Next_State = Pseudo_I_Memory_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_I_Memory_State_Read_HIGH:
		begin
			// Add 4 to the Address and return it as data
			#20 tb_Bus_InstMem_In = tb_Bus_InstMem_Address + 32'd4;

			// Raise the ready signal, to inform that the data being served is valid
			#35 tb_Bus_InstMem_Ready = 1'b1;

			// When the read signal goes low move on to Idle
			if(tb_Bus_InstMem_Read == 1'b0)
				begin
					#5 Pseudo_I_Memory_Next_State = Pseudo_I_Memory_State_Idle  ;
				end
			else
				Pseudo_I_Memory_Next_State = Pseudo_I_Memory_State_Read_HIGH;	
			end
//------------------------------------------------------------------------------------------
	default:
		begin
			Pseudo_I_Memory_Next_State = Pseudo_I_Memory_State_Idle ;
		end

	endcase	

end



endmodule