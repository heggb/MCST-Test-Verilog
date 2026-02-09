module lifo
	#(parameter LIFO_SIZE = 6, 
	  parameter DATA_W = 10)
	(input bit clock, reset, 
	 input read, write,
	 input bit [DATA_W-1:0] datain,
	 output bit full, val,
	 output bit [DATA_W-1:0] dataout);
	 
	parameter SIZE_COUNT = $clog2(LIFO_SIZE+1);
	parameter SIZE_PTR = $clog2(LIFO_SIZE);
	 
	bit [LIFO_SIZE-1:0][DATA_W-1:0] Q ;
	
	output bit [SIZE_COUNT-1:0] count;
	output bit [SIZE_PTR-1:0] endPtr;
	
	bit write_r, read_r;
	bit empty;
	
	assign empty = (count == 0),
		full = (count == LIFO_SIZE);
		
	always_ff @(posedge clock, posedge reset) begin
		if (reset) begin
			write_r <= 0;
			read_r <= 0;
		end
		else begin
			if (write_r ^ write) write_r <= write;
			else if (write_r && write) write_r<= 0;
			if (read_r ^ read) read_r <= read;
		end
	end
	
	always_ff @(posedge clock, posedge reset)
	begin
		if (reset) begin
			count <= 0;
			val <= 0;
			endPtr <= 0; 
		end
		else begin
			val <= 0;
			if (write_r && (!full)) begin
				Q[endPtr] <= datain;
				endPtr <= endPtr + 1; 
				count <= count + 1;
			end 
			else if (read_r && ~write && (!empty)) begin
				dataout <= Q[endPtr-1];
				val <= 1;
				if ((read_r ^ read)&& (!empty)) begin
					dataout <= 0;
					endPtr <= endPtr-1;
					count <= count - 1;
					
				end
			end
		end
	end
	
endmodule: lifo