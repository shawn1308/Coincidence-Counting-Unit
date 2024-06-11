library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Devider_2KHZ is
    Port ( CLK_IN : in STD_LOGIC;
           RE : in STD_LOGIC;
           CLK_OUT : out STD_LOGIC);
end Devider_2KHZ;

architecture Behavioral of Devider_2KHZ is

SIGNAL count : INTEGER := 0;
SIGNAL b : STD_LOGIC := '1';
    
begin
    PROCESS (CLK_IN)
    BEGIN
        if RE = '1' then
            count <= 0;
            b <= '1';
        elsif RISING_EDGE(CLK_IN) THEN
            count <= count + 1;
            IF count = 50000 - 1 THEN
                b <= NOT b;
                count <= 0;
            END IF;
        END IF;
        CLK_OUT <= b;
    END PROCESS;
end Behavioral;
