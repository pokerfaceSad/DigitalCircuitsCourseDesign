library ieee;
use ieee.STD_LOGIC_ARITH.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity AD_DA is 
	port(
		-- port of ADC0832
		
		clk_1 : in std_logic; --clock
		CH0_1 : in integer; --analog data entrance
		CH1_1 : in integer; --analog data entrance
		--CS_1 : in std_logic; --CHIP Select
		--DI_1 : in std_logic; --Data In
		CS_output : out std_logic;
		DI_output : out std_logic;
		state_signal_1 : buffer std_logic_vector(3 downto 0); --state Out
		
		CLKNUM:buffer integer:=0;
		DO_1 : buffer std_logic; --Data Out
		
		DataA_output: out std_logic_vector(7 downto 0);
		DataB_output: out std_logic_vector(7 downto 0);
		
		COUNT1_output: out integer;
		COUNT2_output: out integer;
		COUNT3_output: out integer;
		
		Parallel_Data:buffer integer;
		
		--port of DAC0832
		D : out std_logic_vector(7 downto 0);
		WR1 : out std_logic;
		XFER : out std_logic;
		WR2 : out std_logic
		
		
		);
	signal DI_1 : std_logic:='0'; --Data In
	signal CS_1 : std_logic:='1'; --CHIP Select
	--signal CH0_1: integer:=12; --analog data entrance
	--signal CH1_1 : integer:=16; --analog data entrance
end AD_DA;

architecture behavior of AD_DA is
	COMPONENT ADC0832 
		port(
		clk : in std_logic; --clock
		CH0,CH1 : in integer; --analog data entrance
		CS : in std_logic; --CHIP Select
		DI : In std_logic; --Data In
		state_signal : buffer std_logic_vector(3 downto 0); --state Out
		DO : buffer std_logic --Data Out
		);
	END COMPONENT ADC0832;
	
	type state is (IDLE,ADC_START,DATA_RECEIVE,DATA_CHECK,DAC_START);
	signal current_state:state;
	signal next_state:state;
	signal DataA : std_logic_vector(7 downto 0);
	signal DataB : std_logic_vector(7 downto 0);
	signal receive_order:std_logic;
	signal start_order:std_logic;
	signal temp:integer;
	signal Serial_Data:std_logic_vector(7 downto 0);
	shared VARIABLE COUNT1:INTEGER:=0;
	shared VARIABLE COUNT2:INTEGER:=0;
	shared VARIABLE COUNT3:INTEGER:=0;
begin 
	u1:ADC0832 PORT MAP(clk=>clk_1, CH0=>CH0_1, CH1=>CH1_1, CS=>CS_1,DI=>DI_1,state_signal=>state_signal_1,DO=>DO_1);
	
	counter : process(clk_1)
	begin 
		if(clk_1'event and clk_1 = '0') then
			CLKNUM <= CLKNUM + 1;
			current_state <= next_state;
		end if;
	end process;
	
	controller : process(CLKNUM,current_state)
	begin
		
			case current_state is 
				when IDLE =>
					CS_1 <= '0';
					WR1 <= '1';
					receive_order <= '0';
					start_order  <= '0';
					--DI_1 <= '0';
					next_state <= ADC_START;					
				when ADC_START => 
					if(COUNT2 < 4) then
						start_order <= '1';
						next_state <= ADC_START;
					else 
						start_order <= '0';
						next_state <= DATA_RECEIVE;
					end if;
				
				when DATA_RECEIVE =>
					if(COUNT1 < 15) then
						receive_order <= '1';
						next_state <= DATA_RECEIVE;
					else
						receive_order <= '0';
						next_state <= DATA_CHECK;
					end if;
				when DATA_CHECK =>	
					--check if the data is correct
					if(DataA = DataB) then
						temp <= CONV_INTEGER(DataA);
						Parallel_Data <= (255 - temp)/2;
						next_state <= DAC_START;
					else
						Parallel_Data <= -1;
						
						next_state <= DAC_START;
					end if;
					Serial_Data <= CONV_STD_LOGIC_VECTOR((255 - temp)/2,8);
				when DAC_START =>
					D <= Serial_Data;
					WR1 <= '0';
					WR2 <= '0';
					XFER <= '0';
					next_state <= DAC_START;
				when others => 
					next_state <= IDLE;
					
			end case;
			DataA_output <= DataA;
			DataB_output <= DataB;
			COUNT1_output <= COUNT1;
			COUNT2_output <= COUNT2;
			COUNT3_output <= COUNT3;
			CS_output <= CS_1;
			DI_output <= DI_1;
			--Parallel_Data <= CONV_INTEGER(DataA); 
	end process;
	
	
	
	adc_work : process(start_order,clk_1)
	begin
		if(start_order = '1') then
			if(clk_1'event and clk_1 = '0') then
					if(COUNT2 = 0) then
						--START_BIT
						--CS_1 <= '0';
						DI_1 <= '1';
					end if;
					if(COUNT2 = 1) then
						--First DI
						--CS_1 <= '0';
						DI_1 <= '0';
					end if;
					if(COUNT2 = 2) then
						--Second DI
						--CS_1 <= '0';
						DI_1 <= '1';
					end if;
					if(COUNT2 = 3) then
						--Transform
						DI_1 <= '0';
					end if;
					COUNT2:=COUNT2+1;
			end if;
		end if;		
	end process;
	
	receive : process(receive_order,clk_1)
	begin
		if(receive_order = '1') then
			if(clk_1'event and clk_1='0') then
				if(COUNT1<7) then
					DataA <= DataA(6 downto 0) & DO_1;
				end if;
				if(COUNT1=7) then
					DataA <= DataA(6 downto 0) & DO_1;
					DataB <= DO_1 & DataB(7 downto 1);
				end if;
				if(COUNT1<15 and COUNT1 >7) then
					DataB <= DO_1 & DataB(7 downto 1);
				end if;
				COUNT1:=COUNT1+1;
			end if;
		end if;
	end process;
end behavior;
	