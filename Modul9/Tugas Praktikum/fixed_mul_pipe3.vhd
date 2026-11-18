library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Perkalian Fixed-Point Q8.8 x Q8.8 -> Q8.8 dengan Pipeline 3 Tahap (Latency = 3 siklus)
entity fixed_mul_pipe3 is
    Port (
        clk    : in  STD_LOGIC;
        a      : in  STD_LOGIC_VECTOR (15 downto 0); -- Format Q8.8
        b      : in  STD_LOGIC_VECTOR (15 downto 0); -- Format Q8.8
        result : out STD_LOGIC_VECTOR (15 downto 0)  -- Format Q8.8
    );
end fixed_mul_pipe3;

architecture Behavioral of fixed_mul_pipe3 is
    -- Register Tahap 1: 4 Hasil Perkalian Parsial (8x8 = 16-bit)
    signal p_ll, p_lh, p_hl, p_hh : unsigned (15 downto 0) := (others => '0');

    -- Register Tahap 2: Penjumlahan Hasil Parsial (32-bit Q16.16)
    signal product_reg : unsigned (31 downto 0) := (others => '0');

    -- Register Tahap 3: Hasil Scaling Akhir (16-bit Q8.8)
    signal result_reg  : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
begin

    process(clk)
        variable a_hi, a_lo, b_hi, b_lo : unsigned (7 downto 0);
    begin
        if rising_edge(clk) then
            -- TAHAP 1: Hitung 4 perkalian parsial 8-bit
            a_hi := unsigned(a(15 downto 8));
            a_lo := unsigned(a(7 downto 0));
            b_hi := unsigned(b(15 downto 8));
            b_lo := unsigned(b(7 downto 0));

            p_ll <= a_lo * b_lo;
            p_lh <= a_lo * b_hi;
            p_hl <= a_hi * b_lo;
            p_hh <= a_hi * b_hi;

            -- TAHAP 2: Jumlahkan hasil parsial sesuai bobot pergeseran bitnya
            product_reg <= resize(p_ll, 32) +
                           shift_left(resize(p_lh, 32), 8) +
                           shift_left(resize(p_hl, 32), 8) +
                           shift_left(resize(p_hh, 32), 16);

            -- TAHAP 3: Scaling dari Q16.16 ke Q8.8 (buang 8 bit LSB pecahan & 8 bit MSB)
            result_reg <= STD_LOGIC_VECTOR(product_reg(23 downto 8));
        end if;
    end process;

    result <= result_reg;

end Behavioral;