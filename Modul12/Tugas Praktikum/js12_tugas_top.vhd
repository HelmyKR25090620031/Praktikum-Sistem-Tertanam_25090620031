library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity js12_tugas_top is
    Port (
        clk     : in  STD_LOGIC;                    -- Clock 100 MHz (W5)
        PS2Clk  : in  STD_LOGIC;                    -- Pin C17
        PS2Data : in  STD_LOGIC;                    -- Pin B17
        led     : out STD_LOGIC_VECTOR (0 downto 0); -- Indikator tombol ditekan (LD0)
        an      : out STD_LOGIC_VECTOR (3 downto 0); -- Anoda Seven-Segment
        seg     : out STD_LOGIC_VECTOR (6 downto 0)  -- Katoda Seven-Segment
    );
end js12_tugas_top;

architecture Behavioral of js12_tugas_top is
    -- Tombol target untuk kontrol led(0): 'A' (Scan Code Set 2 = 0x1C)
    constant TARGET_KEY : STD_LOGIC_VECTOR (7 downto 0) := x"1C";

    signal scan_code_wire : STD_LOGIC_VECTOR (7 downto 0);
    signal data_ready     : STD_LOGIC;

    -- Register status make/break code
    signal is_break       : STD_LOGIC := '0';
    signal active_scancode: STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal ascii_wire     : STD_LOGIC_VECTOR (7 downto 0);
    signal led_status     : STD_LOGIC := '0';

    -- Sinyal multiplexing seven-segment
    signal refresh_cnt    : unsigned (19 downto 0) := (others => '0');
    signal active_digit   : STD_LOGIC_VECTOR (1 downto 0);
    signal hex_nibble     : STD_LOGIC_VECTOR (3 downto 0);
begin

    -- 1. Instansiasi Penerima PS/2
    PS2_INST : entity work.ps2_receiver
        port map (
            clk        => clk,
            ps2_clk    => PS2Clk,
            ps2_data   => PS2Data,
            scan_code  => scan_code_wire,
            data_ready => data_ready
        );

    -- 2. Instansiasi Lookup Table Scan Code -> ASCII
    ASCII_LUT : entity work.scancode_to_ascii
        port map (
            scan_code  => active_scancode,
            ascii_code => ascii_wire
        );

    -- 3. Logika Pemisah Make Code & Break Code (0xF0)
    process(clk)
    begin
        if rising_edge(clk) then
            if data_ready = '1' then
                if scan_code_wire = x"F0" then
                    -- Byte berikutnya adalah kode tombol yang dilepas
                    is_break <= '1';
                else
                    if is_break = '0' then
                        -- MAKE CODE: Tombol sedang ditekan
                        active_scancode <= scan_code_wire;
                        if scan_code_wire = TARGET_KEY then
                            led_status <= '1';
                        end if;
                    else
                        -- BREAK CODE: Tombol baru saja dilepas
                        is_break <= '0';
                        if scan_code_wire = TARGET_KEY then
                            led_status <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    led(0) <= led_status;

    -- 4. Pencacah Refresh Rate Seven-Segment
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    active_digit <= STD_LOGIC_VECTOR(refresh_cnt(19 downto 18));

    -- 5. Multiplexer 2 Digit Kanan untuk Menampilkan Heksadesimal ASCII
    process(active_digit, ascii_wire)
    begin
        case active_digit is
            when "00" =>
                an         <= "1110";                 -- Digit paling kanan (Nibble bawah ASCII)
                hex_nibble <= ascii_wire(3 downto 0);
            when "01" =>
                an         <= "1101";                 -- Digit kedua dari kanan (Nibble atas ASCII)
                hex_nibble <= ascii_wire(7 downto 4);
            when others =>
                an         <= "1111";                 -- Matikan digit kiri
                hex_nibble <= "0000";
        end case;
    end process;

    -- 6. Dekoder Heksadesimal ke Seven-Segment Active-Low
    process(hex_nibble)
    begin
        case hex_nibble is
            when x"0"   => seg <= "1000000"; -- 0
            when x"1"   => seg <= "1111001"; -- 1
            when x"2"   => seg <= "0100100"; -- 2
            when x"3"   => seg <= "0110000"; -- 3
            when x"4"   => seg <= "0011001"; -- 4
            when x"5"   => seg <= "0010010"; -- 5
            when x"6"   => seg <= "0000010"; -- 6
            when x"7"   => seg <= "1111000"; -- 7
            when x"8"   => seg <= "0000000"; -- 8
            when x"9"   => seg <= "0010000"; -- 9
            when x"A"   => seg <= "0001000"; -- A
            when x"B"   => seg <= "0000011"; -- b
            when x"C"   => seg <= "1000110"; -- C
            when x"D"   => seg <= "0100001"; -- d
            when x"E"   => seg <= "0000110"; -- E
            when x"F"   => seg <= "0001110"; -- F
            when others => seg <= "1111111";
        end case;
    end process;

end Behavioral;