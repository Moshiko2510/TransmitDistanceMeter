
library ieee;
use ieee.std_logic_1164.all;

entity logic_tb is
end entity logic_tb;



architecture logic_tb_arc of logic_tb is


-----------signals--------------------
signal s_sys_clk			 : std_logic;
signal s_rst				 : std_logic;
signal s_data_in			 : integer;
signal s_data_in_vld		 : std_logic;
signal s_send_trig		 : std_logic;
signal s_start_measure	 : std_logic;
signal s_ones			 	 : integer range 0 to 9; 
signal s_tens 				 : integer range 0 to 9;				   
signal s_hunds		  	 	 : integer range 0 to 9;
signal s_run 				 : std_logic:='1';
signal s_data_out			 : std_logic_vector(7 downto 0);
signal s_data_out_vld	 : std_logic;


-----------components-----------------
component logic
	generic(	cnt_thr		 : integer :=20);
			 
	 port (
				sys_clk			 : in    std_logic;
				rst				 : in    std_logic;
				start_measure	 : in    std_logic;
				data_in			 : in    integer; 				   --recieving the duration of echo in high level in sys_clk cycles
				data_in_vld	 	 : in    std_logic; 				   --when data_in_vld='1', the data_in is valid
				send_trig		 : out   std_logic;				   --send trigger to sensor driver in order to start measuring
				ones			 	 : out   integer range 0 to 9; 
				tens 			  	 : out   integer range 0 to 9;				   
				hunds		   	 : out   integer range 0 to 9;
				data_out			 : out   std_logic_vector(7 downto 0);
				data_out_vld	 : out   std_logic); 	
					
end component logic;


begin

DUT: logic
		generic map(cnt_thr	=> 20)
		 
		port map(
			sys_clk		 	=> s_sys_clk,
			rst			 	=> s_rst,
			data_in		 	=> s_data_in,
			data_in_vld	 	=> s_data_in_vld,
			send_trig	 	=> s_send_trig,
			ones         	=> s_ones,
			tens		    	=> s_tens,
			hunds		    	=> s_hunds,
			start_measure	=> s_start_measure,
			data_out			=> s_data_out,
			data_out_vld	=> s_data_out_vld
		);

------------------signals----------------------

s_rst<='1', '0' after 20 us;
s_data_in<=0 ,150050 after 250 us,0 after 310 us;
s_data_in_vld<='0', '1' after 250 us,'0' after 310 us;
s_start_measure<='0','1' after 50 us,'0' after 90 us,'1' after 1500 us,'0' after 1540 us;
s_run<='1', '0' after 13000 us;

-----------------processes----------------------

clock_create: process
	begin	
			while s_run='1' loop
				s_sys_clk<='0','1' after 10ns;
				wait for 20ns;
			end loop;
			wait;
		end process;


end architecture logic_tb_arc;
