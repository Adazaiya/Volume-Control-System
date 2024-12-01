`define rom_size 6'd8

module CLOCK_500 (
	              CLOCK,
 	              CLOCK_500,
	              DATA,
	              END,
	              RESET,
	              GO,
	              CLOCK_2,
					  LEDR,
					  SW,
					  SW1,
					  SW2,
					  HEX0,
					  HEX1
                 );
//=======================================================
//  PORT declarations
//=======================================================                
	input  		 	CLOCK;
	input 		 	END;
	input 		 	RESET;
	input          SW;
	input          SW1;
	input          SW2;
	
	
	
	output   reg [6:0]   HEX0;
	output   reg [6:0]   HEX1;
//	output   reg [6:0]   HEX2;
//	output   reg [6:0]   HEX3;
//	output   reg [6:0]   HEX4;
//	output   reg [6:0]   HEX5;
//	output   reg [6:0]   HEX6;
	
	
	output  reg   [9:0] LEDR;
	output		    CLOCK_500;
	output 	[23:0]	DATA;
	output 			GO;
	output 			CLOCK_2;


	reg  	[10:0]	COUNTER_500;
	reg  	[15:0]	ROM[`rom_size:0];
	reg  	[15:0]	DATA_A;
	reg  	[5:0]	address;
	reg   [3:0] led_counter;
	reg   [3:0] mute;
	
	
	
initial begin
        led_counter = 1; // Start from the last LED
        LEDR = 10'b0000000000; // Initialize all LEDs to ON
    end



wire  CLOCK_500=COUNTER_500[9];
wire  CLOCK_2=COUNTER_500[1];
wire [23:0]DATA={8'h34,DATA_A};	
wire  GO =((address <= `rom_size) && (END==1))? COUNTER_500[10]:1;
wire [13:0] display_output; // Wire for the function output
//=============================================================================
// Structural coding
//=============================================================================

always @(negedge RESET or posedge END) 
	begin
		if (!RESET)
			begin
				address=0;
			end
		else if (address <= `rom_size)
				begin
					address=address+1;
				end
	end
	
	
	
	
//



function [13:0] get_7seg_display;
    input [3:0] value; // Input value (4-bit, between 1 and 14)
    reg [6:0] HEX0_seg; // LSB (units place)
    reg [6:0] HEX1_seg; // MSB (tens place)
	 
    
    begin
        // Decode LSB (units place)
        case (value % 10)
            4'd0: HEX0_seg = 7'b1000000;
            4'd1: HEX0_seg = 7'b1111001;
            4'd2: HEX0_seg = 7'b0100100;
            4'd3: HEX0_seg = 7'b0110000;
				
            4'd4: HEX0_seg = 7'b0011001;
            4'd5: HEX0_seg = 7'b0010010;
				4'd6: HEX0_seg = 7'b0000010;
				
            4'd7: HEX0_seg = 7'b1111000;
            4'd8: HEX0_seg = 7'b0000000;
            4'd9: HEX0_seg = 7'b0010000;
            default: HEX0_seg = 7'b1111111; // Blank display for invalid input
        endcase

        // Decode MSB (tens place)
        case (value / 10)
            4'd0: HEX1_seg = 7'b1000000;
            4'd1: HEX1_seg = 7'b1111001;
            default: HEX1_seg = 7'b1111111; // Blank display for invalid input
        endcase

        // Combine HEX1 and HEX0 into a single 14-bit output
        get_7seg_display = {HEX1_seg, HEX0_seg};
    end
	 
	 
	 
	 
	 
	 
endfunction
//////	
	
	
	
	
	
	
	
	
	
	
	

reg [4:0] vol;
reg [4:0] vol_2;

reg [6:0] volume_r;
reg [6:0] volume_l;




always @(posedge RESET) 
	begin
		if(SW==1) begin
			vol_2 = vol;
			vol <=0;
			mute=1;
			//led_counter=led_counter+1;
			LEDR[0]<=1'b1;

		end
		
		else begin

		
			if(mute==1) begin
			
				vol=vol_2;
			end
			
			mute=0;
			LEDR[0]<=1'b0;
	
			vol=vol-4;

			if (led_counter >1) begin
				//LEDR[led_counter] = 1'b0; // Turn off the current LED
				led_counter = led_counter - 1; // Move to the next LED
			  end
			else if (led_counter ==1) begin
				//LEDR = 10'b1111111111; // Initialize all LEDs to ON
				led_counter = 8;
				
			end
			
		
		end
	
	
	end


	
   always @(*) begin
		if (SW1==1) begin
			LEDR[1]<=1'b1;
			volume_r = vol+96;
			end
		else begin
			LEDR[1]<=1'b0;
			volume_r = 0+96;
			end
			
			
			
		if(SW2==1) begin
			LEDR[2]<=1'b1;
			volume_l= vol+96;
			
			end
			
		else begin
			LEDR[2]<=1'b0;
			volume_l = 0+96;
		end
		
			
//		else 
//			volume_r = vol+96;
//			volume_l = vol+96;
//			LEDR[2]<=1'b0;
//			LEDR[1]<=1'b0;
//		
		
		
    end
	
	
	
//assign volume_r = vol+96;
//assign volume_l = vol+96;






    // Generate the display output based on the current LED counter
    assign display_output = get_7seg_display(led_counter);

    // Assign display output to HEX0 and HEX1
    always @(*) begin
		if(mute==1) begin
			HEX0= 7'b1000000;
			HEX1= 7'b1000000;
		
		end 
		else begin
        HEX1 = display_output[13:7]; // Upper 7 bits go to HEX1
        HEX0 = display_output[6:0];  // Lower 7 bits go to HEX0
		   
		end
    end















always @(posedge END) 
	begin
	//	ROM[0] = 16'h1e00;
		ROM[0] = 16'h0c00;	    			 //power down
		ROM[1] = 16'h0ec2;	   		    	 //master
		ROM[2] = 16'h0838;	    			 //sound select
	
		ROM[3] = 16'h1000;					 //mclk
	
		ROM[4] = 16'h0017;					 //
		ROM[5] = 16'h0217;					 //
		ROM[6] = {8'h04,1'b0,volume_l[6:0]};		 //
		ROM[7] = {8'h06,1'b0,volume_r[6:0]};	     //sound vol
	
		//ROM[4]= 16'h1e00;		             //reset	
		ROM[`rom_size]= 16'h1201;            //active
		DATA_A=ROM[address];
	end

always @(posedge CLOCK ) 
	begin
		COUNTER_500=COUNTER_500+1;
	end

endmodule
