library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer_2ff is
    Port ( 
        clk      : in  STD_LOGIC;
        async_in : in  STD_LOGIC; -- Sinyal asinkron dari tombol
        sync_out : out STD_LOGIC  -- Sinyal yang sudah tersinkronisasi
    );
end synchronizer_2ff;

architecture Behavioral of synchronizer_2ff is
    signal ff1, ff2 : STD_LOGIC := '0';
    
    -- Atribut agar Vivado tidak mengoptimasi/menghapus flip-flop berantai
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of ff1 : signal is "TRUE";
    attribute ASYNC_REG of ff2 : signal is "TRUE";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            ff1 <= async_in; -- Tingkat 1: menyerap risiko metastabilitas
            ff2 <= ff1;      -- Tingkat 2: menghasilkan keluaran stabil
        end if;
    end process;
    
    sync_out <= ff2;
end Behavioral;