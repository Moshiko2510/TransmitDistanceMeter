library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity uart is
generic(	baud_rate 	 :  integer:=9600);

port(
		sys_clk			 : in    std_logic;
		rst				 : in    std_logic;				   	
		tx_ena			 : in    std_logic;																 --when data is available 				   			   
		tx_data			 : in    std_logic_vector(7 downto 0);
		tx_busy_uart	 : out   std_logic;
		uart_tx			 : out   std_logic);
	
end entity;

--*************************************************************************
--									 Architecture
--*************************************************************************

architecture behave of uart is

constant divider  		   : integer  := 325;														 --sys_clk/(16*baud_rate) --> for uart clk   325
constant clk_width   	   : integer  := integer(ceil(log2(real(divider))));          	 --2 in power of what will be divider-> that's the num of bits for counter  
constant clk_max_cnt       : unsigned := to_unsigned(divider-1, clk_width);				 --max value for counter (value-325,num of bits of value-9)

signal uart_clk_en         : std_logic;																 --uart clk pulse when counter below is at max value
signal uart_clk_cnt        : unsigned(clk_width-1 downto 0);									 --uart clk counter
signal a_clk_divider_en    : std_logic;                                                 --enable when data is ready (tx_ena is HIGH)
signal a_tx_data  			: std_logic_vector(7 downto 0);										 --data bits from logic
signal a_tx_busy_uart		: std_logic;																 --busy flag. on HIGH when data transmit is in progress
signal a_tx_bit_counter	   : unsigned(2 downto 0);													 --counter to check num of bits allready transmited
signal a_tx_bit_counter_en : std_logic;																 --when this flag is enabled data trasmit is in progress and counter above is counting
signal a_parity_bit			: std_logic;																 --error check bit
signal a_tx_clk_en			: std_logic;																 --tx_clk flag once to 16 times of uart_clk
signal a_tx_clk_cnt        : unsigned(3 downto 0);													 --counts 16 times of uart_clk



--state_machine
type state is (idle, txsync, startbit, databits, paritybit, stopbit);
signal pstate_tx 	  : state;
signal nstate_tx    : state;	

begin

uart_clk_cnt_p : process (sys_clk)     				    				     ---one big block for all the data
    begin
        if (rising_edge(sys_clk)) then
            if (rst = '1') then
                uart_clk_cnt <= (others => '0');
            else
                if (uart_clk_en = '1') then
                    uart_clk_cnt <= (others => '0');
                else
                    uart_clk_cnt <= uart_clk_cnt + 1;
                end if;
            end if;
        end if;
    end process;

	uart_clk_en <= '1' when (uart_clk_cnt = clk_max_cnt) else '0';      ---clk_max_cnt is 9
	 
--*************************************************************************
--									 Tx Busy Output
--*************************************************************************

tx_busy_uart<=a_tx_busy_uart;

	
--*************************************************************************
--									 Clk Divider
--*************************************************************************

uart_tx_clk_divider_p : process (sys_clk)    ---process to incresing the counter only or save it position
    begin
        if (rising_edge(sys_clk)) then
            if (a_clk_divider_en = '1') then
                if (uart_clk_en = '1') then
                    if (a_tx_clk_cnt = "1111") then    --1111
                        a_tx_clk_cnt <= (others => '0');
                    else
                        a_tx_clk_cnt <= a_tx_clk_cnt + 1;
                    end if;
                else
                    a_tx_clk_cnt <= a_tx_clk_cnt;
                end if;
            else
                a_tx_clk_cnt <= (others => '0');
            end if;
        end if;
    end process;

--*************************************************************************
-- 								 Tx Clk DIV
--*************************************************************************

    uart_tx_clk_en_p : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (rst = '1') then
                a_tx_clk_en <= '0';
            elsif (uart_clk_en = '1' and a_tx_clk_cnt = "0001" ) then    
                a_tx_clk_en <= '1';
            else
                a_tx_clk_en <= '0'; --it was 0
            end if;
        end if;
    end process;
	 
	
--*************************************************************************
-- 						  Tx Input to Data Registers
--*************************************************************************
uart_data_in : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (tx_ena = '1' AND a_tx_busy_uart = '0') then
                a_tx_data <= tx_data;
            end if;
        end if;
    end process;

	 
--*************************************************************************
-- 							 	Tx Data Bit Counter
--*************************************************************************

uart_tx_bit_counter_p : process (sys_clk)
 begin
	  if (rising_edge(sys_clk)) then
			if (rst = '1') then
				 a_tx_bit_counter <= (others => '0');
			elsif (a_tx_bit_counter_en = '1' AND a_tx_clk_en = '1') then    ---transfer data when a_tx_clk_en is HIGH (tx_clk_en depends on uart clk_en)  
				 if (a_tx_bit_counter = "111") then
					  a_tx_bit_counter <= (others => '0');
				 else
					  a_tx_bit_counter <= a_tx_bit_counter + 1;
				 end if;
			end if;
	  end if;
 end process;
 
 --*************************************************************************
-- 							 		 Parity Bit 
--*************************************************************************

a_parity_bit<='0';
	 
	 
--*************************************************************************
-- 										Tx FSM
--*************************************************************************

-- PRESENT STATE REGISTER
p_state : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (rst = '1') then
                pstate_tx <= idle;
            else
                pstate_tx <= nstate_tx;
            end if;
        end if;
    end process;

    -- NEXT STATE AND OUTPUTS LOGIC
    process (pstate_tx, tx_ena, a_tx_clk_en, a_tx_bit_counter)
    begin

        case pstate_tx is

            when idle =>
                a_tx_busy_uart <= '0';  
                a_tx_bit_counter_en <= '0';
                a_clk_divider_en <= '0';
					 uart_tx	<='1';

                if (tx_ena = '1') then
                    nstate_tx <= txsync;
                else
                    nstate_tx <= idle;
                end if;

            when txsync =>
                a_tx_busy_uart <= '1';
                a_tx_bit_counter_en <= '0';
                a_clk_divider_en <= '1'; 
					 uart_tx	<='1';

                if (a_tx_clk_en = '1') then 
                    nstate_tx <= startbit;
                else
                    nstate_tx <= txsync;
                end if;

            when startbit =>
                a_tx_busy_uart <= '1';
                a_tx_bit_counter_en <= '0';
                a_clk_divider_en <= '1';
					 uart_tx	<='0';       --sign of start transmit data

                if (a_tx_clk_en = '1') then
                    nstate_tx <= databits;
                else
                    nstate_tx <= startbit;
                end if;

            when databits =>
                a_tx_busy_uart <= '1';
                a_tx_bit_counter_en <= '1';     --start counting
                a_clk_divider_en <= '1';
					 uart_tx <= (a_tx_data(to_integer(a_tx_bit_counter)));

                if ((a_tx_clk_en = '1') AND (a_tx_bit_counter = "111")) then
                    nstate_tx <= stopbit;
                else
                    nstate_tx <= databits;
                end if;

            when paritybit =>
                a_tx_busy_uart <= '1';
                a_tx_bit_counter_en <= '0';      --no more counts
                a_clk_divider_en <= '1';
					 uart_tx	<=a_parity_bit;          --check parity bit

                if (a_tx_clk_en = '1') then
                    nstate_tx <= stopbit;
                else
                    nstate_tx <= paritybit;
                end if;

            when stopbit =>
                a_tx_busy_uart <= '0';
                a_tx_bit_counter_en <= '0';
                a_clk_divider_en <= '1';
					 uart_tx	<='1';

                if (tx_ena = '1') then
                    nstate_tx <= txsync;
                elsif (a_tx_clk_en = '1') then
                    nstate_tx <= idle;
                else
                    nstate_tx <= stopbit;
                end if;

            when others =>
                a_tx_busy_uart <= '1';
                a_tx_bit_counter_en <= '0';
                a_clk_divider_en <= '0';
                nstate_tx <= idle;
					 uart_tx	<='1';

        end case;
    end process;

end behave;



























  
  