module store_reg(
		clk,
		rst,
		write_enable,
		address,
		data_inx,
		data_iny,
		data_outx,
		data_outy
);
input	      clk;
input	      rst;
input	      write_enable;
input 	[2:0] address;
input 	[9:0] data_inx;
input 	[9:0] data_iny;
output  [9:0] data_outx;
output  [9:0] data_outy;

reg [9:0] ANS_REG [5:0][1:0];
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
				ANS_REG[i][j]<=10'd0;
			end
		end
	end
	else
	begin
		if(write_enable)
		begin
			ANS_REG[address][0]<=data_inx;
			ANS_REG[address][1]<=data_iny;
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

assign data_outx=ANS_REG[address][0];
assign data_outy=ANS_REG[address][1];


endmodule


