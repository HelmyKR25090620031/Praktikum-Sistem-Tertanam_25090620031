library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_leading_one_detector is
end tb_leading_one_detector;

architecture sim of tb_leading_one_detector is
    constant WIDTH_TB : integer := 8;
    signal din_tb   : STD_LOGIC_VECTOR(WIDTH_TB-1 downto 0) := (others => '0');
    signal pos_tb   : STD_LOGIC_VECTOR(2 downto 0);
    signal valid_tb : STD_LOGIC;
begin
    DUT: entity work.leading_one_detector
        generic map ( WIDTH => WIDTH_TB )
        port map (
            din   => din_tb,
            pos   => pos_tb,
            valid => valid_tb
        );

    stim_proc: process
    begin
        -- Pola 1: Tidak ada bit '1'
        din_tb <= "00000000"; wait for 20 ns;
        assert (valid_tb = '0' and pos_tb = "000")
            report "ERROR: Pola 1 (00000000) gagal!" severity error;

        -- Pola 2: Bit '1' di posisi index 0
        din_tb <= "00000001"; wait for 20 ns;
        assert (valid_tb = '1' and pos_tb = "000")
            report "ERROR: Pola 2 (00000001) gagal!" severity error;

        -- Pola 3: Bit '1' di posisi index 3
        din_tb <= "00001000"; wait for 20 ns;
        assert (valid_tb = '1' and pos_tb = "011")
            report "ERROR: Pola 3 (00001000) gagal!" severity error;

        -- Pola 4: Bit '1' di posisi index 7 (paling kiri)
        din_tb <= "10000000"; wait for 20 ns;
        assert (valid_tb = '1' and pos_tb = "111")
            report "ERROR: Pola 4 (10000000) gagal!" severity error;

        -- Pola 5: Bit '1' terdepan di posisi index 6 (mengabaikan bit 3)
        din_tb <= "01001000"; wait for 20 ns;
        assert (valid_tb = '1' and pos_tb = "110")
            report "ERROR: Pola 5 (01001000) gagal!" severity error;

        report "SIMULASI SELESAI: Seluruh pengujian leading_one_detector berhasil tanpa error!";
        wait;
    end process;
end sim;