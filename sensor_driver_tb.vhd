library ieee;
use ieee.std_logic_1164.all;
--------------------------------------
entity sensor_driver_tb is

end entity;
---------------------------------------
architecture tb of sensor_driver_tb is

 
---------------------------------------
	signal s_sys_clk,s_rst,s_trig_in,s_echo : std_logic:='0';
	signal s_duration: integer ;
	signal s_eoc : std_logic;
	signal s_trig_out : std_logic;
	signal s_run : std_logic:='1';
---------------------------------------

component sensor_driver
		generic (pulse_width	: integer:=6);
		port(
				sys_clk		: in    std_logic;
				rst			: in    std_logic;
				trig_in		: in    std_logic;
				echo			: in    std_logic;	
				duration		: out   integer;	
				eoc			: out   std_logic;	
				trig_out		: out   std_logic);
	
end component sensor_driver;

begin

DUT: sensor_driver
		generic map(pulse_width => 6 )
		port map(
					sys_clk=>s_sys_clk,
					rst=>s_rst,
					duration=>s_duration,
					trig_in=>s_trig_in,
					echo=>s_echo,
					eoc=>s_eoc,
					trig_out=>s_trig_out	);
		
-----------------------------------------

s_rst<='1', '0' after 20us;
s_trig_in<='0' ,'1' after 30us,'0' after 40us;
s_echo<='0', '1' after 180us,'0' after 950us;
s_run<='1', '0' after 1300us;


-----------------------------------------------

clock_create: process
	begin	
			while s_run='1' loop
				s_sys_clk<='0','1' after 10us;
				wait for 20us;
			end loop;
			wait;
		end process;
		
		
end tb;
