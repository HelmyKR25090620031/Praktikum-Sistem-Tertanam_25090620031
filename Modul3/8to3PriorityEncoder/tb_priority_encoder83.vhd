library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_priority_encoder83 is
end tb_priority_encoder83;

architecture sim of tb_priority_encoder83 is
    signal sw_tb  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal led_tb : STD_LOGIC_VECTOR(3 downto 0);
begin
    -- Instansiasi Device Under Test (DUT)
    DUT: entity work.priority_encoder83
        port map (
            sw  => sw_tb,
            led => led_tb
        );

    stim_proc: process
    begin
        -- Test 1: Tidak ada switch aktif (Valid = '0')
        sw_tb <= "00000000"; wait for 20 ns;
        assert (led_tb = "0000") report "ERROR: Test 1 Gagal!" severity error;

        -- Test 2: Hanya bit 0 yang aktif (Posisi = 0, Valid = '1')
        sw_tb <= "00000001"; wait for 20 ns;
        assert (led_tb = "1000") report "ERROR: Test 2 Gagal!" severity error;

        -- Test 3: Banyak bit aktif (bit 3 dan bit 1 -> Pilih bit 3)
        sw_tb <= "00001010"; wait for 20 ns;
        assert (led_tb = "1011") report "ERROR: Test 3 Gagal!" severity error;

        -- Test 4: Uji bit 6 aktif bersamaan dengan bit 4
        sw_tb <= "01010000"; wait for 20 ns;
        assert (led_tb = "1110") report "ERROR: Test 4 Gagal!" severity error;

        -- Test 5: Bit tertinggi MSB (bit 7) aktif bersamaan dengan bit lainnya
        sw_tb <= "11111111"; wait for 20 ns;
        assert (led_tb = "1111") report "ERROR: Test 5 Gagal!" severity error;

        report "SIMULASI SELESAI: Seluruh pengujian Priority Encoder 8-ke-3 Berhasil!";
        wait;
    end process;
end sim;