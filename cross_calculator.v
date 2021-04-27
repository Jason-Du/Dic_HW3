module cross_calculator(
						x0,
						y0,
						x1,
						y1,
						result
);

input signed  [10:0] x0;
input signed  [10:0] y0;
input signed  [10:0] x1;
input signed  [10:0] y1;

output signed [22:0] result;
wire   signed [21:0] Minute; 
wire   signed [21:0] Minus;

assign Minute=$signed(x0)*$signed(y1);
assign Minus =$signed(y0)*$signed(x1);
assign result=$signed(Minute)-$signed(Minus);
endmodule

