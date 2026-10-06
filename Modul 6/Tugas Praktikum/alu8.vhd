library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
    Port (
        a      : in  STD_LOGIC_VECTOR (15 downto 0);
        b      : in  STD_LOGIC_VECTOR (7 downto 0);
        op     : in  STD_LOGIC;                     -- '0' = Tambah, '1' = Kurang
        result : out STD_LOGIC_VECTOR (15 downto 0) -- Output 16-bit untuk display
    );
end alu8;

architecture Behavioral of alu8 is
begin
    process(a, b, op)
        variable res_temp : unsigned(8 downto 0);
    begin
        if op = '0' then
            res_temp := resize(unsigned(a), 9) + resize(unsigned(b), 9);
        else
            res_temp := resize(unsigned(a), 9) - resize(unsigned(b), 9);
        end if;
        result <= std_logic_vector(resize(res_temp, 16));
    end process;
end Behavioral;