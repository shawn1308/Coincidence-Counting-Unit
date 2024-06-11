library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity OR_FINISH is
    Port ( C1 : in STD_LOGIC;
           C2 : in STD_LOGIC;
           RX : in STD_LOGIC;
           D_OUT : out STD_LOGIC);
end OR_FINISH;
architecture Behavioral of OR_FINISH is

begin
 D_OUT <= (C1 and C2) or RX;
end Behavioral;
