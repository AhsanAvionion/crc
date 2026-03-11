
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc16_modbus_tb is
end crc16_modbus_tb;

architecture tb of crc16_modbus_tb is

    -- Clock period for 50 MHz
    constant CLK_PERIOD : time := 20 ns;

    signal clk_i           : std_logic := '0';
    signal arstn_i         : std_logic := '0';
    signal soft_rst_i      : std_logic := '0';
    signal data_in_valid_i : std_logic := '0';
    signal data_in_i       : std_logic_vector(7 downto 0) := (others => '0');
    signal crclatch_out_o  : std_logic_vector(15 downto 0);
    signal crc_out_valid_o : std_logic := '0';

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    dut : entity work.crc16_modbus
        port map (
            clk_i           => clk_i,
            arstn_i         => arstn_i,
            soft_rst_i      => soft_rst_i,
            data_in_valid_i => data_in_valid_i,
            data_in_i       => data_in_i,
            crc_out_valid_o => crc_out_valid_o,
            crclatch_out_o  => crclatch_out_o
        );

    ----------------------------------------------------------------
    -- 50 MHz Clock
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk_i <= '0';
            wait for CLK_PERIOD/2;
            clk_i <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- Stimulus
    ----------------------------------------------------------------
    stim_proc : process

        procedure send_byte(b : std_logic_vector(7 downto 0)) is
        begin
            data_in_i <= b;
            data_in_valid_i <= '1';
            wait until rising_edge(clk_i);
            data_in_valid_i <= '0';
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
            wait until rising_edge(clk_i);
        end procedure;

    begin

        ------------------------------------------------------------
        -- Async reset low for 2 clocks
        ------------------------------------------------------------
        arstn_i <= '0';
        wait until rising_edge(clk_i);
        wait until rising_edge(clk_i);
        arstn_i <= '1';
        wait until rising_edge(clk_i);
--        wait until falling_edge(clk_i);

        ------------------------------------------------------------
        -- Feed 0x313233343536373839
        ------------------------------------------------------------
        send_byte(x"31");
        send_byte(x"32");
        send_byte(x"33");
        send_byte(x"34");
        send_byte(x"35");
        send_byte(x"36");
        send_byte(x"37");
        send_byte(x"38");
        send_byte(x"39");

        wait for 200 ns;

        ------------------------------------------------------------
        -- Soft reset
        ------------------------------------------------------------
        soft_rst_i <= '1';
        wait until rising_edge(clk_i);
        soft_rst_i <= '0';
        wait until rising_edge(clk_i);

        ------------------------------------------------------------
        -- Feed 0x1103006B0002
        ------------------------------------------------------------
        send_byte(x"11");
        send_byte(x"03");
        send_byte(x"00");
        send_byte(x"6B");
        send_byte(x"00");
        send_byte(x"02");

        wait for 500 ns;

        wait;

    end process;

end architecture;
