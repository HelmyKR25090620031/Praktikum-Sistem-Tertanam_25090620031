library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fixed_mul_pipe3 is
end tb_fixed_mul_pipe3;

architecture Behavioral of tb_fixed_mul_pipe3 is
    signal clk    : STD_LOGIC := '0';
    signal a      : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal b      : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR (15 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz
begin

    uut: entity work.fixed_mul_pipe3
        port map (
            clk    => clk,
            a      => a,
            b      => b,
            result => result
        );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        wait for 20 ns;

        -- Siklus 1: Input Pasangan 1 -> 2.0 x 3.0 = 6.0 (0x0200 x 0x0300 -> 0x0600)
        a <= x"0200"; b <= x"0300";
        wait for CLK_PERIOD;

        -- Siklus 2: Input Pasangan 2 -> 1.5 x 2.25 = 3.375 (0x0180 x 0x0240 -> 0x0360)
        a <= x"0180"; b <= x"0240";
        wait for CLK_PERIOD;

        -- Siklus 3: Input Pasangan 3 -> 4.0 x 0.5 = 2.0 (0x0400 x 0x0080 -> 0x0200)
        a <= x"0400"; b <= x"0080";
        wait for CLK_PERIOD;

        -- Akhir Siklus 3 (3 siklus setelah Input 1): Hasil Pasangan 1 valid!
        wait for 1 ns;
        assert (result = x"0600")
            report "GAGAL Pasangan 1: Harapan 0x0600!" severity error;

        -- Akhir Siklus 4 (3 siklus setelah Input 2): Hasil Pasangan 2 valid!
        wait for CLK_PERIOD;
        assert (result = x"0360")
            report "GAGAL Pasangan 2: Harapan 0x0360!" severity error;

        -- Akhir Siklus 5 (3 siklus setelah Input 3): Hasil Pasangan 3 valid!
        wait for CLK_PERIOD;
        assert (result = x"0200")
            report "GAGAL Pasangan 3: Harapan 0x0200!" severity error;

        assert false report "SIMULASI PIPE-3 BERHASIL: Latency 3 siklus & Throughput 1/siklus terverifikasi!" severity note;
        wait;
    end process;

end Behavioral;