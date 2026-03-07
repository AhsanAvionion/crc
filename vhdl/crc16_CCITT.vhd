
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity crc16_modbus is
  port ( 
        clk_i                   : in  std_logic;
        arstn_i                 : in  std_logic;
        soft_rst_i              : in  std_logic;
        data_in_valid_i         : in  std_logic;
        data_in_i               : in  std_logic_vector(7 downto 0);
        crclatch_out_o          : out std_logic_vector(15 downto 0);    -- crc valid at next to next clock of the data_in_valid_i
        crc_out_o               : out std_logic_vector(15 downto 0)     -- crc valid at next clock of the data_in_valid_i
        );
end crc16_modbus;

architecture Behavioral of crc16_modbus is

    constant C_CRC_INIT_VALUE : std_logic_vector(15 downto 0) := x"FFFF";
    signal next_CRC : std_logic_vector(15 downto 0) := (others => '0');
    signal r_CRC    : std_logic_vector(15 downto 0) := C_CRC_INIT_VALUE;
begin

    
    
-- Parallel CRC16/CCITT XOR network in VHDL using a polynomial of 0x1021.
    process(clk_i, arstn_i)
    begin
      if (arstn_i = '0') then
        r_CRC <= C_CRC_INIT_VALUE;
      elsif rising_edge(clk_i) then
        if soft_rst_i = '1' then
          r_CRC <= C_CRC_INIT_VALUE;
        elsif data_in_valid_i = '1' then
          r_CRC <= next_CRC;
        end if;
      end if;
    end process;

    crclatch_out_o <= r_crc;
    crc_out_o <= next_CRC;

-- Parallel CRC16/CCITT XOR network in VHDL using a polynomial of 0x1021.
    next_crc(0)  <= data_in_i(4) xor data_in_i(0) xor r_crc(8)  xor r_crc(12);
    next_crc(1)  <= data_in_i(5) xor data_in_i(1) xor r_crc(9)  xor r_crc(13);
    next_crc(2)  <= data_in_i(6) xor data_in_i(2) xor r_crc(10) xor r_crc(14);
    next_crc(3)  <= data_in_i(7) xor data_in_i(3) xor r_crc(11) xor r_crc(15);
    next_crc(4)  <= data_in_i(4) xor r_crc(12);
    next_crc(5)  <= data_in_i(5) xor data_in_i(4) xor data_in_i(0) xor r_crc(8)  xor r_crc(12) xor r_crc(13);
    next_crc(6)  <= data_in_i(6) xor data_in_i(5) xor data_in_i(1) xor r_crc(9)  xor r_crc(13) xor r_crc(14);
    next_crc(7)  <= data_in_i(7) xor data_in_i(6) xor data_in_i(2) xor r_crc(10) xor r_crc(14) xor r_crc(15);
    next_crc(8)  <= data_in_i(7) xor data_in_i(3) xor r_crc(0)  xor r_crc(11) xor r_crc(15);
    next_crc(9)  <= data_in_i(4) xor r_crc(1)  xor r_crc(12);
    next_crc(10) <= data_in_i(5) xor r_crc(2)  xor r_crc(13);
    next_crc(11) <= data_in_i(6) xor r_crc(3)  xor r_crc(14);
    next_crc(12) <= data_in_i(7) xor data_in_i(4) xor data_in_i(0) xor r_crc(4)  xor r_crc(8)  xor r_crc(12) xor r_crc(15);
    next_crc(13) <= data_in_i(5) xor data_in_i(1) xor r_crc(5)  xor r_crc(9)  xor r_crc(13);
    next_crc(14) <= data_in_i(6) xor data_in_i(2) xor r_crc(6)  xor r_crc(10) xor r_crc(14);
    next_crc(15) <= data_in_i(7) xor data_in_i(3) xor r_crc(7)  xor r_crc(11) xor r_crc(15);
    
    
    
    

end Behavioral;
