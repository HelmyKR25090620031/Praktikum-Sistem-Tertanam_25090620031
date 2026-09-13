library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mux4to1 is
end tb_mux4to1;

architecture sim of tb_mux4to1 is
    signal sel_tb : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal in0_tb : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- 1
    signal in1_tb : STD_LOGIC_VECTOR(3 downto 0) := "0100"; -- 4
    signal in2_tb : STD_LOGIC_VECTOR(3 downto 0) := "1000"; -- 8
    signal in3_tb : STD_LOGIC_VECTOR(3 downto 0) := "1111"; -- 15
    signal y_tb   : STD_LOGIC_VECTOR(3 downto 0);
begin
    DUT: entity work.mux4to1
        port map (
            sel => sel_tb,
            in0 => in0_tb,
            in1 => in1_tb,
            in2 => in2_tb,
            in3 => in3_tb,
            y   => y_tb
        );

    stim_proc: process
    begin
        -- Skenario 1: sel = "00"
        sel_tb <= "00"; wait for 50 ns;
        assert (y_tb = in0_tb)
            report "ERROR: sel=00 gagal, nilai y_tb tidak sesuai in0_tb" severity error;

        -- Skenario 2: sel = "01"
        sel_tb <= "01"; wait for 50 ns;
        assert (y_tb = in1_tb)
            report "ERROR: sel=01 gagal, nilai y_tb tidak sesuai in1_tb" severity error;

        -- Skenario 3: sel = "10"
        sel_tb <= "10"; wait for 50 ns;
        assert (y_tb = in2_tb)
            report "ERROR: sel=10 gagal, nilai y_tb tidak sesuai in2_tb" severity error;

        -- Skenario 4: sel = "11"
        sel_tb <= "11"; wait for 50 ns;
        assert (y_tb = in3_tb)
            report "ERROR: sel=11 gagal, nilai y_tb tidak sesuai in3_tb" severity error;

        report "SIMULASI SELESAI: Seluruh pengujian MUX 4-to-1 berhasil tanpa error!";
        wait;
    end process;
end sim;