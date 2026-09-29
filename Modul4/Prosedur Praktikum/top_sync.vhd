library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_sync is
    Port (
        clk  : in  STD_LOGIC; -- Clock 100 MHz (Pin W5)
        btnC : in  STD_LOGIC; -- Tombol tengah (Input asinkron)
        led0 : out STD_LOGIC  -- LED 0 (Keluaran toggle)
    );
end top_sync;

architecture Behavioral of top_sync is
    signal sync_out  : STD_LOGIC := '0';
    signal sync_prev : STD_LOGIC := '0';
    signal led_reg   : STD_LOGIC := '0';
begin
    -- Instansiasi Synchronizer 2-Tingkat
    SYNC_INST: entity work.synchronizer_2ff
        port map (
            clk      => clk,
            async_in => btnC,
            sync_out => sync_out
        );

    -- Logika Pendeteksi Transisi ('0' ke '1') & Toggle LED
    process(clk)
    begin
        if rising_edge(clk) then
            -- Register menyimpan nilai sync_out siklus sebelumnya
            sync_prev <= sync_out;

            -- Deteksi transisi dari '0' ke '1' (Rising Edge)
            if (sync_out = '1' and sync_prev = '0') then
                led_reg <= not led_reg; -- Ubah status LED (Toggle)
            end if;
        end if;
    end process;

    led0 <= led_reg;
end Behavioral;