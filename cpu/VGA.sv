module VGA
#(
	parameter HEIGHT = 480,
	parameter WIDTH = 640,
	// available memory area
	parameter MEM_HEIGHT = 256,
	parameter MEM_WIDTH = 256,
	// address offset
	parameter MEM_ADDR_OFFSET = 0,
	// unit is pixel clock cycle
	parameter HSYNC_WIDTH = 96,
	parameter H_BACK_PORCH = 48,
	parameter H_FRONT_PORCH = 16,
	// unit is lines
	parameter VSYNC_HEIGHT = 2,
	parameter V_BACK_PORCH = 33,
	parameter V_FRONT_PORCH = 10
)
(
	// must be 25 MHz
	input logic clock,
	input logic clear,
	
	output logic[15:0] addr = MEM_ADDR_OFFSET,
	output logic mem_clock,
	input logic[15:0] data,
	
	output logic [3:0] VGA_R = 3'b0,
	output logic [3:0] VGA_G = 3'b0,
	output logic [3:0] VGA_B = 3'b0,
	output logic VGA_HS,
	output logic VGA_VS
);
	localparam WIDTH_TOTAL = HSYNC_WIDTH + H_BACK_PORCH + WIDTH + H_FRONT_PORCH;
	localparam HEIGHT_TOTAL = VSYNC_HEIGHT + V_BACK_PORCH + HEIGHT + V_FRONT_PORCH;

	always_comb begin
		if ( x < HSYNC_WIDTH ) begin
			VGA_HS <= 0;
		end
		else begin
			VGA_HS <= 1;
		end
			
		if ( y < VSYNC_HEIGHT ) begin
			VGA_VS <= 0;
		end
		else begin
			VGA_VS <= 1;
		end
	end

	logic select_l = 0;
	logic [15:0] x = 15'b0;
	logic [15:0] y = 15'b0;

	always_ff @( posedge clock or posedge clear ) begin
		if ( clear ) begin
			x <= 15'b0;
			y <= 15'b0;
			addr <= 15'b0;
		end
		else if ( x >= H_BACK_PORCH && x < WIDTH + H_FRONT_PORCH && y >= V_BACK_PORCH && y < HEIGHT + V_FRONT_PORCH ) begin
			if ( select_l ) begin
				VGA_R = { data[ 9: 8], 0 };
				VGA_G = { data[11:10], 0 };
				VGA_B = { data[13:12], 0 };
			end
			else begin
				VGA_R = { data[ 1: 0], 0 };
				VGA_G = { data[ 3: 2], 0 };
				VGA_B = { data[ 5: 4], 0 };
			end
		end
	end

	always_ff @( negedge clock ) begin
		if ( select_l ) begin
			select_l <= 0;
			addr = addr + 15'h1;
		end
		else begin
			select_l <= 1;
		end
	end

endmodule