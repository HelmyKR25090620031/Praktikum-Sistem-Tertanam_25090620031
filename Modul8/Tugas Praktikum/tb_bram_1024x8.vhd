library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_1024x8 is
end tb_bram_1024x8;

architecture Behavioral of tb_bram_1024x8 is
    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');
    signal din  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR (7 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin

    uut: entity work.bram_1024x8
        port map (
            clk  => clk,
            we   => we,
            addr => addr,
            din  => din,
            dout => dout
        );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        wait for 20 ns;

        -- 1. Tulis data ke alamat 0, 512, dan 1023
        we   <= '1';
        addr <= std_logic_vector(to_unsigned(0, 10));
        din  <= x"AA";
        wait for CLK_PERIOD;

        addr <= std_logic_vector(to_unsigned(512, 10));
        din  <= x"55";
        wait for CLK_PERIOD;

        addr <= std_logic_vector(to_unsigned(1023, 10));
        din  <= x"F0";
        wait for CLK_PERIOD;

        we <= '0';

        -- 2. Baca kembali dan verifikasi (tunggu 1 siklus clock setelah alamat diberikan)
        addr <= std_logic_vector(to_unsigned(0, 10));
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert (dout = x"AA") report "Error pada alamat 0!" severity error;

        addr <= std_logic_vector(to_unsigned(512, 10));
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert (dout = x"55") report "Error pada alamat 512!" severity error;

        addr <= std_logic_vector(to_unsigned(1023, 10));
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert (dout = x"F0") report "Error pada alamat 1023!" severity error;

        assert false report "SIMULASI BRAM 1024x8 BERHASIL!" severity note;
        wait;
    end process;

end Behavioral;