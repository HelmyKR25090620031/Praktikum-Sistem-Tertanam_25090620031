library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fixed_mul_q8_8 is
end tb_fixed_mul_q8_8;

architecture Behavioral of tb_fixed_mul_q8_8 is
    signal a, b   : STD_LOGIC_VECTOR(15 downto 0);
    signal result : STD_LOGIC_VECTOR(15 downto 0);
begin
    -- Instansiasi Unit Under Test (UUT)
    uut: entity work.fixed_mul_q8_8
        port map (a => a, b => b, result => result);

    stim_proc: process
    begin
        -- Uji 1: 2.0 x 3.0 = 6.0 (Q8.8: 0x0200 x 0x0300 = 0x0600)
        a <= x"0200"; b <= x"0300";
        wait for 10 ns;
        assert (result = x"0600") report "Uji 1 Gagal!" severity error;

        -- Uji 2: 1.5 x 4.0 = 6.0 (Q8.8: 0x0180 x 0x0400 = 0x0600)
        a <= x"0180"; b <= x"0400";
        wait for 10 ns;
        assert (result = x"0600") report "Uji 2 Gagal!" severity error;

        wait;
    end process;
end Behavioral;     