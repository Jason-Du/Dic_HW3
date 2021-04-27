`include "counter.v"
`include "cross_calculator.v"
`include "store_reg.v"
`include "store_reg2.v"
module PSE ( clk,
			reset,
			Xin,
			Yin,
			point_num,
			valid,
			Xout,
			Yout);
			
input        clk;
input        reset;
input [9:0]  Xin;
input [9:0]  Yin;
input [2:0]  point_num;

output reg		 valid;
output reg [9:0] Xout;
output reg [9:0] Yout;


localparam   IDLE       = 3'b000;
localparam   STORE_P    = 3'b001;
localparam   VECTOR_GEN = 3'b010;
localparam   CROSS_CAL  = 3'b011;
localparam   DONE       = 3'b100;
localparam   STORE_ANS  = 3'b101;
integer i;
integer j;

reg         [ 2:0] CS;
reg         [ 2:0] NS;
wire        [ 2:0] point_in_count;
reg                point_in_clear;
reg                point_in_keep;
wire        [2:0]  ier_count;
reg                ier_clear;
reg                ier_keep;
wire        [2:0]  cand_count;
reg                cand_clear;
reg                cand_keep;
reg  signed [10:0] cross_x0;
reg  signed [10:0] cross_y0;
reg  signed [10:0] cross_x1;
reg  signed [10:0] cross_y1;
wire signed [22:0] cross_result1;

reg        ans_write;
reg  [2:0] ans_addr;
reg  [9:0] ans_inx;
reg  [9:0] ans_iny;
wire [9:0] ans_outx;
wire [9:0] ans_outy;
reg        store_write;
reg  [2:0] store_addr;
reg  [9:0] store_inx;
reg  [9:0] store_iny;
wire [9:0] store_outx;
wire [9:0] store_outy;
reg         vector_write;
reg  [ 2:0] vector_addr0;
reg  [ 2:0] vector_addr1;
reg  signed [10:0] vector_inx;
reg  signed [10:0] vector_iny;
wire signed [10:0] vector_outx0;
wire signed [10:0] vector_outy0;
wire signed [10:0] vector_outx1;
wire signed [10:0] vector_outy1;

always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		CS<=IDLE;
	end
	else
	begin
		CS<=NS;
	end
end

assign keep=1'b0;



store_reg ANS(
		.clk(clk),
		.rst(reset),
		.write_enable(ans_write),
		.address(ans_addr),
		.data_inx(ans_inx),
		.data_iny(ans_iny),
		.data_outx(ans_outx),
		.data_outy(ans_outy)
);
store_reg STORE(
		.clk(clk),
		.rst(reset),
		.write_enable(store_write),
		.address(store_addr),
		.data_inx(store_inx),
		.data_iny(store_iny),
		.data_outx(store_outx),
		.data_outy(store_outy)
);
store_reg2 VECTOR(
		.clk(clk),
		.rst(reset),
		.write_enable(vector_write),
		.address0(vector_addr0),
		.address1(vector_addr1),
		.data_inx(vector_inx),
		.data_iny(vector_iny),
		.data_outx0(vector_outx0),
		.data_outy0(vector_outy0),
		.data_outx1(vector_outx1),
		.data_outy1(vector_outy1)
);
counter point_in_counter(
	.clk(clk),
	.rst(reset),
	.count(point_in_count),
	.clear(point_in_clear),
	.keep(point_in_keep)
);
counter cross_cand_counter(
	.clk(clk),
	.rst(reset),
	.count(cand_count),
	.clear(cand_clear),
	.keep(cand_keep)
);
counter cross_ier_counter(
	.clk(clk),
	.rst(reset),
	.count(ier_count),
	.clear(ier_clear),
	.keep(ier_keep)
);
cross_calculator R0(
						.x0(cross_x0),
						.y0(cross_y0),
						.x1(cross_x1),
						.y1(cross_y1),
						.result(cross_result1)
);

always@(*)
begin
	cross_x0=vector_outx0;
	cross_y0=vector_outy0;
	cross_x1=vector_outx1;
	cross_y1=vector_outy1;
	case(CS)
		IDLE:
		begin
			NS=reset?IDLE:STORE_P;
			point_in_clear=reset?1'b1:1'b0;
			ans_write     =reset?1'b0:1'b1;
			ans_addr      =3'd0;
			ans_inx       =Xin;
			ans_iny       =Yin;
			point_in_keep =1'b0;
			cand_keep     =1'b0;
			cand_clear    =1'b1;
			ier_keep      =1'b0;
			ier_clear     =1'b1;
			valid         =1'b0;
			Xout          =10'd0;
			Yout          =10'd0;
			store_write   =1'b1;
			store_addr    =3'd0;
			store_inx     =Xin;
			store_iny     =Yin;
			vector_write  =1'b0;
			vector_addr0  =3'd0;
			vector_addr1  =3'd0;
			vector_inx    =11'd0;
			vector_iny    =11'd0;
		end
		STORE_P:
		begin
			if($unsigned(point_in_count)<($unsigned(point_num)))
			begin
				NS=STORE_P;
				store_write=1'b1;
				store_addr=point_in_count;
				store_inx  =Xin;
				store_iny  =Yin;
				vector_write=1'b0;
				vector_addr0=3'd0;
				vector_addr1=3'd0;
				vector_inx  =11'd0;
				vector_iny  =11'd0;
				point_in_clear=1'b0;
				point_in_keep =1'b0;
			end
			else
			begin
				NS=VECTOR_GEN;
				point_in_clear=1'b1;
				point_in_keep =1'b0;
				store_write=1'b0;
				store_addr =3'd0;
				store_inx  =10'd0;
				store_iny  =10'd0;
				vector_write=1'b0;
				vector_addr0=3'd0;
				vector_addr1=3'd0;
				vector_inx  =11'd0;
				vector_iny  =11'd0;
			end
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			ans_write=1'b0;
			ans_addr    =3'd0;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
		end
		
		VECTOR_GEN:
		begin
			store_write=1'b0;
			store_addr =point_in_count+3'd1;
			store_inx  =10'd0;
			store_iny  =10'd0;
			
			vector_write=1'b1;
			vector_addr0 =point_in_count;
			vector_addr1 =3'd0;
			vector_inx  =$signed({1'b0,store_outx})-$signed({1'b0,ans_outx});
			vector_iny  =$signed({1'b0,store_outy})-$signed({1'b0,ans_outy});
			
			NS=(point_in_count==(point_num-3'd2))?CROSS_CAL:VECTOR_GEN;
			point_in_clear=(point_in_count==(point_num-3'd2))?1'b1:1'b0;
			point_in_keep =1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			ans_write=1'b0;
			ans_addr    =3'd0;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
		end
		CROSS_CAL:
		begin
			valid=1'b0;
			point_in_clear=1'b0;
			point_in_keep=($signed(cross_result1)>$signed(23'd0))?1'b0:1'b1;
			ier_keep=1'b0;
			ier_clear=1'b0;
			cand_keep=1'b1;
			cand_clear=1'b0;
			NS=($unsigned(ier_count[2:0])==($unsigned(point_num)-3'd2) )?STORE_ANS:CROSS_CAL;
			Xout=10'd0;
			Yout=10'd0;
			store_write=1'b0;
			store_addr =3'd0;
			store_inx  =10'd0;
			store_iny  =10'd0;
			vector_write=1'b0;
			vector_addr0=cand_count;
			vector_addr1=ier_count;
			vector_inx  =11'd0;
			vector_iny  =11'd0;
		end
		STORE_ANS:
		begin
			ans_write=1'b1;
			ans_addr    =point_in_count[2:0]+3'd1;
			ans_inx     =store_outx;
			ans_iny     =store_outy;
			store_write=1'b0;
			store_addr =cand_count+16'd1;
			store_inx  =10'd0;
			store_iny  =10'd0;
			vector_write=1'b0;
			vector_addr0=3'd0;
			vector_addr1=3'd0;
			vector_inx  =11'd0;
			vector_iny  =11'd0;
			NS=($unsigned(cand_count[2:0])==($unsigned(point_num)-3'd2) )?DONE:CROSS_CAL;
			point_in_clear=1'b1;
			point_in_keep=1'b0;
			cand_keep =1'b0;
			cand_clear=1'b0;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
		end
		DONE:
		begin
			valid=1'b1;
			point_in_clear=($unsigned(point_in_count)==($unsigned(point_num)-3'd1))?1'b1:1'b0;
			ans_write=1'b0;
			ans_addr    =point_in_count;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
			store_write=1'b0;
			store_addr =3'd0;
			store_inx  =10'd0;
			store_iny  =10'd0;
			vector_write=1'b0;
			vector_addr0=3'd0;
			vector_addr1=3'd0;
			vector_inx  =11'd0;
			vector_iny  =11'd0;
			point_in_keep=1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			Xout=ans_outx;
			Yout=ans_outy;
			NS=($unsigned(point_in_count)==($unsigned(point_num)-3'd1))?IDLE:DONE;
		end
		default:
		begin
			NS=IDLE;
			point_in_clear=1'b1;
			point_in_keep =1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			Xout=10'd0;
			Yout=10'd0;
			valid=1'b0;
			ans_write=1'b0;
			ans_addr    =3'd0;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
			store_write=1'b0;
			store_addr =3'd0;
			store_inx  =10'd0;
			store_iny  =10'd0;
			vector_write=1'b0;
			vector_addr0=3'd0;
			vector_addr1=3'd0;
			vector_inx  =11'd0;
			vector_iny  =11'd0;
		end
	endcase
end
endmodule

