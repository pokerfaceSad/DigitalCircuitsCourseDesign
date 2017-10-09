library ieee;
use ieee.STD_LOGIC_ARITH.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity AD_DA is 
	port(
		clk_1 : in std_logic; --clock
		CH0_1 : in integer; --analog data entrance
		CH1_1 : in integer; --analog data entrance
		CS_1 : in std_logic; --CHIP Select
		DI_1 : in std_logic; --Data In
		state_signal_1 : buffer std_logic_vector(3 downto 0); --state Out
		
		CLKNUM:buffer integer:=0;
		DO_1 : buffer std_logic --Data Out
		);
	--signal DI_1 : std_logic:='0'; --Data In
	--signal CS_1 : std_logic:='1'; --CHIP Select
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
	
begin 
	u1:ADC0832 PORT MAP(clk=>clk_1, CH0=>CH0_1, CH1=>CH1_1, CS=>CS_1,DI=>DI_1,state_signal=>state_signal_1,DO=>DO_1);
	
	
end behavior;
	