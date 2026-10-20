library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity traffic_light_top is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        sw  : in  STD_LOGIC_VECTOR (3 downto 0);
        led : out STD_LOGIC_VECTOR (5 downto 0)
    );
end traffic_light_top;
architecture Behavioral of traffic_light_top is
    signal tick_sig : STD_LOGIC;
begin
    u_tick : entity work.tick_1hz
        generic map (
            CLK_FREQ_HZ => 100_000_000
        )
        port map (
            clk  => clk,
            rst  => rst,
            tick => tick_sig
        );
    u_fsm : entity work.traffic_light_fsm
        port map (
            clk  => clk,
            rst  => rst,
            tick => tick_sig,
            sw   => sw,
            led  => led
        );
end Behavioral;

