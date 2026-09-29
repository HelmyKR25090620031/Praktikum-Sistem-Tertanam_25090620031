library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture sim of tb_debounce is
    signal clk_tb     : STD_LOGIC := '0';
    signal btn_in_tb  : STD_LOGIC := '0';
    signal btn_out_tb : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns; -- Clock 100 MHz
begin
    -- Instansiasi DUT (Device Under Test)
    -- STABLE_MS di-override jadi 1 ms agar waktu simulasi tidak terlalu panjang
    DUT: entity work.debounce
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            STABLE_MS   => 1
        )
        port map (
            clk     => clk_tb,
            btn_in  => btn_in_tb,
            btn_out => btn_out_tb
        );

    -- Generator Clock (100 MHz)
    clk_process: process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD / 2;
        clk_tb <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Simulasi Bouncing
    stim_proc: process
    begin
        -- 1. Kondisi awal tenang ('0')
        btn_in_tb <= '0';
        wait for 100 ns;

        -- 2. Efek Bouncing saat tombol mulai ditekan (0 -> 1 -> 0 -> 1 -> 0 -> 1)
        btn_in_tb <= '1'; wait for 50 us;
        btn_in_tb <= '0'; wait for 30 us;
        btn_in_tb <= '1'; wait for 100 us;
        btn_in_tb <= '0'; wait for 40 us;
        
        -- Sinyal stabil ditekan ('1') lebih lama dari 1 ms (1000 us)
        btn_in_tb <= '1';
        wait for 2 ms; -- btn_out_tb HANYA akan berubah jadi '1' setelah 1 ms stabil

        -- 3. Efek Bouncing saat tombol dilepas (1 -> 0 -> 1 -> 0)
        btn_in_tb <= '0'; wait for 60 us;
        btn_in_tb <= '1'; wait for 40 us;
        btn_in_tb <= '0'; wait for 20 us;

        -- Sinyal stabil dilepas ('0') lebih lama dari 1 ms
        btn_in_tb <= '0';
        wait for 2 ms; -- btn_out_tb HANYA akan kembali ke '0' setelah 1 ms stabil

        wait;
    end process;
end sim;