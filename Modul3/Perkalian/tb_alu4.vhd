library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu4 is
end tb_alu4;

architecture sim of tb_alu4 is
    signal a_tb      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b_tb      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode_tb : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- Disesuaikan jadi 2-bit
    signal result_tb : STD_LOGIC_VECTOR(7 downto 0);        -- Disesuaikan jadi 8-bit
    signal carry_tb  : STD_LOGIC;
begin
    -- Instansiasi Device Under Test (DUT)
    DUT: entity work.alu4
        port map (
            a      => a_tb,
            b      => b_tb,
            opcode => opcode_tb,
            result => result_tb,
            carry  => carry_tb
        );

    -- Proses Stimulus
    stim_proc: process
    begin
        -- Test 1: Penjumlahan tanpa carry (7 + 1 = 8)
        a_tb <= "0111"; b_tb <= "0001"; opcode_tb <= "00"; wait for 20 ns;
        assert (result_tb = "00001000" and carry_tb = '0')
            report "ERROR: Test 1 (Penjumlahan 7+1) Gagal!" severity error;

        -- Test 2: Penjumlahan dengan carry (12 + 5 = 17)
        a_tb <= "1100"; b_tb <= "0101"; opcode_tb <= "00"; wait for 20 ns;
        assert (result_tb = "00010001" and carry_tb = '1')
            report "ERROR: Test 2 (Penjumlahan 12+5) Gagal!" severity error;

        -- Test 3: Pengurangan (10 - 3 = 7)
        a_tb <= "1010"; b_tb <= "0011"; opcode_tb <= "01"; wait for 20 ns;
        assert (result_tb = "00000111" and carry_tb = '0')
            report "ERROR: Test 3 (Pengurangan 10-3) Gagal!" severity error;

        -- Test 4: Perkalian Dasar (3 x 4 = 12)
        a_tb <= "0011"; b_tb <= "0100"; opcode_tb <= "10"; wait for 20 ns;
        assert (result_tb = "00001100" and carry_tb = '0')
            report "ERROR: Test 4 (Perkalian 3x4) Gagal!" severity error;

        -- Test 5: Perkalian Maksimum (15 x 15 = 225 -> "11100001")
        a_tb <= "1111"; b_tb <= "1111"; opcode_tb <= "10"; wait for 20 ns;
        assert (result_tb = "11100001" and carry_tb = '0')
            report "ERROR: Test 5 (Perkalian 15x15) Gagal!" severity error;

        report "SIMULASI SELESAI: Seluruh pengujian alu4 (Penjumlahan, Pengurangan, Perkalian) Berhasil!";
        wait;
    end process;
end sim;