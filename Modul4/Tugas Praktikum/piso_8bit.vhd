library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_8bit is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        load : in  STD_LOGIC;                      -- '1' = Load Paralel, '0' = Pergeseran Serial
        d    : in  STD_LOGIC_VECTOR (7 downto 0); -- Input paralel sw(7 downto 0)
        sout : out STD_LOGIC                       -- Output serial ke led(0)
    );
end piso_8bit;

architecture Behavioral of piso_8bit is
    signal shift_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift_reg <= (others => '0');
            elsif load = '1' then
                -- Pemuatan data paralel
                shift_reg <= d;
            else
                -- Pergeseran serial ke kiri (MSB digeser keluar lebih dulu)
                shift_reg <= shift_reg(6 downto 0) & '0';
            end if;
        end if;
    end process;

    -- Bit paling kiri (MSB / index 7) dihubungkan langsung ke output serial
    sout <= shift_reg(7);
end Behavioral;