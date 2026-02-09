module testbench;
	parameter PARAM_DATA = 10;
	//parameter param_sum = 2;
	parameter param_sum = $clog2(PARAM_DATA+1);
	bit [PARAM_DATA-1:0] data;
	bit [param_sum-1:0] sum;
	summator #(.DATA_W(PARAM_DATA), .POS_W(param_sum)) s (.data(data), .sum(sum));
	
	initial begin 
		data = {PARAM_DATA{1'b1}};
		#1 $display("data: %b, sum: %b", data, sum);
		$finish();
	end
endmodule: testbench

module summator
	#(parameter DATA_W = 10, 
	  parameter POS_W = $clog2(DATA_W+1))
	(input bit [DATA_W-1:0] data, 
	 output bit [POS_W-1:0] sum);
	
	always_comb begin
		sum = 0;
		foreach (data[index_data_bit]) 
			sum += data[index_data_bit];
	end
endmodule: summator