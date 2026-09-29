library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;                     -- Clock 100 MHz (Pin W5)
        btnU : in  STD_LOGIC;                     -- Tombol Up / Increment (Pin T18)
        btnD : in  STD_LOGIC;                     -- Tombol Down / Decrement (Pin U17)
        btnC : in  STD_LOGIC;                     -- Tombol Center / Reset (Pin U18)
        seg  : out STD_LOGIC_VECTOR (6 downto 0); -- Sinyal Katoda Segmen (a-g)
        dp   : out STD_LOGIC;                     -- Titik Desimal
        an   : out STD_LOGIC_VECTOR (3 downto 0)  -- Sinyal Anoda Digit (AN3-AN0)
    );
end js05_top;

architecture Behavioral of js05_top is
    -- Sinyal internal hasil pembersihan debouncer
    signal btnU_db, btnD_db, btnC_db : STD_LOGIC;
    
    -- Sinyal pulsa 1-siklus hasil pendeteksian tepi
    signal btnU_pulse, btnD_pulse : STD_LOGIC;
    
    -- Bus data 16-bit penampung nilai pencacah (4 digit BCD/Hex)
    signal count_val : STD_LOGIC_VECTOR(15 downto 0);
begin

    -- 1. Instansiasi Rangkaian Debounce untuk Ketiga Tombol
    DB_U: entity work.debounce
        generic map (CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10)
        port map (clk => clk, btn_in => btnU, btn_out => btnU_db);

    DB_D: entity work.debounce
        generic map (CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10)
        port map (clk => clk, btn_in => btnD, btn_out => btnD_db);

    DB_C: entity work.debounce
        generic map (CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10)
        port map (clk => clk, btn_in => btnC, btn_out => btnC_db);

    -- 2. Instansiasi Pendeteksi Tepi (Edge Detector) untuk btnU dan btnD
    ED_U: entity work.edge_detect
        port map (clk => clk, sig_in => btnU_db, pulse => btnU_pulse);

    ED_D: entity work.edge_detect
        port map (clk => clk, sig_in => btnD_db, pulse => btnD_pulse);

    -- 3. Instansiasi Up/Down Counter
    COUNTER_INST: entity work.updown_counter
        port map (
            clk       => clk,
            rst       => btnC_db,
            inc_pulse => btnU_pulse,
            dec_pulse => btnD_pulse,
            count_out => count_val
        );

    -- 4. Instansiasi Driver Seven-Segment Display (4-Digit Multiplexing)
    SEG_DRIVER_INST: entity work.seven_seg_driver
        generic map (
            DIGITS      => 4,
            CLK_FREQ_HZ => 100_000_000
        )
        port map (
            clk     => clk,
            data_in => count_val,
            seg     => seg,
            dp      => dp,
            an      => an
        );

end Behavioral;