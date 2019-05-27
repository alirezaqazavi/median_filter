`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:52:17 05/06/2019 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
	 input clk,
    output wire o_hs,       // horizontal sync output
    output wire o_vs,       // vertical sync output
    output wire [1:0] VGA_R,    // 3-bit VGA red output
    output wire [1:0] VGA_G,    // 3-bit VGA green output
    output wire [1:0] VGA_B    
    );
	 
	 reg [1:0]rgb;
	 //wire [2:0]d;
	 wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511
	 reg [15 : 0] addra=0;
	 wire [7 : 0] douta;
	 reg [15:0]temp;
	 reg [1:0]c=0 ;
	// reg signed [15:0]Gx=0;
	// reg signed [15:0]Gy=0;
	// reg [16:0]Gx_abs;
	// reg [16:0]Gy_abs;
	// reg [17:0] a;
	 //integer n,m;

	clocking_wizard clocking_wizard
   (// Clock in ports
    .CLK_IN1(clk),      // IN
    // Clock out ports
    .CLK_OUT1(clk25),     // OUT
    .CLK_OUT2(clk75),
	  .LOCKED(LOCKED));    // OUT

	 
	PIC_ROM ROM_PIC (
	.clka(clk75), // input clka
	.addra(addra), // input [15 : 0] addra
	.douta(douta) // output [7 : 0] douta
	);

	vga640x480 vga_sync (
    .i_clk(clk25), 
    .i_rst(1'b0), 
    .o_hs(o_hs), 
    .o_vs(o_vs), 
    //.o_blanking(o_blanking), 
    .o_active(video_on), 
    //.o_screenend(o_screenend), 
    //.o_animate(o_animate), 
    .o_x(x), 
    .o_y(y)
    );

	reg signed[9:0] r11=0;
	reg signed[9:0] r12=0;
	reg signed[9:0] r13=0;
	reg signed[9:0] r21=0;
	reg signed[9:0] r22=0;
	reg signed[9:0] r23=0;
	reg signed[9:0] r31=0;
	reg signed[9:0] r32=0;
	reg signed[9:0] r33=0;
	
	reg signed[9:0] a11=0;
	reg signed[9:0] a12=0;
	reg signed[9:0] a13=0;
	reg signed[9:0] a21=0;
	reg signed[9:0] a22=0;
	reg signed[9:0] a23=0;
	reg signed[9:0] a31=0;
	reg signed[9:0] a32=0;
	reg signed[9:0] a33=0;
	
	
	always @(posedge clk25) 
		begin
			if((video_on)&(LOCKED))
				begin
					if ((x > 207) & (x < 432) & (y > 127) & (y < 352))
						begin
						r11<=r12;
						r21<=r22;
						r31<=r32;
						r12<=r13;
						r22<=r23;
						r32<=r33;
                  temp <= (x - 208) + (y - 128) * 224;
                  rgb  <= a22 [7:6];
						end
					else
					begin
					rgb<=2'b00;
					end
				end
			else
			rgb<=2'b00;
		end
			
			
	always @(posedge clk75) 		
	begin
	if (c==2'b00) 
	begin
		addra=temp;
		r13=douta;
		c=2'b01;
	end
	else if(c==2'b01)
	begin
		addra=temp+224;
		r23=douta;
		c=2'b10;
	end
	else if(c==2'b10)
	begin
		addra = temp+448;
		r33 = douta;
		c =2'b00;
	end
	else
	c=2'b00;
	end
	

	always@(posedge clk25) begin
	//satr1
	a11=(r11<r12)? r11:r12;
	a11=(a11<r13)? a11:r13;
	a13=(r11>r12)? r11:r12;
	a13=(a13>r13)? a13:r13;
	a12=((r11>a11)&&(r11<a13))?r11:a12;
	a12=((r12>a11)&&(r12<a13))?r12:a12;
	a12=((r13>a11)&&(r13<a13))?r13:a12;
	//satr2
	a21=(r21<r22)? r21:r22;
	a21=(a21<r23)? a21:r23;
	a23=(r21>r22)? r21:r22;
	a23=(a23>r23)? a23:r23;
	a22=((r21>a21)&&(r21<a23))?r21:a22;
	a22=((r22>a21)&&(r22<a23))?r22:a22;
	a22=((r23>a21)&&(r23<a23))?r23:a22;
	//satr3
	a31=(r31<r32)? r31:r32;
	a31=(a31<r33)? a31:r33;
	a33=(r31>r32)? r31:r32;
	a33=(a33>r33)? a33:r33;
	a32=((r31>a31)&&(r31<a33))?r31:a32;
	a32=((r32>a31)&&(r32<a33))?r32:a32;
	a32=((r33>a31)&&(r33<a33))?r33:a32;
	
	
	
	//sotoon1
	a11=(r11<r21)? r11:r21;
	a11=(a11<r31)? a11:r31;
	a31=(r11>r21)? r11:r21;
	a31=(a31>r31)? a31:r31;
	a21=((r11>a11)&&(r11<a31))?r11:a21;
	a21=((r21>a11)&&(r21<a31))?r21:a21;
	a21=((r31>a11)&&(r31<a31))?r31:a21;
		//sotoon2
	a12=(r12<r22)? r12:r22;
	a12=(a12<r32)? a12:r32;
	a32=(r12>r22)? r12:r22;
	a32=(a32>r32)? a32:r32;
	a22=((r12>a12)&&(r12<a32))?r12:a22;
	a22=((r22>a12)&&(r22<a32))?r22:a22;
	a22=((r32>a12)&&(r32<a32))?r32:a22;
	
	//sotoon3
	a13=(r13<r23)? r13:r23;
	a13=(a13<r33)? a13:r33;
	a33=(r13>r23)? r13:r23;
	a33=(a33>r33)? a33:r33;
	a23=((r13>a13)&&(r13<a33))?r13:a23;
	a23=((r23>a13)&&(r23<a33))?r23:a23;
	a23=((r33>a13)&&(r33<a33))?r33:a23;
	
	
	//ghotr asli
	a11=(r11<r22)? r11:r22;
	a11=(a11<r33)? a11:r33;
	a33=(r11>r22)? r11:r22;
	a33=(a33>r33)? a33:r33;
	a22=((r11>a11)&&(r11<a33))?r11:a22;
	a22=((r22>a11)&&(r22<a33))?r22:a22;
	a22=((r33>a11)&&(r33<a33))?r33:a22;
	
	end
	
	assign VGA_R[1] = rgb[1];
	assign VGA_R[0] = rgb[0];
	assign VGA_G[1] = rgb[1];
	assign VGA_G[0] = rgb[0];
	assign VGA_B[1] = rgb[1];
	assign VGA_B[0] = rgb[0];
	
endmodule
