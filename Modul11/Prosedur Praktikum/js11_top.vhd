library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_top is
    Port (
        clk      : in  STD_LOGIC;                    -- Clock Onboard Basys 3 (100 MHz)
        rst      : in  STD_LOGIC;                    -- Reset btnC
        Hsync    : out STD_LOGIC;
        Vsync    : out STD_LOGIC;
        vgaRed   : out STD_LOGIC_VECTOR (3 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
        vgaBlue  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end js11_top;

architecture Behavioral of js11_top is

    -- IP Clocking Wizard Component Declaration
    component clk_wiz_0
        port (
            clk_out1 : out STD_LOGIC; -- Output 25 MHz
            reset    : in  STD_LOGIC;
            locked   : out STD_LOGIC;
            clk_in1  : in  STD_LOGIC  -- Input 100 MHz
        );
    end component;

    signal pclk     : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_cnt    : integer range 0 to 799;
    signal v_cnt    : integer range 0 to 524;
    signal rgb_raw  : STD_LOGIC_VECTOR(11 downto 0);

begin

    -- Instansiasi Clocking Wizard (100 MHz -> 25 MHz)
    CLK_GEN : clk_wiz_0
        port map (
            clk_out1 => pclk,
            reset    => rst,
            locked   => open,
            clk_in1  => clk
        );

    -- Instansiasi VGA Sync Generator
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

    -- Instansiasi Pembangkit Batang Warna
    PATTERN_GEN : entity work.color_bar_pattern
        port map (
            h_count => h_cnt,
            v_count => v_cnt,
            rgb     => rgb_raw
        );

    -- Gating RGB dengan sinyal video_on (Paksa Hitam di luar area display)
    vgaRed   <= rgb_raw(11 downto 8) when video_on = '1' else "0000";
    vgaGreen <= rgb_raw(7 downto 4)  when video_on = '1' else "0000";
    vgaBlue  <= rgb_raw(3 downto 0)  when video_on = '1' else "0000";

end Behavioral;