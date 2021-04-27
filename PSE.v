`include "counter.v"
`include "cross_calculator.v"
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

output 		 valid;
output [9:0] Xout;
output [9:0] Yout;





localparam   IDLE       = 3'b000;
localparam   STORE_P    = 3'b001;
localparam   VECTOR_GEN = 3'b010;
localparam   CROSS_CAL  = 3'b011;
localparam   DONE       = 3'b100;


reg   [ 9:0] STORE_REG     [5:0][1:0];
reg   [ 9:0] STORE_REG_IN  [5:0][1:0];
reg   [ 9:0] ANS_REG       [5:0][1:0];
reg   [ 9:0] ANS_REG_IN    [5:0][1:0];
reg   [ 9:0] VECTOR_REG    [4:0][1:0];
reg   [ 9:0] VECTOR_REG_IN [4:0][1:0];


wire   [2:0] CS;
wire   [2:0] NS;
wire  [15:0] point_in_count;
reg          point_in_clear;
wire         point_in_keep;
wire  [15:0] ier_count;
reg          ier_clear;
reg          ier_keep;
wire  [15:0] cand_count;
reg          cand_clear;
reg          cand_keep;
reg   [ 9:0] cross_x0;
reg   [ 9:0] cross_y0;
reg   [ 9:0] cross_x1;
reg   [ 9:0] cross_y1;
wire  [ 9:0] cross_result1;
//C[0][0][3:0] = 4b’0010;     // 設定位置[0][0]的低4bit為0010
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
		for(int i=0;i<6;i++)
		begin
			for(int j=0;j<2;j++)
			begin
				STORE_REG[i][j]<=10'b0;
			end
		end
		CS<=IDLE;
	end
	else
	begin
		CS<=NS;
		for(int i=0;i<6;i++)
		begin
			for(int j=0;j<2;j++)
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
		for(int i=0;i<5;i++)
		begin
			for(int j=0;j<2;j++)
			begin
				VECTOR_REG[i][j]<=10'b0;
			end
		end
	end
	else
	begin
		for(int i=0;i<5;i++)
		begin
			for(int j=0;j<2;j++)
			begin
				VECTOR_REG[i][j]<=VECTOR_REG_IN[i][j];
			end
		end
	end
end
always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		for(int i=0;i<5;i++)
		begin
			for(int j=0;j<2;j++)
			begin
				ANS_REG[i][j]<=10'b0;
			end
		end
	end
	else
	begin
		for(int i=0;i<5;i++)
		begin
			for(int j=0;j<2;j++)
			begin
				ANS_REG[i][j]<=ANS_REG_IN[i][j];
			end
		end
	end
end
assign keep=1'b0;
assign ANS_REG_IN[0][0]=STORE_REG[0][0];
assign ANS_REG_IN[0][1]=STORE_REG[0][1];
counter point_in__counter(
	.clk(clk),
	.rst(rst),
	.count(point_in_count),
	.clear(point_in_clear),
	.keep(point_in_keep)
);
counter cross_cand_counter(
	.clk(clk),
	.rst(rst),
	.count(cand_count),
	.clear(cand_clear),
	.keep(cand_keep)
);
counter cross_ier_counter(
	.clk(clk),
	.rst(rst),
	.count(ier_count),
	.clear(ier_clear),
	.keep(ier_keep)
);
wire [9:0] cross_result1;
/*
cross_calculator R0(
						.x0(VECTOR_REG[0][0]),
						.y0(VECTOR_REG[0][1]),
						.x1(VECTOR_REG[1][0])),
						.y1(VECTOR_REG[1][1])),
						.result(cross_result1)
);
*/
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
	begin
		IDLE:
		begin
			NS=reset?IDLE:STORE_P;
			point_in_clear=1'b1;
			point_in_keep =1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			cross_x1=10'd0;
			cross_y1=10'd0;
			cross_x0=10'd0;
			cross_y0=10'd0;
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					ANS_REG_IN[i][j]=ANS_REG[i][j];
				end
			end
			for(int i=0;i<5;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		STORE_P:
		begin
			if(count<point_num)
			begin
				NS=STORE_P;
				STORE_REG_IN[point_in_count][0]=Xin;
				STORE_REG_IN[point_in_count][1]=Yin;
				point_in_clear=1'b0;
				point_in_keep =1'b0;
			end
			else
			begin
				NS=VECTOR_GEN;
				point_in_clear=1'b1;
				point_in_keep =1'b0;
				for(int i=0;i<4;i++)
				begin
					for(int j=0;j<2;j++)
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
			cross_x1=10'd0;
			cross_y1=10'd0;
			cross_x0=10'd0;
			cross_y0=10'd0;
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					ANS_REG_IN[i][j]=ANS_REG[i][j];
				end
			end
			for(int i=0;i<5;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		VECTOR_GEN:
		begin
			for(int i=0;i<point_num-1;i++)
			begin
				VECTOR_REG_IN[i][0]=STORE_REG[i+1][0]-STORE_REG[0][0];
				VECTOR_REG_IN[i][1]=STORE_REG[i+1][1]-STORE_REG[0][1];
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
			cross_x1=10'd0;
			cross_y1=10'd0;
			cross_x0=10'd0;
			cross_y0=10'd0;
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					ANS_REG_IN[i][j]=ANS_REG[i][j];
				end
			end
		end
		CROSS_CAL:
		begin
			cand_keep=(ier_count[2:0]-point_num-3'd1)==3'b000)?1'b1:1'b0;
			cand_clear=((cand_count[2:0]-point_num)==3'b000)?1'b0:1'b1;
			valid=1'b0;
			point_in_clear=1'b0;
			point_in_keep=(cross_result1>10'd0)?1'b0:1'b1;
			ier_keep=1'b0;
			ier_clear=((ier_count[2:0]-point_num-3'd1)==3'b000)?1'b0:1'b1;
			NS=(((cand_count[2:0]-point_num-3'd1)==3'b000))?STORE_ANS:CROSS_CAL;
			Xout=10'd0;
			Yout=10'd0;
			case(cand_count)
			begin
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
					cross_x0=10'd0;
					cross_y0=10'd0;
				end
			end
			case(ier_count)
			begin
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
					cross_x1=10'd0;
					cross_y1=10'd0;
				end
			end
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					ANS_REG_IN[i][j]=ANS_REG[i][j];
				end
			end
			for(int i=0;i<5;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		STORE_ANS:
		begin
			ANS_REG_IN[point_in_count+16'd1][0]=STORE_REG_IN[ier_count+3'd1][0];
			ANS_REG_IN[point_in_count+16'd1][1]=STORE_REG_IN[ier_count+3'd1][1];
			NS=(((ier_count[2:0]-point_num-3'd1)==3'b000))?CROSS_CAL:DONE;
			point_in_clear=1'b1;
			point_in_keep=1'b0;
			cand_keep =1'b1;
			cand_clear=1'b0;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			valid=1'b0;
			Xout=10'd0;
			Yout=10'd0;
			cross_x1=10'd0;
			cross_y1=10'd0;
			cross_x0=10'd0;
			cross_y0=10'd0;
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(int i=0;i<5;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
		DONE:
		begin
			valid=1'b1;
			point_in_clear=1'b0;
			point_in_keep=1'b0;
			cand_keep =1'b0;
			cand_clear=1'b1;
			ier_keep  =1'b0;
			ier_clear =1'b1;
			Xout=ANS_REG[point_in_count][0];
			Yout=ANS_REG[point_in_count][1];
			NS=(point_in_count==point_num-3'd1)?IDLE:DONE;
			cross_x1=10'd0;
			cross_y1=10'd0;
			cross_x0=10'd0;
			cross_y0=10'd0;
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					ANS_REG_IN[i][j]=ANS_REG[i][j];
				end
			end
			for(int i=0;i<5;i++)
			begin
				for(int j=0;j<2;j++)
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
			cross_x1=10'd0;
			cross_y1=10'd0;
			cross_x0=10'd0;
			cross_y0=10'd0;
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					STORE_REG_IN[i][j]=STORE_REG[i][j];
				end
			end
			for(int i=0;i<6;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					ANS_REG_IN[i][j]=ANS_REG[i][j];
				end
			end
			for(int i=0;i<5;i++)
			begin
				for(int j=0;j<2;j++)
				begin
					VECTOR_REG[i][j]=VECTOR_REG_IN[i][j];
				end
			end
		end
	end
end
endmodule

