`timescale 1ns / 1ns
`default_nettype none

module tb();
	  //input
	
	
	reg CLK, RST, BUTTON, SENSOR, PR, PG, RR, RG, RY;
	
	//wire [5:0] O;
	
	initial CLK <= 0;
	
	always #10 CLK <=~CLK; // P = 20ns, f = 50MHz
		
	initial begin
		RST = 1'b1;
		#50
		RST = 1'b0;
	end;
	
	initial begin
		BUTTON = 1'b0;
		#500
		BUTTON = 1'b1;
		#1000
		BUTTON = 1'b0; 
		;
	end	
	
	
	crosswalk gg(  
	.RST(RST), 
	.CLK(CLK), 
	.BUTTON(BUTTON),
	.SENSOR(SENSOR),
	.PR(PR),	// Pedestrian Red
	.PG(PG),    // Pedestrian Green 
	.RR(RR),	// Road Red 
	.RG(RG),	// Road Green
	.RY(RY)	// Road Yellow 	
	);  
	

endmodule
	