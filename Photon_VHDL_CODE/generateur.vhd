library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity generateur is
    Port ( CLK : in STD_LOGIC;
           CLK_N1 : out STD_LOGIC;
           CLK_N2 : out STD_LOGIC);
end generateur;

architecture Behavioral of generateur is
    
    signal cnt1 : integer range 0 to 10 := 0;
    signal C_N1: std_logic := '0';
    
    signal cnt2 : integer range 0 to 30 := 0;
    signal C_N2: std_logic := '0';
begin

    CLK_N1 <= C_N1;
    CLK_N2 <= C_N2;
    
    C_1: process(CLK)
    begin
        if cnt1 = 10 then
            cnt1 <= 0;
        elsif rising_edge(CLK) then
            if cnt1 < 4 then
                C_N1 <= '1';
            else
                C_N1 <= '0';
            end if;
            cnt1 <= cnt1 + 1; 
        end if;
    end process;
    
    C_2: process(CLK)
    begin
        if cnt2 = 30 then
            cnt2 <= 0;
        elsif rising_edge(CLK) then
            if cnt2 < 18 then
                C_N2 <= '0';
            else
                C_N2 <= '1';
            end if;
            cnt2 <= cnt2 + 1; 
        end if;
    end process;

end Behavioral;
