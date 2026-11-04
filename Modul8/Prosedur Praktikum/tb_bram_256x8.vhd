library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_256x8 is
end tb_bram_256x8;

architecture Behavioral of tb_bram_256x8 is
    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal din  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- Clock 100 MHz
begin

    -- Instansiasi UUT
    uut: entity work.bram_256x8
        port map (
            clk  => clk,
            we   => we,
            addr => addr,
            din  => din,
            dout => dout
        );

    -- Pembangkit Clock
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Pengujian
    stim_proc: process
    begin
        wait for 20 ns;

        ------------------------------------------------------------------
        -- 1. PROSES PENULISAN DATA (WRITE)
        ------------------------------------------------------------------
        we <= '1';
        
        -- Tulis Data 0xA5 ke Alamat 0x05
        addr <= x"05"; din <= x"A5";
        wait for CLK_PERIOD;
        
        -- Tulis Data 0x5C ke Alamat 0x0A
        addr <= x"0A"; din <= x"5C";
        wait for CLK_PERIOD;

        -- Tulis Data 0xFF ke Alamat 0xFF
        addr <= x"FF"; din <= x"FF";
        wait for CLK_PERIOD;

        ------------------------------------------------------------------
        -- 2. PROSES PEMBACAAN DATA (READ) & VERIFIKASI ASSERT
        ------------------------------------------------------------------
        we <= '0';

        -- Baca Alamat 0x05
        addr <= x"05";
        wait for CLK_PERIOD * 2; -- Tunggu 1 siklus untuk latency registered output
        assert (dout = x"A5") report "Gagal membaca alamat 0x05!" severity error;

        -- Baca Alamat 0x0A
        addr <= x"0A";
        wait for CLK_PERIOD;
        assert (dout = x"5C") report "Gagal membaca alamat 0x0A!" severity error;

        -- Baca Alamat 0xFF
        addr <= x"FF";
        wait for CLK_PERIOD;
        assert (dout = x"FF") report "Gagal membaca alamat 0xFF!" severity error;

        wait;
    end process;

end Behavioral;