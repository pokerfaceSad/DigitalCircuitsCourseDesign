library ieee;
use ieee.STD_LOGIC_ARITH.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity ADC0832 is 
	port(
		clk : in std_logic; --clock
		CH0,CH1 : in integer; --analog data entrance
		CS : in std_logic; --CHIP Select
		DI : In std_logic; --Data In
		state_signal : buffer std_logic_vector(3 downto 0); --state Out
		DO : buffer std_logic --Data Out
		--output_index:buffer std_logic_vector(3 downto 0);
		--data_input_model : buffer std_logic_vector(1 downto 0);
		--data : buffer std_logic_vector(7 downto 0)
		);
	
	signal output_index:std_logic_vector(3 downto 0):="0000";
	signal data_input_model : std_logic_vector(1 downto 0);
	signal data : std_logic_vector(7 downto 0);
	signal receive_data : boolean:=false;
	
end ADC0832;

architecture behavior of ADC0832 is
	type state is (Start_Order_Wait,First_DI_Receive,Second_DI_Receive,Data_Transform,Data_Output);
	signal current_state:state;
	signal next_state:state:=Start_Order_Wait;
	signal DI1,DI0:std_logic:='0';
	signal output_order:std_logic;
begin 
	
	synch:process(clk)
	begin
		--change state with clock
		if(clk'event and clk = '0') then
			
			
			current_state <= next_state;

			
		end if;
	end process;
	
	state_trans:process(CS,DI,current_state)
	begin
		state_signal <= "1111";
		--work only if CS is low
		if(CS = '0') then
			case current_state is
				when Start_Order_Wait =>
					
					-- wait the START BIT
					if(DI = '1')then
						state_signal <= "0001";
						next_state <= First_DI_Receive;
					else
						state_signal <= "0010";
						next_state <= Start_Order_Wait;
					end if;
					output_order <= '1';
				when First_DI_Receive =>
					state_signal <= "0011";
					DI1 <= DI;
					next_state <= Second_DI_Receive;
				when Second_DI_Receive =>
					state_signal <= "1000";
					DI0 <= DI;
					data_input_model(1) <= DI1;
					data_input_model(0) <= DI0;
					next_state <= Data_Transform;
				when Data_Transform =>
					state_signal <= "0101";
					case data_input_model is 
						when "00" =>
							data<=CONV_STD_LOGIC_VECTOR(CH0-CH1,8);
						when "01" =>
							data<=CONV_STD_LOGIC_VECTOR(CH1-CH0,8);
						when "10" =>
							data<=CONV_STD_LOGIC_VECTOR(CH0,8);
						when "11" =>
							data<=CONV_STD_LOGIC_VECTOR(CH1,8);
					end case;
					next_state <= Data_Output;
					output_order <= '0';
					
				when Data_Output =>
					state_signal <= "0110";
					output_order <= '0';
					next_state <= Data_Output;							
				when others =>
					state_signal <= "1001";
					next_state <= Start_Order_Wait;
			end case;
		else
			next_state <= Start_Order_Wait;
			
		end if;
			
	end process;
	
	output:process(clk,output_order)
	begin		
			if(clk'event and clk = '0') then
				if(output_order = '0')then
					
						case output_index is 
							when "0000" =>
								DO <= data(7);
								output_index <= output_index + "0001";
							when "0001" =>
								DO <= data(6);
								output_index <= output_index + "0001";
							when "0010" =>
								DO <= data(5);
								output_index <= output_index + "0001";
							when "0011" =>
								DO <= data(4);
								output_index <= output_index + "0001";
							when "0100" =>
								DO <= data(3);
								output_index <= output_index + "0001";
							when "0101" =>
								DO <= data(2);
								output_index <= output_index + "0001";
							when "0110" =>
								DO <= data(1);
								output_index <= output_index + "0001";
							when "0111" =>
								DO <= data(0);
								output_index <= output_index + "0001";
							when "1000" =>
								DO <= data(1);
								output_index <= output_index + "0001";
							when "1001" =>
								DO <= data(2);
								output_index <= output_index + "0001";
							when "1010" =>
								DO <= data(3);
								output_index <= output_index + "0001";
							when "1011" =>
								DO <= data(4);
								output_index <= output_index + "0001";
							when "1100" =>
								DO <= data(5);
								output_index <= output_index + "0001";
							when "1101" =>
								DO <= data(6);
								output_index <= output_index + "0001";
							when "1110" =>
								DO <= data(7);
								output_index <= output_index + "0001";
							when "1111" =>
								DO <= '0';
								output_index<=output_index;
					end case;	
					--output_index <= output_index + '1';
				end if;
			end if;
		
		
	end process;
end behavior;
	