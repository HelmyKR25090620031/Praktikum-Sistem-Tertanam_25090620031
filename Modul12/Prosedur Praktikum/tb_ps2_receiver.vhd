library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ps2_receiver is
end tb_ps2_receiver;

architecture Behavioral of tb_ps2_receiver is
    signal clk        : STD_LOGIC := '0';
    signal ps2_clk    : STD_LOGIC := '1';
    signal ps2_data   : STD_LOGIC := '1';
    signal scan_code  : STD_LOGIC_VECTOR (7 downto 0);
    signal data_ready : STD_LOGIC;

    constant CLK_PERIOD     : time := 10 ns; -- Clock FPGA 100 MHz
    constant PS2_HALF_PERIOD : time := 30 us; -- Total periode 60 us (~16.7 kHz)

    -- Frame 11-bit untuk Scan Code 0x1C (Tombol 'A'):
    -- Bit 0: Start = '0'
    -- Bit 1..8: 0x1C (00011100) dikirim LSB dulu -> 0,0,1,1,1,0,0,0
    -- Bit 9: Odd Parity = '0' (jumlah '1' sudah ganjil = 3)
    -- Bit 10: Stop = '1'
    constant FRAME_1C : STD_LOGIC_VECTOR(0 to 10) := "00011100001";
begin

    uut: entity work.ps2_receiver
        port map (
            clk        => clk,
            ps2_clk    => ps2_clk,
            ps2_data   => ps2_data,
            scan_code  => scan_code,
            data_ready => data_ready
        );

    -- Pembangkit Clock Sistem 100 MHz
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Pengiriman 1 Frame PS/2 (11-bit)
    stim_proc: process
    begin
        ps2_clk  <= '1';
        ps2_data <= '1';
        wait for 100 us;

        -- Kirim bit 0 sampai bit 9
        for i in 0 to 9 loop
            ps2_data <= FRAME_1C(i);
            wait for PS2_HALF_PERIOD;
            ps2_clk  <= '0'; -- Tepi turun: data disampel FPGA
            wait for PS2_HALF_PERIOD;
            ps2_clk  <= '1';
        end loop;

        -- Kirim bit 10 (Stop bit) dan verifikasi output
        ps2_data <= FRAME_1C(10);
        wait for PS2_HALF_PERIOD;
        ps2_clk  <= '0';

        -- Tunggu pulsa data_ready muncul setelah synchronizer (maks 200 ns)
        wait until data_ready = '1' for 200 ns;
        assert (data_ready = '1')
            report "GAGAL: Pulsa data_ready tidak aktif setelah 11 bit!" severity error;
        assert (scan_code = x"1C")
            report "GAGAL: Scan code tidak sesuai (harapan 0x1C)!" severity error;

        wait for PS2_HALF_PERIOD;
        ps2_clk  <= '1';
        ps2_data <= '1';

        wait for 100 us;
        assert false report "SIMULASI SELESAI: Frame PS/2 0x1C berhasil diverifikasi!" severity note;
        wait;
    end process;

end Behavioral;