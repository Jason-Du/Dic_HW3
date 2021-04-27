module store_reg2(
		clk,
		rst,
		write_enable,
		address0,
		address1,
		data_inx,
		data_iny,
		data_outx0,
		data_outy0,
		data_outx1,
		data_outy1
);
input	      clk;
input	      rst;
input	      write_enable;
input 	[2:0] address0;
input 	[2:0] address1;
input 	[10:0] data_inx;
input 	[10:0] data_iny;
output  [10:0] data_outx0;
output  [10:0] data_outy0;
output  [10:0] data_outx1;
output  [10:0] data_outy1;
reg [10:0] ANS_REG [5:0][1:0];
integer i;
integer j;
always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		for(i=0;i<6;i=i+1)
		begin
			for(j=0;j<2;j=j+1)
			begin
				ANS_REG[i][j]<=11'd0;
			end
		end
	end
	else
	begin
		if(write_enable)
		begin
			ANS_REG[address0][0]<=data_inx;
			ANS_REG[address0][1]<=data_iny;
		end
		else
		begin
			for(i=0;i<6;i=i+1)
			begin
				for(j=0;j<2;j=j+1)
				begin
					ANS_REG[i][j]<=ANS_REG[i][j];
				end
			end
		end
	end
end

assign data_outx0=ANS_REG[address0][0];
assign data_outy0=ANS_REG[address0][1];
assign data_outx1=ANS_REG[address1][0];
assign data_outy1=ANS_REG[address1][1];


endmodule


