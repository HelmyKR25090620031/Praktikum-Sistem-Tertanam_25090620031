library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_switch_top is
    Port ( sw  : in  STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0) );
end led_switch_top;

architecture Behavioral of led_switch_top is
begin
    -- 1. Mengaktifkan led[7:0] secara berkebalikan (inverted) dari sw[7:0]
    led(7 downto 0) <= not sw(7 downto 0);
    
    -- 2. Mematikan sisa LED (led[15:8]) dengan memberi nilai logika '0'
    led(15 downto 8) <= (others => '0');
end Behavioral;