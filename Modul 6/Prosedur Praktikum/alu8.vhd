library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
    Port (
        a      : in  STD_LOGIC_VECTOR (15 downto 0); -- Akumulator 16-bit
        b      : in  STD_LOGIC_VECTOR (7 downto 0);  -- Input angka dari sw(7 downto 0)
        mode   : in  STD_LOGIC;                     -- '0' = Tambah/Kurang, '1' = Kali/Bagi
        op     : in  STD_LOGIC;                     -- '0' = Tambah/Kali, '1' = Kurang/Bagi
        result : out STD_LOGIC_VECTOR (15 downto 0)  -- Hasil kalkulasi 16-bit
    );
end alu8;

architecture Behavioral of alu8 is
begin
    process(a, b, mode, op)
        variable val_a    : unsigned(15 downto 0);
        variable val_b    : unsigned(15 downto 0);
        variable res_temp : unsigned(15 downto 0);
        variable mult_res : unsigned(31 downto 0);
    begin
        val_a := unsigned(a);
        val_b := resize(unsigned(b), 16);

        if mode = '0' then
            -- MODE 1 (sw15 = 0): Penjumlahan & Pengurangan
            if op = '0' then
                res_temp := val_a + val_b;             -- Penjumlahan (+)
            else
                res_temp := val_a - val_b;             -- Pengurangan (-)
            end if;
        else
            -- MODE 2 (sw15 = 1): Perkalian & Pembagian
            if op = '0' then
                mult_res := val_a * val_b;             -- Perkalian (*)
                res_temp := mult_res(15 downto 0);    -- Ambil 16-bit terendah
            else
                if val_b = 0 then
                    res_temp := (others => '0');       -- Proteksi Pembagian dengan Nol
                else
                    res_temp := val_a / val_b;         -- Pembagian (/)
                end if;
            end if;
        end if;

        result <= std_logic_vector(res_temp);
    end process;
end Behavioral;