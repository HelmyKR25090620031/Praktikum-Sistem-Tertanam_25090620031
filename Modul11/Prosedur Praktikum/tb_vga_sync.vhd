library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_vga_sync is
end tb_vga_sync;

architecture Behavioral of tb_vga_sync is
    signal pclk     : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '0';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_count  : integer range 0 to 799;
    signal v_count  : integer range 0 to 524;

    -- Periode Pixel Clock 25 MHz (40 ns)
    constant PCLK_PERIOD : time := 40 ns;
begin

    -- Instansiasi Unit Under Test (UUT)
    uut: entity work.vga_sync
        port map (
            pclk     => pclk,
            rst      => rst,
            hsync    => hsync,
            vsync    => vsync,
            video_on => video_on,
            h_count  => h_count,
            v_count  => v_count
        );

    -- Pembangkit Clock 25 MHz
    pclk_process : process
    begin
        pclk <= '0'; wait for PCLK_PERIOD / 2;
        pclk <= '1'; wait for PCLK_PERIOD / 2;
    end process;

    -- Stimulus Pengujian
    stim_proc: process
    begin
        -- Assert Reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        
        -- Simulasi berjalan selama 1 frame penuh (~16.6 ms)
        wait for 17 ms;

        -- Verifikasi bahwa h_count dan v_count melakukan reset kembali ke 0
        assert (h_count < 800) report "Error: H_count melebihi total!" severity error;
        assert (v_count < 525) report "Error: V_count melebihi total!" severity error;

        wait;
    end process;

end Behavioral;