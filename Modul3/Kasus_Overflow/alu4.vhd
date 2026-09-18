library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu4 is
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode : in  STD_LOGIC_VECTOR (1 downto 0); -- "00"=tambah, "01"=kurang, "10"=kali
           result : out STD_LOGIC_VECTOR (7 downto 0); -- Lebar 8-bit untuk menampung perkalian
           carry  : out STD_LOGIC );
end alu4;

architecture Behavioral of alu4 is
    signal a_u, b_u : signed(3 downto 0);
begin
    a_u <= signed(a); -- Ubah menjadi signed untuk kasus overflow
    b_u <= signed(b); -- Ubah menjadi signed untuk kasus overflow
-- jangan lupa kembalikan ke unsigned ketika sudah mencoba kasus overflow
    process(a_u, b_u, opcode)
        variable sum_ext  : signed(4 downto 0);
        variable mult_ext : signed(7 downto 0);
    begin
        case opcode is
            when "00" => -- Penjumlahan
                sum_ext := ('0' & a_u) + ('0' & b_u);
                result  <= "000" & STD_LOGIC_VECTOR(sum_ext);
                carry   <= sum_ext(4);

            when "01" => -- Pengurangan
                sum_ext := ('0' & a_u) - ('0' & b_u);
                result  <= "0000" & STD_LOGIC_VECTOR(sum_ext(3 downto 0));
                carry   <= sum_ext(4);

            when "10" => -- Perkalian
                mult_ext := a_u * b_u;
                result   <= STD_LOGIC_VECTOR(mult_ext);
                carry    <= '0'; -- Tidak ada carry terpisah untuk perkalian 8-bit

            when others =>
                result <= (others => '0');
                carry  <= '0';
        end case;
    end process;
end Behavioral;