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
    constant REFRESH_LIMIT : integer := CLK_FREQ_HZ / 1000 - 1;
    signal refresh_cnt     : integer range 0 to REFRESH_LIMIT := 0;
    signal digit_select    : unsigned(1 downto 0) := "00";
    signal current_digit   : unsigned(3 downto 0) := "0000";

    -- Fungsi Konversi Heksadesimal (0-F) ke Pola Seven-Segment (gfedcba) Aktif-Rendah
    function hex_to_seg(digit : unsigned(3 downto 0)) return STD_LOGIC_VECTOR is
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
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000110"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when "1111" => return "0001110"; -- F
            when others => return "0111111"; -- '-'
        end case;
    end function;

begin
    dp <= '1'; -- Matikan titik desimal

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

    process(digit_select, data_in)
    begin
        case digit_select is
            when "00" =>
                an <= "1110"; -- Digit 0 (Paling kanan)
                current_digit <= unsigned(data_in(3 downto 0));
            when "01" =>
                an <= "1101"; -- Digit 1
                current_digit <= unsigned(data_in(7 downto 4));
            when "10" =>
                an <= "1011"; -- Digit 2
                current_digit <= unsigned(data_in(11 downto 8));
            when "11" =>
                an <= "0111"; -- Digit 3 (Paling kiri)
                current_digit <= unsigned(data_in(15 downto 12));
            when others =>
                an <= "1111";
                current_digit <= "0000";
        end case;
    end process;

    seg <= hex_to_seg(current_digit);

end Behavioral;