library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity priority_encoder83 is
    Port (
        sw  : in  STD_LOGIC_VECTOR (7 downto 0);
        led : out STD_LOGIC_VECTOR (3 downto 0)  -- led(2 downto 0): posisi, led(3): flag valid
    );
end priority_encoder83;

architecture Behavioral of priority_encoder83 is
begin
    process(sw)
    begin
        if sw(7) = '1' then
            led(2 downto 0) <= "111"; -- Posisi 7
            led(3)          <= '1';   -- Valid
        elsif sw(6) = '1' then
            led(2 downto 0) <= "110"; -- Posisi 6
            led(3)          <= '1';   -- Valid
        elsif sw(5) = '1' then
            led(2 downto 0) <= "101"; -- Posisi 5
            led(3)          <= '1';   -- Valid
        elsif sw(4) = '1' then
            led(2 downto 0) <= "100"; -- Posisi 4
            led(3)          <= '1';   -- Valid
        elsif sw(3) = '1' then
            led(2 downto 0) <= "011"; -- Posisi 3
            led(3)          <= '1';   -- Valid
        elsif sw(2) = '1' then
            led(2 downto 0) <= "010"; -- Posisi 2
            led(3)          <= '1';   -- Valid
        elsif sw(1) = '1' then
            led(2 downto 0) <= "001"; -- Posisi 1
            led(3)          <= '1';   -- Valid
        elsif sw(0) = '1' then
            led(2 downto 0) <= "000"; -- Posisi 0
            led(3)          <= '1';   -- Valid
        else
            led(2 downto 0) <= "000"; -- Default
            led(3)          <= '0';   -- Tidak valid (semua switch OFF)
        end if;
    end process;
end Behavioral;