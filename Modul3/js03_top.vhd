library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js03_top is
    Port (
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (4 downto 0)
    );
end js03_top;

architecture Structural of js03_top is
begin
    -- Instansiasi modul alu4
    U_ALU4: entity work.alu4
        port map (
            a      => sw(3 downto 0),
            b      => sw(7 downto 4),
            opcode => sw(15),
            result => led(3 downto 0),
            carry  => led(4)
        );
end Structural;