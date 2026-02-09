module testbench;

	parameter PARAM_DATA_W = 10;
	parameter PARAM_ARRAY_SIZE = 6;
	
	bit clock = 0, reset = 1;
	bit clock_p = 0, reset_p = 1;
	bit clock_c = 0, reset_c = 1; 
	
	bit read, write, empty;
	bit full, val;
	
	bit [PARAM_DATA_W-1:0] dataout, datain;
	
	bit check = 0;
	bit sync = 0;
	
	lifo #(.LIFO_SIZE(PARAM_ARRAY_SIZE), .DATA_W(PARAM_DATA_W)) lf (.*);
	
	initial #2 
	begin: set_system
		reset = 0;
		reset_p = 0;
		reset_c = 0;
	end: set_system
	
	always #5 clock = ~clock;
	always #8 clock_c = ~clock_c;
	always #9 clock_p = ~clock_p;
	
	always #1 sync = clock_p && clock_c;
	
	initial begin
		#10;
		WriteData(8'h11);
		WriteData(8'h22);
		
		#10;
		ReadData;
		
		#10
		WriteData(8'h33);
		
		#10;
		ReadData;
		ReadData;
		
		#10;
		WriteData(8'hAA);
		WriteData(8'hBB);
		WriteData(8'hCC);
		WriteData(8'hDD);
		WriteData(8'hEE);
		WriteData(8'hFF);
		WriteData(8'hAB);
		WriteData(8'hBC);
		
		#10;
		ReadData;
		ReadData;
		ReadData;
		ReadData;
		ReadData;
		ReadData;
		
		
		#10;
		WriteData(8'h44);
		
		#10;
		WriteReadData(8'h55);
		
		#10;
		WriteData(8'h66);
		
		#10;
		ReadData;
		ReadData;
		ReadData;
		ReadData;
		
		#1 $finish;
	end
	
	task WriteData (input [7:0] data); //Работа интерфейса аппартаного потока производителя
	  begin: WriteData
		if (~reset_p) begin
			@(posedge clock_p);
			if (full) 
				$display("Buffer is full");
			else begin
				write <= 1;
				datain <= data;
				$display("Write data = %h", data);	
			end
			@(posedge clock_p) write <= 0;
		end else 
			$display("Producer is disabled");
		
	  end: WriteData
	endtask
	
	task ReadData; //Работа интерфейса аппартаного потока потребителя
	  begin: ReadData
		if (~reset_c) begin
			@(posedge clock_c);
			read <= 1;
			@(posedge val) $display("ReadData data = %h", dataout);
			@(posedge clock_c);
			read <= 0;
		end else 
			$display("Consumer is disabled");
	  end: ReadData
	endtask
	
	task WriteReadData (input [7:0] data); //Случай синхронного срабатывания сигнала записи и чтения
	  begin
		if (~reset_p && ~reset_c) begin
			@(posedge sync);
			if (full) 
				$display("Buffer is full");
			else begin
				read <= 1;
				write <= 1;
				datain <= data;
				$display("EnterData data = %h, Last dataout = %h", data, dataout);
			end
			repeat (2) begin
				@(posedge clock_p, posedge clock_c) begin 
					if (clock_p) write <= 0;
					else if (clock_c) read <= 0;
				end
			end
		end
		
	  end
	endtask
	
	initial #100000 $finish;
	
endmodule: testbench


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