module cross_calculator(
						x0,
						y0,
						x1,
						y1,
						result
);

input [9:0] x0;
input [9:0] y0;
input [9:0] x1;
input [9:0] y1;

output[9:0] result;


assign result=x0*y1+y0*x1;

