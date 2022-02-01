library ieee;
use ieee.std_logic_1164.all;


entity Transmit_distance_meter_tb is
end entity Transmit_distance_meter_tb;


architecture Transmit_distance_meter_tb_arc of Transmit_distance_meter_tb is

-------signals------------
signal s_clk_50Mhz		    : std_logic;	
signal s_rst					 : std_logic;
signal s_echo		   		 : std_logic;
signal s_start_measure	    : std_logic;
signal s_hunds 				 : std_logic_vector(6 DOWNTO 0);
signal s_tens  				 : std_logic_vector(6 DOWNTO 0);
signal s_ones					 : std_logic_vector(6 DOWNTO 0);
signal s_trig_out	 		    : std_logic;
signal s_tx	 		    	    : std_logic;
signal s_run 				    : std_logic:='1';


-----components---------------
component Transmit_distance_meter
				
	PORT(clk_50Mhz, rst,start_measure,echo : IN STD_LOGIC;
			ones_7seg,tens_7seg, hunds_7seg : OUT std_logic_vector(6 DOWNTO 0);
			trig_out,tx: OUT STD_LOGIC 
			);
											
end component Transmit_distance_meter;


begin


DUT: Transmit_distance_meter
		port map(
			clk_50Mhz		=>	s_clk_50Mhz		,
			start_measure  =>s_start_measure ,
			rst				=>	s_rst				,
			echo				=>	s_echo			,
			hunds_7seg 		=>	s_hunds		   ,
			tens_7seg		=>	s_tens	   	,
			ones_7seg		=>	s_ones	   	,
			tx					=>	s_tx	   	   ,
			trig_out			=>	s_trig_out			
		);


----------------------signals------------------------
s_rst<='1', '0' after 20us;
s_start_measure<='0','1' after 50us,'0' after 70us;
s_echo<='0', '1' after 280us,'0' after 9155us;
s_run<='1', '0' after 13000us;
-----------------------------------------------------

clock_create: process
	begin	
			while s_run='1' loop
				s_clk_50Mhz<='0','1' after 10ns;
				wait for 20ns;
			end loop;
			wait;
	end process;



end architecture Transmit_distance_meter_tb_arc;
