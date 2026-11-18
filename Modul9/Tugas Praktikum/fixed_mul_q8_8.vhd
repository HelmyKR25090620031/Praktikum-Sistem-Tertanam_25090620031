library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc_temp_q8_8 is
    Port (
        clk : in  STD_LOGIC;                     -- Clock 100 MHz (W5)
        sw  : in  STD_LOGIC_VECTOR (11 downto 0); -- Simulasi ADC 12-bit (SW11..SW0)
        led : out STD_LOGIC_VECTOR (15 downto 0); -- Output biner mentah Q8.8 (LD15..LD0)
        an  : out STD_LOGIC_VECTOR (3 downto 0);  -- Anoda Seven-Segment
        seg : out STD_LOGIC_VECTOR (6 downto 0);  -- Katoda Seven-Segment (CA..CG)
        dp  : out STD_LOGIC                       -- Titik Desimal Seven-Segment
    );
end adc_temp_q8_8;

architecture Behavioral of adc_temp_q8_8 is
    -- Faktor skala linear 0..4095 -> 0..100.00 C dalam Q8.8:
    -- (100 / 4096) * 256 = 6.25 -> dalam Q8.8 = 6.25 * 256 = 1600 (0x0640)
    constant SCALE_Q8_8 : unsigned (15 downto 0) := x"0640";

    signal mult_full    : unsigned (27 downto 0); -- 12-bit * 16-bit = 28-bit
    signal temp_q8_8    : unsigned (15 downto 0); -- Hasil suhu format Q8.8

    -- Sinyal konversi BCD untuk tampilan XX.XX C
    signal int_part     : integer range 0 to 255;
    signal frac_part    : integer range 0 to 99;
    signal d3, d2, d1, d0 : integer range 0 to 9;

    -- Sinyal multiplexing seven-segment
    signal refresh_cnt  : unsigned (19 downto 0) := (others => '0');
    signal active_digit : STD_LOGIC_VECTOR (1 downto 0);
    signal bcd_digit    : integer range 0 to 9;
begin

    -- 1. Operasi Perkalian Fixed-Point & Scaling (Geser kanan 8 bit)
    mult_full <= unsigned(sw) * SCALE_Q8_8;
    temp_q8_8 <= mult_full(23 downto 8);

    -- Tampilkan representasi biner Q8.8 pada 16 LED onboard
    led <= STD_LOGIC_VECTOR(temp_q8_8);

    -- 2. Pemisahan Bagian Bulat (8 bit atas) & Pecahan (8 bit bawah) ke Desimal
    int_part  <= to_integer(temp_q8_8(15 downto 8));
    frac_part <= (to_integer(temp_q8_8(7 downto 0)) * 100) / 256;

    d3 <= int_part / 10;     -- Puluhan derajat
    d2 <= int_part mod 10;   -- Satuan derajat
    d1 <= frac_part / 10;    -- Persepuluhan derajat
    d0 <= frac_part mod 10;  -- Perseratusan derajat

    -- 3. Pencacah Refresh Rate Seven-Segment
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    active_digit <= STD_LOGIC_VECTOR(refresh_cnt(19 downto 18));

    -- 4. Multiplexer 4 Digit (Format: d3 d2 . d1 d0)
    process(active_digit, d3, d2, d1, d0)
    begin
        case active_digit is
            when "00" =>
                an        <= "1110"; -- AN0 (Paling kanan)
                bcd_digit <= d0;
                dp        <= '1';    -- Titik mati
            when "01" =>
                an        <= "1101"; -- AN1
                bcd_digit <= d1;
                dp        <= '1';
            when "10" =>
                an        <= "1011"; -- AN2 (Satuan + Titik Desimal)
                bcd_digit <= d2;
                dp        <= '0';    -- Titik desimal aktif (active-low)
            when others =>
                an        <= "0111"; -- AN3 (Paling kiri)
                bcd_digit <= d3;
                dp        <= '1';
        end case;
    end process;

    -- 5. Dekoder BCD ke Seven-Segment Active-Low
    process(bcd_digit)
    begin
        case bcd_digit is
            when 0      => seg <= "1000000";
            when 1      => seg <= "1111001";
            when 2      => seg <= "0100100";
            when 3      => seg <= "0110000";
            when 4      => seg <= "0011001";
            when 5      => seg <= "0010010";
            when 6      => seg <= "0000010";
            when 7      => seg <= "1111000";
            when 8      => seg <= "0000000";
            when 9      => seg <= "0010000";
            when others => seg <= "1111111";
        end case;
    end process;

end Behavioral;