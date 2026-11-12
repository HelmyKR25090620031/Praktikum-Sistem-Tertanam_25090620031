library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_tugas_top is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        sw       : in  STD_LOGIC_VECTOR (3 downto 0);
        Hsync    : out STD_LOGIC;
        Vsync    : out STD_LOGIC;
        vgaRed   : out STD_LOGIC_VECTOR (3 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
        vgaBlue  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end js11_tugas_top;

architecture Behavioral of js11_tugas_top is

    component clk_wiz_0
        port (
            clk_out1 : out STD_LOGIC;
            reset    : in  STD_LOGIC;
            locked   : out STD_LOGIC;
            clk_in1  : in  STD_LOGIC
        );
    end component;

    signal pclk     : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_cnt    : integer range 0 to 799;
    signal v_cnt    : integer range 0 to 524;
    signal rgb_raw  : STD_LOGIC_VECTOR(11 downto 0);

begin

    CLK_GEN : clk_wiz_0
        port map (
            clk_out1 => pclk,
            reset    => rst,
            locked   => open,
            clk_in1  => clk
        );

    SYNC_GEN : entity work.vga_sync
        port map (
            pclk     => pclk,
            rst      => rst,
            hsync    => Hsync,
            vsync    => Vsync,
            video_on => video_on,
            h_count  => h_cnt,
            v_count  => v_cnt
        );

    TUGAS_PATTERN : entity work.color_pattern_tugas
        port map (
            h_count => h_cnt,
            v_count => v_cnt,
            sw      => sw,
            rgb     => rgb_raw
        );

    vgaRed   <= rgb_raw(11 downto 8) when video_on = '1' else "0000";
    vgaGreen <= rgb_raw(7 downto 4)  when video_on = '1' else "0000";
    vgaBlue  <= rgb_raw(3 downto 0)  when video_on = '1' else "0000";

end Behavioral;