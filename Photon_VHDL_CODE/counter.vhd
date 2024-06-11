library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity counter is
    Port (  DETC : in STD_LOGIC;
            RE : in STD_LOGIC;
            FINISH : out STD_LOGIC;
            COUNT_OUT : out STD_LOGIC_VECTOR (31 downto 0));
end counter;

architecture Behavioral of counter is

signal counter: std_logic_vector(31 downto 0):= (others => '0');
signal FIN : std_logic :='0';

begin
    COUNT_OUT <= counter;
    FINISH <= FIN;
    PROCESS (DETC,RE)
    BEGIN
        if (RE = '1') then
    		counter <= (others=>'0');
    		FIN <= '0';
    	elsif counter = x"FFFFFFFF" then
    	   FIN <= '1';
        elsif rising_edge(DETC)  then
            counter <= counter + 1;
            FIN <= '0';
        end if;
    END PROCESS;
end Behavioral;
