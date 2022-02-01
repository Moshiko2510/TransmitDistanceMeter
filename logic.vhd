----------------------------------------------------------------------------------------------------
--Module name: logic
--Tasks:
--(1) Send triggers periodeclly to the sensor when the car is in reverse drive state.
--(2) Convert the duration of echo signal to distance and send to 7seg.

----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



entity logic is
generic(	cnt_thr		 : integer :=20);	-- defines the period of the periodically sending triggers.

port(
	sys_clk			 : in    std_logic;
	rst				 : in    std_logic;
	start_measure	 : in    std_logic; 				   
	data_in_vld		 : in    std_logic; 	
	data_in			 : in    integer; 				   
	send_trig		 : out   std_logic; 				   
	ones				 : out   integer range 0 to 9; 
	tens 				 : out   integer range 0 to 9;				   
	hunds		   	 : out   integer range 0 to 9;
	data_out			 : out   std_logic_vector(7 downto 0);
	data_out_vld	 : out   std_logic); 
	
end entity;



architecture logic_arc of logic is
-----------signals----------
signal distance		: integer:=0;
signal cnt				: integer:=0;


begin

--Task(1):

send_trig_proc: process(sys_clk, rst)
begin
	if (rst='1') then
		send_trig	<= '0';
		cnt			<=  0;
		
		
	elsif(rising_edge(sys_clk)) then
		send_trig	<= '0';
				 
			if(start_measure='1') then
				cnt	<=	cnt + 1;
				
				if (cnt=0) then
					send_trig	<= '1';
				else
					send_trig	<= '0';
				end if;
				
				if (cnt=cnt_thr) then
					cnt			<=  0;
				end if;
				 
			end if;
	end if;
end process send_trig_proc;


--Task(2): 
calc_proc: process(sys_clk, rst)
begin
	if (rst='1') then
		ones <=0;
		tens <=0;
		hunds <=0; 
		data_out		<= (others => '0');
		data_out_vld	<= '0';

		
	elsif(rising_edge(sys_clk)) then
		if (data_in_vld='1') then
			distance		<= ((data_in*343)/1000000);    --distance in cm.  range [17490-1749000] of pulses clock for 50MHz freq
			data_out<= conv_std_logic_vector((data_in*343)/1000000, 8);
			if(start_measure='1') then		-----add
				data_out_vld	<= '1';
			else								-----add
				data_out_vld	<= '0'; -----add
			end if;
			if (99<distance and distance<1000) then
				hunds<= distance/100;
				ones<=distance rem 10;
				tens<=(distance/10) rem 10;
				
			elsif(9<distance and distance<100)	then
				hunds<= 0;
				ones<=distance rem 10;
				tens<=(distance/10) ;
			elsif(0<distance and distance<10)	then
				hunds<= 0;
				ones<=distance rem 10;
				tens<=0 ;
			elsif(distance=0)then
				hunds<= 0;
				ones<=0;
				tens<=0 ;
			else
				hunds<= distance/100;
				ones<=distance rem 10;
				tens<=(distance/10) rem 10;
			end if;
		end if;
	end if;
	
end process calc_proc;
	
end architecture logic_arc;	
	
	
	
	
	
	
	
	