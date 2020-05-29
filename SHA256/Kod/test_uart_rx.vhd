
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY test_uart_rx IS
END test_uart_rx;

ARCHITECTURE behavior OF test_uart_rx IS

    --! Inputs uart_rx 
    signal Clk      : std_logic := '0';
    signal Reset    : std_logic := '0';
    signal Rx       : std_logic   := '1';

    --! Outputs uart_rx 
    signal RX_Data      : std_logic_vector(7 downto 0);
    signal RX_Ready     : std_logic;

    --! Clock for bit changing
    signal Clk_bit      : std_logic := '0';

    --! Clock periods
    constant Clk_period : time := 83.3 ns;
    constant Bit_period : time := 25.5 us;

    signal counter      : integer := 0;

BEGIN
	
	--! declaration uart_rx 
    uut: entity work.uart_rx
    PORT MAP (
        Clk 			=> Clk,
        Reset			=> Reset,
        Rx				=> Rx,
        RX_Data_Out		=> RX_Data,
        RX_Ready		=> RX_Ready
    );

    --! Clock process definitions
    Clk_process :process
    begin
        Clk <= '0';
        wait for Clk_period/2;
        Clk <= '1';
        wait for Clk_period/2;
    end process;

    clk2 : Clk_bit <= not Clk_bit after Bit_period;

    --! Stimulus process
    stim_proc: process(Clk_bit)
    begin
        if rising_edge(Clk_bit) then
            
            counter <= counter + 1;

            if counter = 0 then
                Rx <= '0';
            elsif counter < 9 then
                Rx <= not Rx;
            elsif counter = 11 then
                counter <= 0;
            else
                Rx <= '1';
            end if;
            
        end if;
        
    end process;

END;
