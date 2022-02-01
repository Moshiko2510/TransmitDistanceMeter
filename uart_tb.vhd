library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity uart_tb is
end entity uart_tb;



architecture uart_tb_arc of uart_tb is


-----------signals--------------------
signal  		s_sys_clk		 :   std_logic;
signal		s_rst				 :   std_logic;				   	
signal		s_tx_ena			 :   std_logic;																 				   			   
signal		s_tx_data		 :   std_logic_vector(7 downto 0);
signal		s_tx_busy_uart	 :   std_logic;
signal		s_uart_tx		 :   std_logic;
signal 	   s_run 			 :   std_logic:='1';	



-----------components-----------------
Component uart
		GENERIC (baud_rate : integer:=9600);
		
		PORT(	sys_clk			 : in    std_logic;
				rst				 : in    std_logic;				   	
				tx_ena			 : in    std_logic;	 				   			   
				tx_data			 : in    std_logic_vector(7 downto 0);
				tx_busy_uart	 : out   std_logic;
				uart_tx			 : out   std_logic );
			 	
END Component;


begin

DUT: uart
		generic map(baud_rate => 9600)
		 
		port map(sys_clk => s_sys_clk,
						rst => s_rst,
						tx_ena=>s_tx_ena,
						tx_busy_uart=>s_tx_busy_uart,
						tx_data=>s_tx_data,
						uart_tx=>s_uart_tx ); 
		

------------------signals----------------------

s_rst<='1', '0' after 20 us;
s_tx_data<="00000000" ,"10100111" after 50 us,"00000000" after 150 us,"00110110" after 1500 us,"00000000" after 1600 us;
s_tx_ena<='0','1' after 50 us,'0' after 60 us,'1' after 1500 us,'0' after 1520 us;
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


end architecture;
