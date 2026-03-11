
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
        crc_out_valid_o         : out std_logic
--        crc_out_o               : out std_logic_vector(15 downto 0);     -- crc valid at next clock of the data_in_valid_i
        );
end crc16_modbus;

architecture Behavioral of crc16_modbus is

    constant C_CRC_INIT_VALUE : std_logic_vector(15 downto 0) := x"FFFF";
    constant C_CRC_POLY       : std_logic_vector(15 downto 0) := x"A001";
    signal next_CRC : std_logic_vector(15 downto 0) := (others => '0');
    signal r_CRC    : std_logic_vector(15 downto 0) := C_CRC_INIT_VALUE;
    
    
        signal loop_count  : integer range 0 to 63         := 0;
        
        type state_type is (
            S_IDLE,
            S_CAL
          ); 
        signal state : state_type := S_IDLE;
begin

    
    
-- Parallel CRC16/CCITT XOR network in VHDL using a polynomial of 0x1021.
--    process(clk_i, arstn_i)
--    begin
--      if (arstn_i = '0') then
--        r_CRC <= C_CRC_INIT_VALUE;
--      elsif rising_edge(clk_i) then
--        if soft_rst_i = '1' then
--          r_CRC <= C_CRC_INIT_VALUE;
--        elsif data_in_valid_i = '1' then
--          r_CRC <= next_CRC;
--        end if;
--      end if;
--    end process;

----    crclatch_out_o <= r_crc;
--    crc_out_o <= next_CRC;

---- Parallel CRC16/CCITT XOR network in VHDL using a polynomial of 0x1021.
--    next_crc(0)  <= data_in_i(4) xor data_in_i(0) xor r_crc(8)  xor r_crc(12);
--    next_crc(1)  <= data_in_i(5) xor data_in_i(1) xor r_crc(9)  xor r_crc(13);
--    next_crc(2)  <= data_in_i(6) xor data_in_i(2) xor r_crc(10) xor r_crc(14);
--    next_crc(3)  <= data_in_i(7) xor data_in_i(3) xor r_crc(11) xor r_crc(15);
--    next_crc(4)  <= data_in_i(4) xor r_crc(12);
--    next_crc(5)  <= data_in_i(5) xor data_in_i(4) xor data_in_i(0) xor r_crc(8)  xor r_crc(12) xor r_crc(13);
--    next_crc(6)  <= data_in_i(6) xor data_in_i(5) xor data_in_i(1) xor r_crc(9)  xor r_crc(13) xor r_crc(14);
--    next_crc(7)  <= data_in_i(7) xor data_in_i(6) xor data_in_i(2) xor r_crc(10) xor r_crc(14) xor r_crc(15);
--    next_crc(8)  <= data_in_i(7) xor data_in_i(3) xor r_crc(0)  xor r_crc(11) xor r_crc(15);
--    next_crc(9)  <= data_in_i(4) xor r_crc(1)  xor r_crc(12);
--    next_crc(10) <= data_in_i(5) xor r_crc(2)  xor r_crc(13);
--    next_crc(11) <= data_in_i(6) xor r_crc(3)  xor r_crc(14);
--    next_crc(12) <= data_in_i(7) xor data_in_i(4) xor data_in_i(0) xor r_crc(4)  xor r_crc(8)  xor r_crc(12) xor r_crc(15);
--    next_crc(13) <= data_in_i(5) xor data_in_i(1) xor r_crc(5)  xor r_crc(9)  xor r_crc(13);
--    next_crc(14) <= data_in_i(6) xor data_in_i(2) xor r_crc(6)  xor r_crc(10) xor r_crc(14);
--    next_crc(15) <= data_in_i(7) xor data_in_i(3) xor r_crc(7)  xor r_crc(11) xor r_crc(15);
    
    
    

-- Parallel CRC16/modbus XOR network in VHDL using a polynomial of 0xA001.
    process(clk_i, arstn_i)
        variable crc_rsh     : std_logic_vector(15 downto 0) := C_CRC_INIT_VALUE;
        
    begin
        if arstn_i = '0' or soft_rst_i = '1' then
          r_crc <= C_CRC_INIT_VALUE;
          crc_out_valid_o <= '0';
          crclatch_out_o <= (others => '0');
        elsif rising_edge(clk_i) then
          case state is
              ---------------------------------
              when S_IDLE =>
              ---------------------------------
                if data_in_valid_i = '1' then
                  r_crc(7 downto 0) <= r_crc(7 downto 0) xor data_in_i;
                  state <= S_CAL;
                  crc_out_valid_o <= '0';
                end if;
                -- crc_out_o <= r_crc;
              ---------------------------------
              when S_CAL =>
              ---------------------------------
                if loop_count = 7 then
                  -- state := S_DONE;
                  loop_count <= 0;
                  crc_out_valid_o <= '1';
                  crc_rsh := '0' & r_crc(15 downto 1);  -- shift right by 1
                    if r_crc(0) = '1' then
                      r_crc <= crc_rsh xor C_CRC_POLY;
                      crclatch_out_o <= crc_rsh xor C_CRC_POLY;
                    else
                      r_crc <= crc_rsh;
                      crclatch_out_o <= crc_rsh;
                    end if; 
                  state <= S_IDLE;
                else
                  crc_rsh := '0' & r_crc(15 downto 1);  -- shift right by 1
                    if r_crc(0) = '1' then
                      r_crc <= crc_rsh xor C_CRC_POLY;
                    else
                      r_crc <= crc_rsh;
                    end if; 
                  loop_count <= loop_count + 1;
                end if;
                
                
              ---------------------------------
              when others =>
              ---------------------------------
                state <= S_IDLE;
            end case;
        end if;
    end process;

--                crc_out_o <= r_crc;
    
    

end Behavioral;
