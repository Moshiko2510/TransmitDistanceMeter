LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Transmit_distance_meter IS
				
	PORT(clk_50Mhz, rst,start_measure,echo : IN STD_LOGIC;
			ones_7seg,tens_7seg, hunds_7seg  : out std_logic_vector(6 DOWNTO 0);
			trig_out : OUT STD_LOGIC;
			tx			: out   std_logic
			);
	
END Transmit_distance_meter;

---------------------------------------------------

ARCHITECTURE struct OF Transmit_distance_meter IS

Component logic
		GENERIC (cnt_thr: integer:=2500000);
		
		PORT(sys_clk, rst,start_measure,data_in_vld: In std_logic;
			  data_in		  	  : in integer;
			  ones, tens ,hunds : Out integer range 0 to 9;
			  send_trig 		  : out std_logic;
			  data_out			  : out   std_logic_vector(7 downto 0);
			  data_out_vld	     : out   std_logic );
			 
	
END Component;

Component uart
		GENERIC (baud_rate : integer:=9600);
		
		PORT(	sys_clk			 : in    std_logic;
				rst				 : in    std_logic;				   	
				tx_ena			 : in    std_logic;	 				   			   
				tx_data			 : in    std_logic_vector(7 downto 0);
				tx_busy_uart	 : out   std_logic;
				uart_tx			 : out   std_logic );
			 	
END Component;


Component sensor_driver
		GENERIC (pulse_width	: integer:=600);
		
		PORT(sys_clk, rst,echo,trig_in: In std_logic;
			  duration : Out integer;	
			  trig_out,eoc : Out std_logic );
	
END Component;

Component bcd_to_7seg
	PORT(bcd_in : In INTEGER RANGE 0 to 9;
		  d_out : Out std_logic_vector(6 downto 0));
		  
END Component;

----------------------------------------------------
signal s1,s2,s3	: std_logic;
signal sv1, sv2, sv3 : INTEGER RANGE 0 to 9;
signal sv4 				: integer;
signal sv5 			   : std_logic_vector(7 downto 0);
----------------------------------------------------

BEGIN

U1 : logic
		Port Map(sys_clk => clk_50Mhz,
					rst => rst,
					start_measure => start_measure,
					data_in_vld => s1,
					data_in => sv4,
					ones=>sv1,
					tens=>sv2,
					hunds=>sv3,
					send_trig=>s2,
					data_out_vld=>s3,
					data_out=>sv5 );
					
					
U2: uart
		port map(sys_clk => clk_50Mhz,
					rst => rst,
					tx_ena=>s3,
					tx_busy_uart=>open,
					tx_data=>sv5,
					uart_tx=>tx );
		
			

U3 : sensor_driver
		Port Map(sys_clk => clk_50Mhz,
					rst => rst,
					echo =>echo,
					eoc=> s1,
					duration =>sv4,
					trig_out=>trig_out,
					trig_in =>  s2 );
					
		
U4 : bcd_to_7seg
		Port Map(bcd_in=>sv1,
					d_out => ones_7seg);

U5 : bcd_to_7seg
		Port Map(bcd_in=>sv2,
					d_out => tens_7seg);					
					
U6 : bcd_to_7seg
		Port Map(bcd_in=>sv3,
					d_out => hunds_7seg);
					
					
END struct;