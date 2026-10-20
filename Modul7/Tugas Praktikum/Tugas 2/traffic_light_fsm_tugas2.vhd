library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity traffic_light_fsm is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        tick : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR (3 downto 0);
        led  : out STD_LOGIC_VECTOR (5 downto 0)
    );
end traffic_light_fsm;
architecture Behavioral of traffic_light_fsm is
    type state_type is (NS_HIJAU, NS_KUNING, EW_HIJAU, EW_KUNING);
    signal current_state, next_state : state_type;
    constant TIME_YELLOW : integer := 3;
    signal time_green : integer range 5 to 20;
    signal timer      : integer range 0 to 20 := 4;
begin
    -- Konversi input switch 0..15 menjadi durasi hijau 5..20 detik
    time_green <= 5 + to_integer(unsigned(sw));
    -- Process 1: Update State dan Timer
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= NS_HIJAU;
                timer         <= time_green - 1;
            elsif tick = '1' then
                if timer = 0 then
                    current_state <= next_state;
                    case next_state is
                        when NS_HIJAU  => timer <= time_green - 1;
                        when NS_KUNING => timer <= TIME_YELLOW - 1;
                        when EW_HIJAU  => timer <= time_green - 1;
                        when EW_KUNING => timer <= TIME_YELLOW - 1;
                    end case;
                else
                    timer <= timer - 1;
                end if;
            end if;
        end if;
    end process;
    -- Process 2: Transisi State dan Logika LED
    process(current_state)
    begin
        case current_state is
            when NS_HIJAU =>
                next_state <= NS_KUNING;
                led        <= "100001"; -- EW: Merah (bit 5), NS: Hijau (bit 0)
            when NS_KUNING =>
                next_state <= EW_HIJAU;
                led        <= "100010"; -- EW: Merah (bit 5), NS: Kuning (bit 1)
            when EW_HIJAU =>
                next_state <= EW_KUNING;
                led        <= "001100"; -- EW: Hijau (bit 3), NS: Merah (bit 2)
            when EW_KUNING =>
                next_state <= NS_HIJAU;
                led        <= "010100"; -- EW: Kuning (bit 4), NS: Merah (bit 2)
        end case;
    end process;
end Behavioral;

