module vga_test 
(
	input vga_clk,
	input rst_n,
	output VGA_HSYNC,
	output VGA_VSYNC,
	output [15:0] VGAD
);
vga0 uut (
   .rst_n(rst_n),
	.vga_clk(vga_clk),
	.vga_hs(VGA_HSYNC),
	.vga_vs(VGA_VSYNC),
	.vga_red(VGAD[15:11]),
	.vga_green(VGAD[10:5]),
	.vga_blue(VGAD[4:0])
);
//
endmodule 