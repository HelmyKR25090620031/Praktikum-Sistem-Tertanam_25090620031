library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    Generic (
        CLK_FREQ : integer := 100_000_000; -- Clock Onboard Basys 3 (100 MHz)
        I2C_FREQ : integer := 100_000      -- SCL Standard Mode (100 kHz)
    );
    Port (
        clk        : in    STD_LOGIC;
        rst        : in    STD_LOGIC;
        enable     : in    STD_LOGIC;                      -- Pemicu transaksi
        rw         : in    STD_LOGIC;                      -- '0' = Write, '1' = Read
        slave_addr : in    STD_LOGIC_VECTOR(6 downto 0);   -- Alamat Slave 7-bit
        reg_addr   : in    STD_LOGIC_VECTOR(7 downto 0);   -- Alamat Register Internal
        data_write : in    STD_LOGIC_VECTOR(7 downto 0);   -- Data yang ditulis
        data_read  : out   STD_LOGIC_VECTOR(7 downto 0);   -- Data yang dibaca
        busy       : out   STD_LOGIC;                      -- Sinyal indikator proses
        ack_error  : out   STD_LOGIC;                      -- Deteksi NACK dari Slave
        scl        : inout STD_LOGIC;                      -- I2C Clock Line
        sda        : inout STD_LOGIC                       -- I2C Data Line
    );
end i2c_master;

architecture Behavioral of i2c_master is

    -- Pembagi Clock SCL (4x sampling rate)
    constant CLK_DIVIDER : integer := (CLK_FREQ / (I2C_FREQ * 4));
    signal count         : integer range 0 to CLK_DIVIDER := 0;
    signal i2c_clk_en    : boolean := false;

    -- State Machine
    type i2c_state is (S_IDLE, S_START, S_ADDR, S_ADDR_ACK, S_DATA, S_DATA_ACK, S_STOP);
    signal state : i2c_state := S_IDLE;

    -- Internal Registers & Tri-state Control
    signal scl_clk  : STD_LOGIC := '1';
    signal sda_out  : STD_LOGIC := '1';
    signal sda_ena  : STD_LOGIC := '0'; -- '1' = Drive low, '0' = Hi-Z (Read ACK)
    signal bit_idx  : integer range 0 to 7 := 7;
    signal tx_byte  : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_byte  : STD_LOGIC_VECTOR(7 downto 0);

begin

    ------------------------------------------------------------------
    -- 1. PEMBANGKIT PULSA SAMPLE ENABLER (4x I2C Clock)
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if count = CLK_DIVIDER - 1 then
                count <= 0;
                i2c_clk_en <= true;
            else
                count <= count + 1;
                i2c_clk_en <= false;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- 2. LOGIKA KONTROL TRISTATE BUS SDA & SCL
    ------------------------------------------------------------------
    scl <= '0' when (scl_clk = '0') else 'Z';
    sda <= '0' when (sda_ena = '1' and sda_out = '0') else 'Z';

    ------------------------------------------------------------------
    -- 3. FSM I2C MASTER STATE MACHINE
    ------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            state     <= S_IDLE;
            busy      <= '0';
            ack_error <= '0';
            sda_ena   <= '0';
            scl_clk   <= '1';
        elsif rising_edge(clk) then
            if i2c_clk_en then
                case state is

                    -- IDLE: Bus Bebas
                    when S_IDLE =>
                        busy    <= '0';
                        scl_clk <= '1';
                        sda_ena <= '0';
                        if enable = '1' then
                            state   <= S_START;
                            busy    <= '1';
                            tx_byte <= slave_addr & rw; -- 7-bit Addr + R/W bit
                        end if;

                    -- START Condition: SDA Turun saat SCL Tinggi
                    when S_START =>
                        sda_ena <= '1';
                        sda_out <= '0';
                        scl_clk <= '1';
                        state   <= S_ADDR;
                        bit_idx <= 7;

                    -- Send Slave Address + R/W Bit (8-bit)
                    when S_ADDR =>
                        scl_clk <= not scl_clk;
                        if scl_clk = '0' then
                            sda_out <= tx_byte(bit_idx);
                            if bit_idx = 0 then
                                state <= S_ADDR_ACK;
                            else
                                bit_idx <= bit_idx - 1;
                            end if;
                        end if;

                    -- Receive ACK dari Slave
                    when S_ADDR_ACK =>
                        scl_clk <= not scl_clk;
                        if scl_clk = '1' then
                            sda_ena <= '0'; -- Hi-Z untuk membaca ACK
                            if sda = '0' then
                                ack_error <= '0';
                                state     <= S_DATA;
                                bit_idx   <= 7;
                                tx_byte   <= data_write;
                            else
                                ack_error <= '1'; -- NACK terdeteksi
                                state     <= S_STOP;
                            end if;
                        end if;

                    -- Transmit / Receive Data Byte
                    when S_DATA =>
                        scl_clk <= not scl_clk;
                        if rw = '0' then -- Write Mode
                            sda_ena <= '1';
                            if scl_clk = '0' then
                                sda_out <= tx_byte(bit_idx);
                                if bit_idx = 0 then
                                    state <= S_DATA_ACK;
                                else
                                    bit_idx <= bit_idx - 1;
                                end if;
                            end if;
                        else -- Read Mode
                            sda_ena <= '0';
                            if scl_clk = '1' then
                                rx_byte(bit_idx) <= sda;
                                if bit_idx = 0 then
                                    state <= S_DATA_ACK;
                                else
                                    bit_idx <= bit_idx - 1;
                                end if;
                            end if;
                        end if;

                    -- Send / Receive ACK Data
                    when S_DATA_ACK =>
                        scl_clk <= not scl_clk;
                        if rw = '0' then
                            sda_ena <= '0'; -- Read ACK dari Slave
                        else
                            sda_ena <= '1'; -- Master memberikan ACK
                            sda_out <= '0';
                        end if;
                        state <= S_STOP;

                    -- STOP Condition: SDA Naik saat SCL Tinggi
                    when S_STOP =>
                        scl_clk <= '1';
                        sda_ena <= '1';
                        sda_out <= '1';
                        data_read <= rx_byte;
                        state   <= S_IDLE;

                end case;
            end if;
        end if;
    end process;

end Behavioral;