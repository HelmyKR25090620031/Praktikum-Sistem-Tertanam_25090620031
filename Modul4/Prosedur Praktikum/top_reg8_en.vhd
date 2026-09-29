library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_reg8_en is
    Port (
        clk  : in  STD_LOGIC;                    -- Clock 100 MHz (Pin W5)
        btnU : in  STD_LOGIC;                    -- Reset (Button Up)
        btnC : in  STD_LOGIC;                    -- Enable (Button Center)
        sw   : in  STD_LOGIC_VECTOR(7 downto 0); -- Data input (Switch 0-7)
        led  : out STD_LOGIC_VECTOR(7 downto 0)  -- Output data (LED 0-7)
    );
end top_reg8_en;

architecture Behavioral of top_reg8_en is
begin
    -- Instansiasi modul reg8_en
    UUT: entity work.reg8_en
        port map (
            clk => clk,
            rst => btnU,
            en  => btnC,
            d   => sw,
            q   => led
        );
end Behavioral;