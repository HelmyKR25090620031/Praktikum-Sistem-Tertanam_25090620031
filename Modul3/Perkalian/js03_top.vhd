library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js03_top is
    Port (
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (8 downto 0)  -- LED0-LED7: result, LED8: carry
    );
end js03_top;

architecture Structural of js03_top is
begin
    U_ALU4: entity work.alu4
        port map (
            a      => sw(3 downto 0),    -- SW0 s.d. SW3
            b      => sw(7 downto 4),    -- SW4 s.d. SW7
            opcode => sw(15 downto 14),  -- SW14 & SW15 (2-bit)
            result => led(7 downto 0),   -- LED0 s.d. LED7 (8-bit)
            carry  => led(8)             -- LED8
        );
end Structural;