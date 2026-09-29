library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity updown_counter is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC; -- Terhubung ke btnC_db (Reset)
        inc_pulse : in  STD_LOGIC; -- Pulsa 1-siklus dari edge_detect(btnU)
        dec_pulse : in  STD_LOGIC; -- Pulsa 1-siklus dari edge_detect(btnD)
        count_out : out STD_LOGIC_VECTOR (15 downto 0) -- Keluaran data 16-bit
    );
end updown_counter;

architecture Behavioral of updown_counter is
    signal count_reg : unsigned(15 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_reg <= (others => '0');
            elsif inc_pulse = '1' then
                count_reg <= count_reg + 1;
            elsif dec_pulse = '1' then
                count_reg <= count_reg - 1;
            end if;
        end if;
    end process;

    count_out <= std_logic_vector(count_reg);

end Behavioral;