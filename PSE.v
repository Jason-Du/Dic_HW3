`include "counter.v"
`include "cross_calculator.v"
`include "store_reg.v"
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

reg  signed [  9:0] STORE_REG     [5:0][1:0];
reg  signed [  9:0] STORE_REG_IN  [5:0][1:0];
reg  signed [ 10:0] VECTOR_REG    [4:0][1:0];
reg  signed [ 10:0] VECTOR_REG_IN [4:0][1:0];


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

always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		for(i=0;i<6;i=i+1)
		begin
			for(j=0;j<2;j=j+1)
			begin
				STORE_REG[i][j]<=10'd0;
			end
		end
	end
	else
	begin
		for(i=0;i<6;i=i+1)
		begin
			for(j=0;j<2;j=j+1)
			begin
				STORE_REG[i][j]<=STORE_REG_IN[i][j];
			end
		end
	end
end

always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		for(i=0;i<5;i=i+1)
		begin
			for(j=0;j<2;j=j+1)
			begin
				VECTOR_REG[i][j]<=10'd0;
			end
		end
	end
	else
	begin
		for(i=0;i<5;i=i+1)
		begin
			for(j=0;j<2;j=j+1)
			begin
				VECTOR_REG[i][j]<=VECTOR_REG_IN[i][j];
			end
		end
	end
end
assign keep=1'b0;
reg        ans_write;
reg  [2:0] ans_addr;
reg  [9:0] ans_inx;
reg  [9:0] ans_iny;
wire [9:0] ans_outx;
wire [9:0] ans_outy;
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

	case(CS)
		IDLE:
		begin
			NS=reset?IDLE:STORE_P;
			point_in_clear=reset?1'b1:1'b0;
			ans_write=reset?1'b0:1'b1;
			ans_addr    =3'd0;
			ans_inx     =Xin;
			ans_iny     =Yin;
			point_in_keep =1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			cross_x1=11'd0;
			cross_y1=11'd0;
			cross_x0=11'd0;
			cross_y0=11'd0;
			STORE_REG_IN[0][0]=Xin;
			STORE_REG_IN[0][1]=Yin;
			for(i=1;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(i=0;i<5;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		STORE_P:
		begin
			if($unsigned(point_in_count)<($unsigned(point_num)))
			begin
				NS=STORE_P;
				STORE_REG_IN[point_in_count[2:0]][0]=Xin;
				STORE_REG_IN[point_in_count[2:0]][1]=Yin;
				point_in_clear=1'b0;
				point_in_keep =1'b0;
			end
			else
			begin
				NS=VECTOR_GEN;
				point_in_clear=1'b1;
				point_in_keep =1'b0;
				for(i=0;i<4;i=i+1)
				begin
					for(j=0;j<2;j=j+1)
					begin
						STORE_REG_IN[i][j]<=STORE_REG[i][j];
					end
				end
			end
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			cross_x1=11'd0;
			cross_y1=11'd0;
			cross_x0=11'd0;
			cross_y0=11'd0;
			ans_write=1'b0;
			ans_addr    =3'd0;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
			for(i=0;i<5;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		
		VECTOR_GEN:
		begin
			for(i=0;i<point_num-1;i=i+1)
			begin
				VECTOR_REG_IN[i][0]=$signed({1'b0,STORE_REG[i+1][0]})-$signed({1'b0,STORE_REG[0][0]});
				VECTOR_REG_IN[i][1]=$signed({1'b0,STORE_REG[i+1][1]})-$signed({1'b0,STORE_REG[0][1]});
			end
			NS=CROSS_CAL;
			point_in_clear=1'b1;
			point_in_keep =1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			cross_x1=11'd0;
			cross_y1=11'd0;
			cross_x0=11'd0;
			cross_y0=11'd0;
			ans_write=1'b0;
			ans_addr    =3'd0;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
			for(i=0;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
		end
		CROSS_CAL:
		begin
			case(cand_count)
				3'b000:
				begin
					cross_x0=VECTOR_REG[0][0];
					cross_y0=VECTOR_REG[0][1];
				end
				3'b001:
				begin
					cross_x0=VECTOR_REG[1][0];
					cross_y0=VECTOR_REG[1][1];
				end
				3'b010:
				begin
					cross_x0=VECTOR_REG[2][0];
					cross_y0=VECTOR_REG[2][1];
				end
				3'b011:
				begin
					cross_x0=VECTOR_REG[3][0];
					cross_y0=VECTOR_REG[3][1];
				end
				3'b100:
				begin
					cross_x0=VECTOR_REG[4][0];
					cross_y0=VECTOR_REG[4][1];
				end
				default:
				begin
					cross_x0=11'd0;
					cross_y0=11'd0;
				end
			endcase
			case(ier_count)
				3'b000:
				begin
					cross_x1=VECTOR_REG[0][0];
					cross_y1=VECTOR_REG[0][1];
				end
				3'b001:
				begin
					cross_x1=VECTOR_REG[1][0];
					cross_y1=VECTOR_REG[1][1];
				end
				3'b010:
				begin
					cross_x1=VECTOR_REG[2][0];
					cross_y1=VECTOR_REG[2][1];
				end
				3'b011:
				begin
					cross_x1=VECTOR_REG[3][0];
					cross_y1=VECTOR_REG[3][1];
				end
				3'b100:
				begin
					cross_x1=VECTOR_REG[4][0];
					cross_y1=VECTOR_REG[4][1];
				end
				default:
				begin
					cross_x1=11'd0;
					cross_y1=11'd0;
				end
			endcase
			for(i=0;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(i=0;i<5;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end

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
		end
		STORE_ANS:
		begin
			ans_write=1'b1;
			ans_addr    =point_in_count[2:0]+3'd1;
			ans_inx     =STORE_REG[cand_count+16'd1][0];
			ans_iny     =STORE_REG[cand_count+16'd1][1];
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
			cross_x1=11'd0;
			cross_y1=11'd0;
			cross_x0=11'd0;
			cross_y0=11'd0;
			for(i=0;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(i=0;i<5;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		DONE:
		begin
			valid=1'b1;
			point_in_clear=($unsigned(point_in_count)==($unsigned(point_num)-3'd1))?1'b1:1'b0;
			ans_write=1'b0;
			ans_addr    =point_in_count;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
			point_in_keep=1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			Xout=ans_outx;
			Yout=ans_outy;
			NS=($unsigned(point_in_count)==($unsigned(point_num)-3'd1))?IDLE:DONE;
			cross_x1=11'd0;
			cross_y1=11'd0;
			cross_x0=11'd0;
			cross_y0=11'd0;
			for(i=0;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(i=0;i<5;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
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
			cross_x1=11'd0;
			cross_y1=11'd0;
			cross_x0=11'd0;
			cross_y0=11'd0;
			ans_write=1'b0;
			ans_addr    =3'd0;
			ans_inx     =10'd0;
			ans_iny     =10'd0;
			for(i=0;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(i=0;i<5;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
	endcase
end

endmodule

