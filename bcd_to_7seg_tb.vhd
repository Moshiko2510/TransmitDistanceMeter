library ieee;
use ieee.std_logic_1164.all;

entity bcd_to_7seg_tb is

end bcd_to_7seg_tb;


architecture tb of bcd_to_7seg_tb is

	signal s_bcd_in : INTEGER RANGE 0 to 9;
	signal s_d_out : std_logic_vector(6 DOWNTO 0);
	signal s_run : std_logic:='1';
	
Component bcd_to_7seg
	PORT(bcd_in : In INTEGER RANGE 0 to 9;
		  d_out : Out std_logic_vector(6 downto 0));
		  
END Component;

begin

DUT: bcd_to_7seg
	Port Map(bcd_in=>s_bcd_in,
				d_out => s_d_out);
				
s_bcd_in<=7;
s_run<='1', '0' after 100us;

end tb;
