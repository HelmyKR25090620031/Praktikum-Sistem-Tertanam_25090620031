library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Versi pipeline 2 tahap dari fixed_mul_q8_8:[cite: 12]
-- tahap 1 = perkalian, tahap 2 = scaling + register[cite: 12]
entity fixed_mul_pipe2 is
    Port (
        clk    : in  STD_LOGIC;
        a      : in  STD_LOGIC_VECTOR (15 downto 0);
        b      : in  STD_LOGIC_VECTOR (15 downto 0);
        result : out STD_LOGIC_VECTOR (15 downto 0)
    );
end fixed_mul_pipe2;

architecture Behavioral of fixed_mul_pipe2 is
    -- Sinyal register pipeline
    signal product_reg : unsigned (31 downto 0);         -- Register Tahap 1[cite: 12]
    signal result_reg  : STD_LOGIC_VECTOR (15 downto 0); -- Register Tahap 2[cite: 12]
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Tahap 1: Hitung perkalian penuh, simpan ke register[cite: 12]
            product_reg <= unsigned(a) * unsigned(b);

            -- Tahap 2: Ambil hasil tahap 1 (dari siklus sebelumnya), lakukan scaling[cite: 12]
            result_reg <= STD_LOGIC_VECTOR(product_reg(23 downto 8));
        end if;
    end process;

    result <= result_reg;

    -- Catatan: latency menjadi 2 siklus clock (dibandingkan 0 siklus/kombinasional murni[cite: 12]
    -- pada Kode 9.1), namun setiap siklus dapat menerima pasangan a, b BARU[cite: 13]
    -- (throughput tinggi).[cite: 13]
end Behavioral;