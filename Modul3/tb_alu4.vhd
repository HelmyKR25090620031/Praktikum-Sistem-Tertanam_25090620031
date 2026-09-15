library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu4 is
end tb_alu4;

architecture sim of tb_alu4 is
    signal a_tb      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b_tb      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode_tb : STD_LOGIC := '0';
    signal result_tb : STD_LOGIC_VECTOR(3 downto 0);
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
        a_tb <= "0111"; b_tb <= "0001"; opcode_tb <= '0'; wait for 20 ns;
        assert (result_tb = "1000" and carry_tb = '0')
            report "ERROR: Test 1 (Penjumlahan 7+1) Gagal!" severity error;

        -- Test 2: Penjumlahan dengan carry (12 + 5 = 17 -> result=1, carry=1)
        a_tb <= "1100"; b_tb <= "0101"; opcode_tb <= '0'; wait for 20 ns;
        assert (result_tb = "0001" and carry_tb = '1')
            report "ERROR: Test 2 (Penjumlahan 12+5) Gagal!" severity error;

        -- Test 3: Pengurangan tanpa borrow (10 - 3 = 7)
        a_tb <= "1010"; b_tb <= "0011"; opcode_tb <= '1'; wait for 20 ns;
        assert (result_tb = "0111" and carry_tb = '0')
            report "ERROR: Test 3 (Pengurangan 10-3) Gagal!" severity error;

        -- Test 4: Pengurangan dengan nilai a < b (2 - 5)
        a_tb <= "0010"; b_tb <= "0101"; opcode_tb <= '1'; wait for 20 ns;
        assert (result_tb = "1101" and carry_tb = '1')
            report "ERROR: Test 4 (Pengurangan 2-5) Gagal!" severity error;

        -- Test 5: Penjumlahan nilai maksimum (15 + 15 = 30 -> result=14, carry=1)
        a_tb <= "1111"; b_tb <= "1111"; opcode_tb <= '0'; wait for 20 ns;
        assert (result_tb = "1110" and carry_tb = '1')
            report "ERROR: Test 5 (Penjumlahan 15+15) Gagal!" severity error;

        report "SIMULASI SELESAI: Seluruh pengujian alu4 berhasil tanpa error!";
        wait;
    end process;
end sim;