library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_piso is
    Port (
        clk  : in  STD_LOGIC;                    -- Clock 100 MHz (Pin W5)
        btnU : in  STD_LOGIC;                    -- Reset (Button Up)
        btnC : in  STD_LOGIC;                    -- Load (Button Center)
        sw   : in  STD_LOGIC_VECTOR(7 downto 0); -- Input data paralel (Switch 0-7)
        led0 : out STD_LOGIC                     -- Output serial (LED 0)
    );
end top_piso;

architecture Behavioral of top_piso is
    signal clk_1hz : STD_LOGIC := '0';
    signal count   : integer range 0 to 49_999_999 := 0;
begin
    -- Pembagi Clock: 100 MHz menjadi 1 Hz (1 Siklus per Detik)
    process(clk)
    begin
        if rising_edge(clk) then
            if count = 49_999_999 then
                count <= 0;
                clk_1hz <= not clk_1hz;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    -- Instansiasi Modul PISO menggunakan Clock 1 Hz
    UUT: entity work.piso_8bit
        port map (
            clk  => clk_1hz,
            rst  => btnU,
            load => btnC,
            d    => sw,
            sout => led0
        );
end Behavioral;