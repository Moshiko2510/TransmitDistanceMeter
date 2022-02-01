----------------------------------------------------------------------------------------------------

--Module name: sensor_driver
--Tasks:
--(1) Count the duration of input signal 'echo' in '1' logic level.
--(2) Send triggers pulses with pulse width of 12us.

----------------------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity sensor_driver is
generic (pulse_width	: integer:=6);
	
port(
	sys_clk		: in    std_logic;
	rst			: in    std_logic;
	trig_in		: in    std_logic;	--trigger recieved from logic module
	echo			: in    std_logic;	--recieving data from sensor driver
	duration		: out   integer;		--duration of echo signal 
	eoc			: out   std_logic;	--end of counting 
	trig_out		: out   std_logic);	--sending trigger to sensor driver


end entity sensor_driver;


architecture sensor_driver_arc of sensor_driver is
-----------signals--------------------
signal cnt_duration		 : integer:=0;
signal trig_out_cnt		 : integer:=0;
signal trig_flag         : std_logic;

begin

--Task(1):
dur: process(sys_clk,rst)
begin
	if (rst='1') then
		cnt_duration <=0;
		duration	 	 <= 0;
		eoc<='0';
		
	elsif(rising_edge(sys_clk)) then
		--eoc <= '0'; 
		if(echo='1') then
			eoc <= '0';
			cnt_duration <= cnt_duration + 1;
		
		else
			if(cnt_duration>0)then
				duration	    <= cnt_duration;
				eoc<='1';
			end if;
			cnt_duration <= 0;	
		end if; 		
	end if; 
	
end process dur; 


--Task(2):
cnt_trig_proc: process(sys_clk,rst)
begin
	if (rst='1') then
		trig_out	     <= '0';
		trig_out_cnt  <=  0;
		trig_flag     <= '0';
		
	elsif(rising_edge(sys_clk)) then
	
		
		
		if (trig_in='1') then
			trig_flag<='1';
		end if;
		
		if(trig_flag='1')then 
			if (trig_out_cnt=pulse_width)then
				trig_out		 <= '0';
				trig_out_cnt <=  0;
				trig_flag    <='0';
					
			elsif (trig_out_cnt<pulse_width) then 
				trig_out 	 		<= '1';
				trig_out_cnt 		<= trig_out_cnt + 1;
			end if;
		end if;
	end if;
end process cnt_trig_proc;

end architecture sensor_driver_arc;
 