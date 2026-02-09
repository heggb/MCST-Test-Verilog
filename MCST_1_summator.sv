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