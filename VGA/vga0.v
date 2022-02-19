// file 			:	vga0.v
// author 			:	ZHUHAI.EE (wmy)
// date 			: 	2018-03-08
// description 		:	this file is a simple example for using VGA
// additional		:	get more information from wechat public number(xy_ee)
module vga0 
(
	input 			vga_clk,
	//add reset
	input 			rst_n,
	output 			vga_hs,
	output 			vga_vs,
	output[4:0] 	vga_red,
	output[5:0] 	vga_green,
	output[4:0] 	vga_blue
);
//	------------------------------------------------
//	param. definition 
//	------------------------------------------------
	parameter H_SYNC   =  12;  
	parameter H_BACK   =  40  ;
	parameter H_ACTIVE =  1920;  
	parameter H_FRONT  =  28 ; 
	parameter V_SYNC   =  4 ;
	parameter V_BACK   =  18 ;
	parameter V_ACTIVE =  1080  ;
	parameter V_FRONT  =  3 	;
	parameter HP = H_SYNC + H_BACK + H_ACTIVE + H_FRONT;
	parameter VP = V_SYNC + V_BACK + V_ACTIVE + V_FRONT;
	
	parameter START =1;
//	------------------------------------------------
//	register. definition 
//	------------------------------------------------
	reg [12:0] cnt_xx;
	reg [12:0] cnt_yy;
	//
	reg[4:0] red_r;
	reg[5:0] green_r;
	reg[4:0] blue_r;
	//
	reg hs_r;
	reg vs_r;
	//
	reg [15:0] dis_data;
	//
	always @(posedge vga_clk ,negedge rst_n)
		if(!rst_n) cnt_xx <= 1'b1;
		else if(cnt_xx == HP) cnt_xx <= 1'b1;
		else cnt_xx <= cnt_xx + 1'b1;
	//
	always @(posedge vga_clk,negedge rst_n)
	begin
		if(!rst_n) hs_r <= 1'b1;
		else if(cnt_xx == 1) hs_r <= 1'b0;
			else if(cnt_xx == H_SYNC) hs_r <= 1'b1;
	end
	//
	always @(posedge vga_clk ,negedge rst_n)
	begin 
		if(!rst_n) cnt_yy <= 1'b1;
		else if(cnt_yy == VP) cnt_yy <= 1'b1;
				else if(cnt_xx == HP) cnt_yy <= cnt_yy + 1'b1;	
	end 
	//
	always @(posedge vga_clk,negedge rst_n)
	begin 
		if(!rst_n) vs_r <= 1'b1;
		else if(cnt_yy == 1) vs_r <= 1'b0;
			else if (cnt_yy == V_SYNC) vs_r <= 1'b1;
	end 
	//
	always @(negedge vga_clk,negedge rst_n)
	begin 
	if(!rst_n)
		dis_data <= 16'hffff;
	else
		case(cnt_xx) 
		300:	dis_data <= 16'hffff;
				
		600:	dis_data <= 16'hff00;
		900:  dis_data <= 16'h0ff0;
	
		
		1200:	dis_data <= 16'h00ff;
		1500:	dis_data <= 16'hf800;
		endcase 
	end 
	//
	assign vga_hs = hs_r;
	assign vga_vs = vs_r;
	assign vga_red = dis_data[15:11];
	assign vga_green = dis_data[10:5];
	assign vga_blue = dis_data[4:0];
	
endmodule 