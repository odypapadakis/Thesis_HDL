`timescale 1ns / 1ps

/*

* File			: Pseudo_MEMv
* Project 		: Univeristy of Patras, Computer engineering & informatics dept.
*			 	  Design of a multicore system based on the mips32 processor.
* Creator(s)	: Odysseas Papadakis	
*
* Description: This is a pseudo module, an actor that is called to play the role
*				Of the memory system in simulations for the project.
*				It contains delays , it is therefore non synthesizable
*				Two always blocks are running, to simulate the ability to access
*				Data and instruction memory at the same time	
*/

module PSEUDO_MEM(

	input 			clock	,
	input 			reset	,

	// DATA SIGNALS
	input 			DataMem_Read	,
	input 	[3:0] 	DataMem_Write	,	
	input 	[29:0]	DataMem_Address	,
	input 	[31:0]	DataMem_In		,

	output	reg 	[31:0]	DataMem_Out		,
	output	reg		DataMem_Ready	,


	// INSTRUCTION SIGNALS
	input	[29:0]	InstMem_Address	,
	input			InstMem_Read	,

	output 	reg			InstMem_Ready	,
	output 	reg	[31:0]	InstMemData		


	);

	always@( posedge clock  or posedge reset  )
	begin
		if( reset )
			begin
				DataMem_Out 	<= 'd0;
				DataMem_Ready	<= 1'b0;
			end
		else if (DataMem_Read == 1'b1)	
			begin
				#50 DataMem_Out <= 'b111;
				#50 DataMem_Ready <= 1'b1;			
			end
		else if (DataMem_Write[3] == 1'b1 | DataMem_Write[2] == 1'b1 | DataMem_Write[1] == 1'b1 | DataMem_Write[0] == 1'b1)		
			begin
				#50 DataMem_Ready <= 1'b1;
			end
		else 
			begin
				#50 DataMem_Out <= 'b001;
				#50 DataMem_Ready <= 1'b0;
			end

	end
	
	always@( posedge clock  or posedge reset  )
	begin
		if( reset )
			begin
				InstMem_Ready  	<= 1'b0;
				InstMemData		<= 'd0;
			end
		else if (InstMem_Read == 1'b1)
			begin
				#100 	InstMemData <= 'b0101;
				#50		InstMem_Ready <= 1'b1;
			end
		else
			begin
				#100 	InstMemData <= 'b0001;
				#100 InstMem_Ready <= 1'b0;
			end

	end

endmodule