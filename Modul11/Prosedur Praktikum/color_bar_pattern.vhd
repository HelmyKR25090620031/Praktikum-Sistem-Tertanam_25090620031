library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity color_bar_pattern is
    Port (
        h_count : in  integer range 0 to 799;
        v_count : in  integer range 0 to 524;
        rgb     : out STD_LOGIC_VECTOR (11 downto 0) -- 4-bit Red, 4-bit Green, 4-bit Blue
    );
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is
begin

    process(h_count, v_count)
    begin
        -- Pembagian 640 piksel menjadi 8 zona @ 80 piksel
        if h_count < 80 then
            rgb <= x"FFF"; -- Putih
        elsif h_count < 160 then
            rgb <= x"FF0"; -- Kuning
        elsif h_count < 240 then
            rgb <= x"0FF"; -- Cyan
        elsif h_count < 320 then
            rgb <= x"0F0"; -- Hijau
        elsif h_count < 400 then
            rgb <= x"F0F"; -- Magenta
        elsif h_count < 480 then
            rgb <= x"F00"; -- Merah
        elsif h_count < 560 then
            rgb <= x"00F"; -- Biru
        else
            rgb <= x"000"; -- Hitam
        end if;
    end process;

end Behavioral;