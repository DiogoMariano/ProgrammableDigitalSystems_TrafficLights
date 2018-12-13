module crosswalk (  
	input  wire RST, 
	input  wire CLK, 
	input  wire BUTTON,
	input  wire SENSOR,
	
	output wire  PR,	// Pedestrian Red
	output wire  PG,    // Pedestrian Green 
	output wire  RR,	// Road Red 
	output wire  RG,	// Road Green
	output wire  RY,	// Road Yellow 	

	);       		
	
	parameter timerRed=10000;
	parameter timerGreen=10000;
	parameter timer_blink=50000;
	parameter timerYellow=3000;
	
	localparam START= 0;
	localparam RED_0 = 1;
	localparam GREEN_1 = 2;
	localparam BLINKING = 3;
	localparam YELLOW_1 = 4;
	localparam GREEN_2 = 5;
	localparam YELLOW_2 = 6;
	localparam DECR_DCNT = 7;
	
	reg [2:0] state, prev_state;
	reg [31:0] DCNT;
	reg [31:0] CNTGB ; //	 counter to make the green pedestrian blinking
	
	always @ (posedge CLK or posedge RST) // always block to update the present state
		if (RST) state <=START;
		else  
			case (state) 
				
				START			  :		  
					begin
						if (BUTTON)
							begin
								prev_state<=state;
								state <= GREEN_1;
							end 
						else if(SENSOR && !BUTTON)
							begin
								prev_state<=state;
								state <= YELLOW_1; 
							end
					end
				
				RED_0             : 
					begin
						prev_state<=state;
						state <= DECR_DCNT;
					end 
				
				GREEN_1          :                   
					begin
						state <= DECR_DCNT;
						prev_state<=state;	
					end
				
				
				DECR_DCNT        :  
					begin
						if (DCNT==0 && prev_state==GREEN_1)     state <= BLINKING;	
						else if(DCNT==0 && prev_state==BLINKING) state <= YELLOW_1;
						else if(DCNT==0 && prev_state==GREEN_2) state <= YELLOW_2;
						else if(DCNT==0 && prev_state==YELLOW_1) state<=GREEN_2;
						else if(DCNT==0 && prev_state==YELLOW_2) state<=RED_0;
						else if(DCNT==0 && prev_state==RED_0)    state<=GREEN_1;
						else             						 state <= DECR_DCNT; 
					end
				
				BLINKING 		:	
					begin
						prev_state<=state;
						state<=DECR_DCNT;
					end
				
				YELLOW_1        : 		
					begin	
						prev_state<=state;
						state<=DECR_DCNT;
					end
				
				GREEN_2			:	
					begin
						prev_state<=state;
						state<=DECR_DCNT;
					end										
				
				YELLOW_2		:						
					begin
						prev_state<=state;
						state<=DECR_DCNT;
					end
				
				default          :                   	state <= START;
			endcase
	
	always @ (posedge CLK or posedge RST) //counter to make the green pedestrian blinking
	if (RST) CNTGB<=32'b0;
	else if (CNTGB==32'b11111111111111111111111111111111) CNTGB<=32'b0;
	else CNTGB<=CNTGB+1;
			
			
			
	always@(posedge CLK or posedge RST)
		if(RST)                    DCNT <= 3'd0; 
		else if(state==RED_0)          DCNT<=timerRed;
		else if(state ==GREEN_1 || state==GREEN_2)    	DCNT <= timerGreen ;							
		else if(state==BLINKING)       DCNT<= timer_blink;
		else if(state==YELLOW_1 || state==YELLOW_2)		DCNT<= timerYellow;
		else if(state == DECR_DCNT)      DCNT <= DCNT - 'd1;
		
		else                            DCNT <= DCNT      ;
	
	
	reg O_PR;		//Declaration of all the output registers
	reg O_PG;
	reg O_RR;		  
	reg O_RG;
	reg O_RY;
		
			
			
			//reg[5:0] O_reg;
	
	always@(posedge CLK or posedge RST)
		if(RST)
			begin
				O_RR <=   1'b1;	  // 1 if the red is turned on
				O_PR <=   1'b1;
			
				O_PG <= 1'b0;
				O_RG <= 1'b0;
				O_RY <= 1'b0;
		  	end
		 else
		
		 case(state)
			 
			 START : 
				 begin  
				 	O_RR <= 1'b1;
				 	O_PR <= 1'b1;
				 
				 	O_PG <= 1'b0;
					O_RG <= 1'b0;
					O_RY <= 1'b0;
			 	 end
			 
			 RED_0 :
			 	begin
				 	O_RR <= 1'b1;
				 	O_PR <= 1'b1;
				 
				 	O_PG <= 1'b0;
				 	O_RG <= 1'b0;
				 	O_RY <= 1'b0;
			 	end
			 
			 GREEN_1 :
			 	begin
				 	O_RR <= 1'b1;
				 	O_PG <= 1'b1;
				 
				 	O_PR <= 1'b0;
				 	O_RG <= 1'b0;
				 	O_RY <= 1'b0;
			 	end
			 
			 YELLOW_1 :
			 	begin
				 	O_RY <= 1'b1;
				 	O_PR <= 1'b1; 
				 
				 	O_PG <= 1'b0;
				 	O_RG <= 1'b0;
				 	O_RR <= 1'b0;
			 	end
			 
			 YELLOW_2 :
			 	begin
				 	O_RY <= 1'b1;
				 	O_PR <= 1'b1;
				 
				 	O_PG <= 1'b0;
				 	O_RG <= 1'b0;
				 	O_RR <= 1'b0;
			 	end
			
			 GREEN_2 :
			 	begin
				 	O_RG <= 1'b1;
				 	O_PR <= 1'b1;
				 
				 	O_PG <= 1'b0;
				 	O_RR <= 1'b0;
				 	O_RY <= 1'b0;
			 	end
			 BLINKING :
			 	begin
				 	O_RR <= 1'b1;
				 	O_PG <= CNTGB[5];
				 
				 	O_PR <= 1'b0;
				 	O_RG <= 1'b0;
				 	O_RY <= 1'b0;
			 	end
			 DECR_DCNT :
			 begin  
				   	O_RR <= O_RR;	  // 1 if the red is turned on
					if (prev_state==BLINKING) O_PG <=CNTGB[5];
						else O_PG <= O_PG;
			
					O_PR <= O_PR;
					O_RG <= O_RG;
					O_RY <= O_RY;
				end
				
			  default :
			  	begin
					O_RR <=   1'b1;	  // 1 if the red is turned on
					O_PR <=   1'b1;
			
					O_PG <= 1'b0;
					O_RG <= 1'b0;
					O_RY <= 1'b0;  
			  	end
			endcase
		
		
		/*
		if(RST)                    O_reg<= 5'b00000;    
		else if(state ==    RED_0 || state==START )      O_reg<= 5'b10010;
		else if(state == GREEN_1)    O_reg<=5'b10001;
		else if(state==GREEN_2)    O_reg<=5'b01010;
		else if(state==YELLOW_1 || state==YELLOW_2)   O_reg<=5'b10110;
		else if(state==YELLOW_2)   O_reg<=5'b10110;	
		else O_reg<=O_reg; */
	
	
	assign PR = O_PR;
	assign PG = O_PG;
	assign RR = O_RR;
	assign RG = O_RG;
	assign RY = O_RY;
	
endmodule
