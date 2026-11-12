library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity color_pattern_tugas is
    Port (
        h_count : in  integer range 0 to 799;
        v_count : in  integer range 0 to 524;
        sw      : in  STD_LOGIC_VECTOR (3 downto 0); -- Switch geser posisi kotak
        rgb     : out STD_LOGIC_VECTOR (11 downto 0)
    );
end color_pattern_tugas;

architecture Behavioral of color_pattern_tugas is
    signal box_x      : integer;
    signal h_u, v_u   : unsigned(9 downto 0);
    constant BOX_Y    : integer := 215; -- Posisi vertikal di tengah layar (height 50)
    constant BOX_SIZE : integer := 50;  -- Ukuran kotak 50x50 piksel
begin

    -- Konversi tipe integer ke unsigned 10-bit agar bisa diindeks per bit
    h_u <= to_unsigned(h_count, 10);
    v_u <= to_unsigned(v_count, 10);

    -- Menghitung posisi X kotak berdasarkan nilai switch (sw * 35 piksel)
    box_x <= to_integer(unsigned(sw)) * 35 + 50;

    process(h_count, v_count, h_u, v_u, box_x)
    begin
        -- 1. DETEKSI AREA KOTAK INTERAKTIF
        if (h_count >= box_x and h_count < box_x + BOX_SIZE) and
           (v_count >= BOX_Y and v_count < BOX_Y + BOX_SIZE) then
            rgb <= x"FF0"; -- Kotak Berwarna Kuning Terang

        -- 2. LATAR BELAKANG PAPAN CATUR (CHECKERBOARD PATTERN)
        else
            -- Menggunakan bit ke-5 dari sinyal unsigned untuk kisi 32x32 piksel
            if (h_u(5) xor v_u(5)) = '1' then
                rgb <= x"FFF"; -- Blok Putih
            else
                rgb <= x"00F"; -- Blok Biru
            end if;
        end if;
    end process;

end Behavioral;