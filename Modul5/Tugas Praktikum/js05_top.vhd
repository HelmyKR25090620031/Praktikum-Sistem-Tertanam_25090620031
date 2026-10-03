library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR (0 downto 0); -- sw(0) sebagai input freeze
        btnU : in  STD_LOGIC;
        btnD : in  STD_LOGIC;
        btnC : in  STD_LOGIC;
        seg  : out STD_LOGIC_VECTOR (6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is
    signal btnU_db, btnD_db, btnC_db : STD_LOGIC;
    signal btnU_pulse, btnD_pulse   : STD_LOGIC;
    signal count_val                 : STD_LOGIC_VECTOR(15 downto 0);
begin

    DB_U: entity work.debounce generic map (100_000_000, 10) port map (clk, btnU, btnU_db);
    DB_D: entity work.debounce generic map (100_000_000, 10) port map (clk, btnD, btnD_db);
    DB_C: entity work.debounce generic map (100_000_000, 10) port map (clk, btnC, btnC_db);

    ED_U: entity work.edge_detect port map (clk, btnU_db, btnU_pulse);
    ED_D: entity work.edge_detect port map (clk, btnD_db, btnD_pulse);

    COUNTER_INST: entity work.updown_counter
        port map (
            clk       => clk,
            rst       => btnC_db,
            freeze    => sw(0), -- Mengatur freeze via sw(0)
            inc_pulse => btnU_pulse,
            dec_pulse => btnD_pulse,
            count_out => count_val
        );

    SEG_DRIVER_INST: entity work.seven_seg_driver
        generic map (4, 100_000_000)
        port map (clk, count_val, seg, dp, an);

end Behavioral;