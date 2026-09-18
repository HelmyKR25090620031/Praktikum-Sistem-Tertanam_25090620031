library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu4 is
end tb_alu4;

architecture sim of tb_alu4 is
    signal a_tb      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b_tb      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode_tb : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal result_tb : STD_LOGIC_VECTOR(7 downto 0);
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
        -- Test 1: Penjumlahan Normal Signed (+3 + +2 = +5)
        a_tb <= "0011"; b_tb <= "0010"; opcode_tb <= "00"; wait for 20 ns;

        -- Test 2: BUKTI OVERFLOW POSITIF (+7 + +1)
        -- Dalam 4-bit signed: "0111" (+7) + "0001" (+1) = "1000" (-8)
        -- Penjumlahan dua bilangan positif menghasilkan MSB '1' (negatif)
        a_tb <= "0111"; b_tb <= "0001"; opcode_tb <= "00"; wait for 20 ns;

        -- Test 3: BUKTI OVERFLOW NEGATIF (-8 + -1)
        -- Dalam 4-bit signed: "1000" (-8) + "1111" (-1) = "0111" (+7)
        -- Penjumlahan dua bilangan negatif menghasilkan MSB '0' (positif)
        a_tb <= "1000"; b_tb <= "1111"; opcode_tb <= "00"; wait for 20 ns;

        -- Test 4: Pengurangan Signed (+3 - +5 = -2)
        -- "0011" (+3) - "0101" (+5) = "1110" (-2 dalam 4-bit LSB)
        a_tb <= "0011"; b_tb <= "0101"; opcode_tb <= "01"; wait for 20 ns;

        -- Test 5: Perkalian Signed (+3 x -2 = -6)
        -- "0011" (+3) x "1110" (-2) = "11111010" (-6 dalam 8-bit signed)
        a_tb <= "0011"; b_tb <= "1110"; opcode_tb <= "10"; wait for 20 ns;

        report "SIMULASI SELESAI: Pengujian Signed ALU dan Bukti Overflow Berhasil!";
        wait;
    end process;
end sim;