library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_i2c_master is
end tb_i2c_master;

architecture Behavioral of tb_i2c_master is
    signal clk        : STD_LOGIC := '0';
    signal rst        : STD_LOGIC := '0';
    signal enable     : STD_LOGIC := '0';
    signal rw         : STD_LOGIC := '0';
    signal slave_addr : STD_LOGIC_VECTOR(6 downto 0) := "1001000"; -- 0x48 (Pmod TMP2)
    signal reg_addr   : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal data_write : STD_LOGIC_VECTOR(7 downto 0) := x"AB";
    signal data_read  : STD_LOGIC_VECTOR(7 downto 0);
    signal busy       : STD_LOGIC;
    signal ack_error  : STD_LOGIC;
    signal scl        : STD_LOGIC;
    signal sda        : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;
begin

    -- External Pull-up Resistors pada Bus I2C ('H' = Weak High)
    scl <= 'H';
    sda <= 'H';

    -- Instansiasi Unit Under Test (UUT) I2C Master
    uut: entity work.i2c_master
        generic map (
            CLK_FREQ => 100_000_000,
            I2C_FREQ => 100_000
        )
        port map (
            clk        => clk,
            rst        => rst,
            enable     => enable,
            rw         => rw,
            slave_addr => slave_addr,
            reg_addr   => reg_addr,
            data_write => data_write,
            data_read  => data_read,
            busy       => busy,
            ack_error  => ack_error,
            scl        => scl,
            sda        => sda
        );

    -- Pembangkit Clock 100 MHz
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Pengujian Transaksi I2C
    stim_proc: process
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- Pemicuan Transaksi Penulisan (Write 0xAB ke Slave 0x48)
        enable <= '1';
        rw     <= '0';
        wait for CLK_PERIOD * 10;
        enable <= '0';

        -- Waktu tunggu pengamatan gelombang SCL/SDA pada simulasi
        wait for 100 us;
        
        wait;
    end process;

end Behavioral;