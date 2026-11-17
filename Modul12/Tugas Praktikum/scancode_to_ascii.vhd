library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity scancode_to_ascii is
    Port (
        scan_code  : in  STD_LOGIC_VECTOR (7 downto 0);
        ascii_code : out STD_LOGIC_VECTOR (7 downto 0)
    );
end scancode_to_ascii;

architecture Behavioral of scancode_to_ascii is
begin

    with scan_code select
        ascii_code <=
            -- Angka '0' - '9' (ASCII 0x30 - 0x39)
            x"30" when x"45", -- '0'
            x"31" when x"16", -- '1'
            x"32" when x"1E", -- '2'
            x"33" when x"26", -- '3'
            x"34" when x"25", -- '4'
            x"35" when x"2E", -- '5'
            x"36" when x"36", -- '6'
            x"37" when x"3D", -- '7'
            x"38" when x"3E", -- '8'
            x"39" when x"46", -- '9'

            -- Huruf 'A' - 'Z' (ASCII 0x41 - 0x5A)
            x"41" when x"1C", -- 'A'
            x"42" when x"32", -- 'B'
            x"43" when x"21", -- 'C'
            x"44" when x"23", -- 'D'
            x"45" when x"24", -- 'E'
            x"46" when x"2B", -- 'F'
            x"47" when x"34", -- 'G'
            x"48" when x"33", -- 'H'
            x"49" when x"43", -- 'I'
            x"4A" when x"3B", -- 'J'
            x"4B" when x"42", -- 'K'
            x"4C" when x"4B", -- 'L'
            x"4D" when x"3A", -- 'M'
            x"4E" when x"31", -- 'N'
            x"4F" when x"44", -- 'O'
            x"50" when x"4D", -- 'P'
            x"51" when x"15", -- 'Q'
            x"52" when x"2D", -- 'R'
            x"53" when x"1B", -- 'S'
            x"54" when x"2C", -- 'T'
            x"55" when x"3C", -- 'U'
            x"56" when x"2A", -- 'V'
            x"57" when x"1D", -- 'W'
            x"58" when x"22", -- 'X'
            x"59" when x"35", -- 'Y'
            x"5A" when x"1A", -- 'Z'

            -- Spasi (ASCII 0x20)
            x"20" when x"29", -- Space

            -- Default jika tombol lain ditekan
            x"00" when others;

end Behavioral;