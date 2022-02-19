// make by ZHZUHAI.EE
// create at 13.00 ,5-6,2019
// function point :
//                  1. good  -> 20 type, display on cd1,cd2   [done]
//                  2. money -> 5 type, display on cd5,cd6    [done] 
//                  3. support return     
module salem(
    input              clk      ,
    input              rstn     ,
    input [4:0]        swb      ,
    input [4:0]        mty      ,// money type
    input              get      ,// get money
    output reg         alarm    ,// less than 5 
    output reg [7:0]   gm_c     ,
    output reg [7:0]   im_c     ,
    output reg [7:0]   res_c    ,
    output[7:0]        dbg_good_price
);
  //  reg [7:0]       gm_c        ;// good label [bcd]
  //  reg [7:0]       im_c        ;// input money [bcd]
    reg [5:0]       residue     ;
  //  reg [7:0]       res_c       ; // residue money [bcd]
    wire [7:0]      item[0:19]  ;
    reg [2:0]       cst         ;
    reg [2:0]       nst         ;
    reg [4:0]       cnt         ;// residue good
    parameter  IDLE         = 3'b000;
    parameter  GMONEY       = 3'b001;
    parameter  SHOPPING     = 3'b010;
    parameter  BACK         = 3'b100;
    parameter  RETURN       = 3'b111; // can not buy
    // table of item

    assign item[0]         = 8'h01;
    assign item[1]         = 8'h02;
    assign item[2]         = 8'h02;
    assign item[3]         = 8'h03;
    assign item[4]         = 8'h03;
    assign item[5]         = 8'h04;
    assign item[6]         = 8'h08;
    assign item[7]         = 8'h09;
    assign item[8]         = 8'h12;
    assign item[9]         = 8'h18;
    assign item[10]         = 8'h10;
    assign item[11]         = 8'h10;
    assign item[12]         = 8'h12;
    assign item[13]         = 8'h12;
    assign item[14]         = 8'h15;
    assign item[15]         = 8'h15;
    assign item[16]         = 8'h20;
    assign item[17]         = 8'h25;
    assign item[18]         = 8'h30;
    assign item[19]         = 8'h30;
    //
    assign dbg_good_price = item[swb];
    // good type display (label)
    always @(posedge clk or negedge rstn) begin
        if(rstn == 1'b0)
            gm_c      <=  8'h00   ;
        else if(swb < 5'd10)
            gm_c      <=  {3'b000,swb}     ;
        else if(swb < 5'd20) begin 
            gm_c[3:0]      <=  swb - 5'd10 ;
            gm_c[7:4]      <=  4'h1;
        end 
    end
    // input money display
    always @(posedge clk or negedge rstn) begin
        if(rstn == 1'b0)
            im_c      <=  8'h00   ;
        else begin case (mty)
                5'h1    :       im_c      <=  8'h01   ;
                5'h2    :       im_c      <=  8'h05   ;
                5'h4    :       im_c      <=  8'h10   ;
                5'h8    :       im_c      <=  8'h20   ;
                5'h10   :       im_c      <=  8'h50   ;
                default :       im_c      <=  8'h00   ;
             endcase
        end  
    end
    // =================  FSM === 1 ================================
    always @(posedge clk or negedge rstn) begin
        if(rstn == 1'b0)
            cst     <=  IDLE;
        else 
            cst     <=  nst;
    end
   // =================  FSM === 2 ================================
    always @(posedge clk or negedge rstn) begin
        if(rstn == 1'b0) begin 
            residue     <= 8'h00;
            res_c       <= 'd0;
            nst         <= IDLE ;   
        end else case(cst)
            IDLE:
                if(mty == 5'h00)
                    nst     <=   IDLE;
                else 
                    nst     <=    GMONEY;
            GMONEY: 
                if(im_c > item[swb] || im_c == item[swb]) 
                    nst     <=    SHOPPING;
                else
                    nst     <=   RETURN; // less than cannot shopping
            SHOPPING:begin if(im_c > item[swb] || im_c == item[swb]) 
                                residue <=  (im_c[7:4] -item[swb][7:4])*4'ha + im_c[3:0] - item[swb][3:0];
                    nst     <=   BACK;
            end                              
            BACK:   begin 
                        if(residue < 5'd10)
                            res_c      <=  residue     ;
                        else if(residue < 5'd20) begin 
                            res_c[3:0]      <=  residue - 5'd10 ;
                            res_c[7:4]      <=  4'h1;
                        end  else if(residue < 5'd30)begin 
                            res_c[3:0]      <=  residue - 5'd20 ;
                            res_c[7:4]      <=  4'h2;
                        end  else if(residue < 5'd40)begin 
                            res_c[3:0]      <=  residue - 5'd30 ;
                            res_c[7:4]      <=  4'h3;
                        end  else if(residue < 5'd50)begin 
                            res_c[3:0]      <=  residue - 5'd40 ;
                            res_c[7:4]      <=  4'h4;
                        end 
                    nst     <=   IDLE;
            end
            RETURN:   begin 
                       if(get) begin 
                        res_c   <= 8'h00   ;
                        nst     <= IDLE  ;
                       end else begin 
                            res_c   <=  im_c    ;
                            nst     <=  GMONEY  ;
                        end 
            end  
        endcase
    end
    // alarm when number of goods is less than 5
    always @(posedge clk or negedge rstn) begin
        if(rstn == 1'b0) 
            cnt <= 5'd19;
        else if(cst == SHOPPING && nst == BACK)
            cnt <= cnt - 1'b1;
    end
     always @(posedge clk or negedge rstn) begin
        if(rstn == 1'b0) 
            alarm   <=  1'b0;
        else if(cnt < 5'd5)
            alarm   <= 1'b1;
        else 
            alarm   <=  1'b0;
    end

endmodule 

// ===============================================
// ===============================================
module bcd2seg(SW,SEG);
  input [3:0]               SW;
  output reg[6:0]           SEG;
  parameter	cd0	= 7'b1000000,
            cd1	= 7'b1111001,
            cd2	= 7'b0100100,
            cd3	= 7'b0110000,
            cd4	= 7'b0011001,
            cd5	= 7'b0010010,
            cd6	= 7'b0000010,
            cd7	= 7'b1111000,
            cd8	= 7'b0000000,
            cd9	= 7'b0010000,
            cda	= 7'b0001000,
            cdb	= 7'b0000011,
            cdc	= 7'b1000110,
            cdd	= 7'b0100001,
            cde	= 7'b0000110,
            cdf	= 7'b0001110;
  always @(*)
  case(SW[3:0])
    4'h0: SEG[6:0] = cd0;
    4'h1: SEG[6:0] = cd1;
    4'h2: SEG[6:0] = cd2;
    4'h3: SEG[6:0] = cd3;
    4'h4: SEG[6:0] = cd4;
    4'h5: SEG[6:0] = cd5;
    4'h6: SEG[6:0] = cd6;
    4'h7: SEG[6:0] = cd7;
    4'h8: SEG[6:0] = cd8;
    4'h9: SEG[6:0] = cd9;
    4'ha: SEG[6:0] = cda;
    4'hb: SEG[6:0] = cdb;
    4'hc: SEG[6:0] = cdc;
    4'hd: SEG[6:0] = cdd;
    4'he: SEG[6:0] = cde;
    4'hf: SEG[6:0] = cdf;
    default:SEG[6:0] = cd0;
  endcase
endmodule
