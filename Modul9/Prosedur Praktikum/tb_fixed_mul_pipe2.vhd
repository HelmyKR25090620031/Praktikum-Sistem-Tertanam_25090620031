library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fixed_mul_pipe2 is
end tb_fixed_mul_pipe2;

architecture Behavioral of tb_fixed_mul_pipe2 is
    -- Sinyal Simulasi
    signal clk    : STD_LOGIC := '0';
    signal a      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal b      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR(15 downto 0);

    -- Periode Clock (100 MHz = 10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instansiasi Unit Under Test (UUT)
    uut: entity work.fixed_mul_pipe2
        port map (
            clk    => clk,
            a      => a,
            b      => b,
            result => result
        );

    -- Pembangkit Sinyal Clock (Wajib untuk Pipeline)
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Process Stimulus Pengujian
    stim_proc: process
    begin
        wait for 20 ns;

        -- Uji 1: 2.0 x 3.0 = 6.0 (Q8.8: 0x0200 x 0x0300 = 0x0600)
        a <= x"0200";
        b <= x"0300";
        wait for CLK_PERIOD * 2; -- Tunggu 2 siklus clock (latency pipeline)
        assert (result = x"0600") report "Uji 1 Gagal!" severity error;

        -- Uji 2: 1.5 x 4.0 = 6.0 (Q8.8: 0x0180 x 0x0400 = 0x0600)
        a <= x"0180";
        b <= x"0400";
        wait for CLK_PERIOD * 2; -- Tunggu 2 siklus clock (latency pipeline)
        assert (result = x"0600") report "Uji 2 Gagal!" severity error;

        wait;
    end process;

end Behavioral;