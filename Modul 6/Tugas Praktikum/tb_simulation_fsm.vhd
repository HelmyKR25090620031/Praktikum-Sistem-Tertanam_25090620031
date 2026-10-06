library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture sim of tb_calculator_fsm is
    signal clk_tb : STD_LOGIC := '0';
    signal sw_tb  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal btnU_tb, btnD_tb, btnL_tb, btnR_tb, btnC_tb : STD_LOGIC := '0';
    signal seg_tb : STD_LOGIC_VECTOR(6 downto 0);
    signal dp_tb  : STD_LOGIC;
    signal an_tb  : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.js06_top
        port map (
            clk => clk_tb, sw => sw_tb,
            btnU => btnU_tb, btnD => btnD_tb,
            btnL => btnL_tb, btnR => btnR_tb, btnC => btnC_tb,
            seg => seg_tb, dp => dp_tb, an => an_tb
        );

    clk_process: process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD/2;
        clk_tb <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        wait for 100 ns;
        
        -- Set Operand A = 12 (0x0C)
        sw_tb <= "00001100";
        btnU_tb <= '1'; wait for 20 ms; btnU_tb <= '0'; wait for 10 ms;

        -- Set Operand B = 5 (0x05) dan Pilih Operasi Tambah (btnL)
        sw_tb <= "00000101";
        btnL_tb <= '1'; wait for 20 ms; btnL_tb <= '0'; wait for 10 ms;
        btnD_tb <= '1'; wait for 20 ms; btnD_tb <= '0'; wait for 10 ms;

        -- Hasil harus menampilkan 17 (0x0011) di S_SHOW
        wait for 50 ms;
        
        -- Reset ke awal
        btnC_tb <= '1'; wait for 20 ms; btnC_tb <= '0';
        wait;
    end process;
end sim;