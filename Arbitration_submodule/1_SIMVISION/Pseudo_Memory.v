`timescale 1ns / 1ns   // <time_unit> / <time_precision>


module Pseudo_Memory;



// Pseudo Data memory States
reg [1:0] Pseudo_D_Memory_Current_State,Pseudo_D_Memory_Next_State ;

localparam	Pseudo_D_Memory_State_Idle 				= 2'b00 ;
localparam	Pseudo_D_Memory_State_Read_HIGH 		= 2'b01 ;
//localparam	Pseudo_D_Memory_State_Wait_MEM_LOW 	= 2'b11 ;



//	Pseudo Data Memory Sequential always Block

always@(posedge clk or posedge reset) 
	if(reset)
		#1 Pseudo_D_Memory_Current_State <= Pseudo_D_Memory_State_Idle ; // On reset, go to the Idle state
	else
		#1 Pseudo_D_Memory_Current_State <= Pseudo_D_Memory_Next_State ; // If not resetting, start sequencing the states




//	Pseudo Data Memory combinational always Block
always@(*)
begin
	case(Pseudo_D_Memory_Current_State)
//------------------------------------------------------------------------------------------
	Pseudo_D_Memory_State_Idle: 	
		begin
			
			// Show that the data is not valid 
			#(5*m) tb_Bus_DataMem_Ready = 0'b0;

			// Idle 
			#(5*m) tb_Bus_DataMem_In = 32'dx;

			// When the read signal goes high
			if( (tb_Bus_DataMem_Read == 1'b1) )
				#(5*m) Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Read_HIGH;
			else
				Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle;

		end	
//------------------------------------------------------------------------------------------
	Pseudo_D_Memory_State_Read_HIGH:
		begin
			// Add 6 to the Address and return it as data
			#(5*m) tb_Bus_DataMem_In = tb_Bus_DataMem_Address + 32'd6;

			// Raise the ready signal, to inform that the data being served is valid
			#(15*m) tb_Bus_DataMem_Ready = 1'b1;

			// When the read signal goes low move on to Idle
			if(tb_Bus_DataMem_Read == 1'b0)
				begin
					#5 Pseudo_D_Memory_Next_State = Pseudo_D_Memory_State_Idle  ;
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


endmodule