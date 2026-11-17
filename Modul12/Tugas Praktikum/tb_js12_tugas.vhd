library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_js12_tugas is
end tb_js12_tugas;

architecture Behavioral of tb_js12_tugas is
    signal clk     : STD_LOGIC := '0';
    signal PS2Clk  : STD_LOGIC := '1';
    signal PS2Data : STD_LOGIC := '1';
    signal led     : STD_LOGIC_VECTOR (0 downto 0);
    signal an      : STD_LOGIC_VECTOR (3 downto 0);
    signal seg     : STD_LOGIC_VECTOR (6 downto 0);

    constant CLK_PERIOD      : time := 10 ns;
    constant PS2_HALF_PERIOD : time := 30 us;

    -- Frame 11-bit: Start(0) + 8-bit LSB..MSB + Odd Parity + Stop(1)
    constant FRAME_1C : STD_LOGIC_VECTOR(0 to 10) := "00011100001"; -- 0x1C ('A')
    constant FRAME_F0 : STD_LOGIC_VECTOR(0 to 10) := "00000111111"; -- 0xF0 (Break)

    procedure send_ps2_frame(
        constant frame : in STD_LOGIC_VECTOR(0 to 10);
        signal p_clk   : out STD_LOGIC;
        signal p_data  : out STD_LOGIC
    ) is
    begin
        for i in 0 to 10 loop
            p_data <= frame(i);
            wait for PS2_HALF_PERIOD;
            p_clk  <= '0';
            wait for PS2_HALF_PERIOD;
            p_clk  <= '1';
        end loop;
        p_data <= '1';
        wait for 100 us;
    end procedure;
begin

    uut: entity work.js12_tugas_top
        port map (
            clk     => clk,
            PS2Clk  => PS2Clk,
            PS2Data => PS2Data,
            led     => led,
            an      => an,
            seg     => seg
        );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        wait for 100 us;

        -- 1. Simulasi tombol 'A' ditekan (Make Code 0x1C)
        send_ps2_frame(FRAME_1C, PS2Clk, PS2Data);
        assert (led(0) = '1')
            report "GAGAL: led(0) seharusnya menyala saat tombol 'A' ditekan!" severity error;

        wait for 200 us;

        -- 2. Simulasi tombol 'A' dilepas (Break Code 0xF0 lalu 0x1C)
        send_ps2_frame(FRAME_F0, PS2Clk, PS2Data);
        send_ps2_frame(FRAME_1C, PS2Clk, PS2Data);
        assert (led(0) = '0')
            report "GAGAL: led(0) seharusnya padam saat tombol 'A' dilepas!" severity error;

        assert false report "SIMULASI TUGAS SELESAI: Make & Break Code bekerja sesuai!" severity note;
        wait;
    end process;

end Behavioral;