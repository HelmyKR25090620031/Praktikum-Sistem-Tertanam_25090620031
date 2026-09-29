library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic (
        DIGITS      : integer := 4;
        CLK_FREQ_HZ : integer := 100_000_000
    );
    Port (
        clk     : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR (15 downto 0); -- Input 16-bit (4 digit @ 4-bit)
        seg     : out STD_LOGIC_VECTOR (6 downto 0); -- Katoda bersama (aktif-rendah)
        dp      : out STD_LOGIC;                     -- Titik desimal (aktif-rendah)
        an      : out STD_LOGIC_VECTOR (3 downto 0)  -- Anoda digit (aktif-rendah)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    -- Pembagi Clock: 100 MHz / 1.000 = 100.000 siklus (1 kHz refresh rate per digit)
    constant REFRESH_LIMIT : integer := CLK_FREQ_HZ / 1000 - 1;
    signal refresh_cnt     : integer range 0 to REFRESH_LIMIT := 0;
    signal digit_select    : unsigned(1 downto 0) := "00";
    signal current_digit   : unsigned(3 downto 0) := "0000";

    -- Fungsi konversi BCD ke pola seven-segment (aktif-rendah) sesuai Kode 5.3
    function bcd_to_seg(digit : unsigned(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "0111111"; -- '-' (nilai tak terdefinisi)
        end case;
    end function;

begin
    -- Matikan titik desimal (aktif-rendah = '1')
    dp <= '1';

    -- Pencacah pembagi clock untuk pemindaian digit (multiplexing)
    process(clk)
    begin
        if rising_edge(clk) then
            if refresh_cnt = REFRESH_LIMIT then
                refresh_cnt <= 0;
                digit_select <= digit_select + 1;
            else
                refresh_cnt <= refresh_cnt + 1;
            end if;
        end if;
    end process;

    -- Pemilihan Digit Aktif & Pengaturan Anoda (Common Anode / Aktif Rendah)
    process(digit_select, data_in)
    begin
        case digit_select is
            when "00" =>
                an <= "1110"; -- Nyalakan Digit 0 (paling kanan / AN0)
                current_digit <= unsigned(data_in(3 downto 0));
            when "01" =>
                an <= "1101"; -- Nyalakan Digit 1 (AN1)
                current_digit <= unsigned(data_in(7 downto 4));
            when "10" =>
                an <= "1011"; -- Nyalakan Digit 2 (AN2)
                current_digit <= unsigned(data_in(11 downto 8));
            when "11" =>
                an <= "0111"; -- Nyalakan Digit 3 (paling kiri / AN3)
                current_digit <= unsigned(data_in(15 downto 12));
            when others =>
                an <= "1111";
                current_digit <= "0000";
        end case;
    end process;

    -- Terjemahkan BCD Digit terpilih ke pola katoda
    seg <= bcd_to_seg(current_digit);

end Behavioral;