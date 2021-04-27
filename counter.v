module counter(
	clk,
	rst,
	count,
	clear,
	keep
);
	input               clk;
	input               rst;
	input               keep;
	input               clear;
	reg        [15:0]   count;
	reg        [15:0]   count_in;
	always@(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			count<=16'd0;
		end
		else
		begin
			count<=count_in;
		end

	end
	always@(*)
	begin
		if(clear)
		begin
			count_in=16'd0;
		end
		else if(keep)
		begin
			count_in=count;
		end
		else
		begin
			count_in=count+16'd1;
		end
	end
endmodule