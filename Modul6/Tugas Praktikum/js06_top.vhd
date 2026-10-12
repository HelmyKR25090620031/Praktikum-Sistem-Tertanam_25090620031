library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity js06_top is
    Port (
        clk  : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR (7 downto 0); -- Input Switch
        btnU : in  STD_LOGIC;                     -- Muat Operand A Awal
        btnD : in  STD_LOGIC;                     -- Muat Operand B & Hitung
        btnL : in  STD_LOGIC;                     -- Operasi Tambah (+)
        btnR : in  STD_LOGIC;                     -- Operasi Kurang (-)
        btnC : in  STD_LOGIC;                     -- Reset Total ke 0000
        seg  : out STD_LOGIC_VECTOR (6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end js06_top;

architecture Behavioral of js06_top is
    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;

    signal reg_a       : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- Akumulator 16-bit
    signal reg_b       : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
    signal op_sel      : STD_LOGIC := '0';
    signal alu_result  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal display_val : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    signal btnU_db, btnD_db, btnL_db, btnR_db, btnC_db : STD_LOGIC;
    signal btnU_p,  btnD_p,  btnL_p,  btnR_p,  btnC_p  : STD_LOGIC;

begin

    -- Instansiasi Debounce & Edge Detect
    DB_U: entity work.debounce port map (clk => clk, btn_in => btnU, btn_out => btnU_db);
    DB_D: entity work.debounce port map (clk => clk, btn_in => btnD, btn_out => btnD_db);
    DB_L: entity work.debounce port map (clk => clk, btn_in => btnL, btn_out => btnL_db);
    DB_R: entity work.debounce port map (clk => clk, btn_in => btnR, btn_out => btnR_db);
    DB_C: entity work.debounce port map (clk => clk, btn_in => btnC, btn_out => btnC_db);

    ED_U: entity work.edge_detect port map (clk => clk, sig_in => btnU_db, pulse => btnU_p);
    ED_D: entity work.edge_detect port map (clk => clk, sig_in => btnD_db, pulse => btnD_p);
    ED_L: entity work.edge_detect port map (clk => clk, sig_in => btnL_db, pulse => btnL_p);
    ED_R: entity work.edge_detect port map (clk => clk, sig_in => btnR_db, pulse => btnR_p);
    ED_C: entity work.edge_detect port map (clk => clk, sig_in => btnC_db, pulse => btnC_p);

    -- Process Sinkron: FSM & Register Akumulator
    process(clk)
    begin
        if rising_edge(clk) then
            if btnC_p = '1' then
                state  <= S_WAIT_A;
                reg_a  <= (others => '0');
                reg_b  <= (others => '0');
                op_sel <= '0';
            else
                state <= next_state;

                -- Pemuatan nilai Awal A
                if state = S_WAIT_A and btnU_p = '1' then
                    reg_a <= std_logic_vector(resize(unsigned(sw), 16));
                elsif state = S_SHOW and btnU_p = '1' then
                    reg_a <= std_logic_vector(resize(unsigned(sw), 16));
                end if;

                -- Operasi & Pemuatan nilai B
                if state = S_WAIT_B or state = S_SHOW then
                    if btnL_p = '1' then
                        op_sel <= '0'; -- Tambah
                    elsif btnR_p = '1' then
                        op_sel <= '1'; -- Kurang
                    end if;

                    if btnD_p = '1' then
                        reg_b <= sw;
                    end if;
                end if;

                -- Simpan Hasil ke Akumulator
                if state = S_COMPUTE then
                    reg_a <= alu_result;
                end if;
            end if;
        end if;
    end process;

    -- Process Kombinasional: Transisi State
    process(state, btnU_p, btnD_p)
    begin
        next_state <= state;
        case state is
            when S_WAIT_A =>
                if btnU_p = '1' then next_state <= S_WAIT_B; end if;

            when S_WAIT_B =>
                if btnD_p = '1' then next_state <= S_COMPUTE; end if;

            when S_COMPUTE =>
                next_state <= S_SHOW;

            when S_SHOW =>
                if btnD_p = '1' then
                    next_state <= S_COMPUTE; -- Kalkulasi berlanjut
                elsif btnU_p = '1' then
                    next_state <= S_WAIT_B;  -- Reset angka awal dari switch
                end if;

            when others =>
                next_state <= S_WAIT_A;
        end case;
    end process;

    -- ALU 16-Bit
    ALU_INST: entity work.alu8
        port map (
            a      => reg_a,
            b      => reg_b,
            op     => op_sel,
            result => alu_result
        );

    -- Seleksi Tampilan
    display_val <= std_logic_vector(resize(unsigned(sw), 16)) when state = S_WAIT_A else
                   std_logic_vector(resize(unsigned(sw), 16)) when state = S_WAIT_B else
                   reg_a;

    -- Driver Seven Segment
    SEG_DISP: entity work.seven_seg_driver
        port map (
            clk     => clk,
            data_in => display_val,
            seg     => seg,
            dp      => dp,
            an      => an
        );

end Behavioral;