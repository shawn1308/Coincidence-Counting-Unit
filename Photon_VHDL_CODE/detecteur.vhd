library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity detecteur is
    Port (  CLK : in STD_LOGIC;
            ENTREE : in STD_LOGIC;
            RE : in STD_LOGIC;
            DETC : out STD_LOGIC);
end detecteur;

architecture Behavioral of detecteur is

signal counter: std_logic_vector(15 downto 0):= (others => '0');
signal dispo : STD_LOGIC := '0';
type etat is (Base,Exit_count);
signal state_machine: etat := Base;

begin
    DETC <= dispo;
    process(CLK,RE)
    begin
        if (RE = '1') or counter >= x"FFFF" then
    		counter <= (others=>'0');
    		dispo <='0';
        elsif rising_edge(Clk) then
            counter <= counter + 1;
        	dispo <='0';
            case state_machine is
                when Base =>
                    if(ENTREE = '1') then
                        dispo <= '1';
                        state_machine <= Exit_count;
                    else
                        state_machine <= Base;
                    end if;
                    
                when Exit_count =>
                	dispo <= '0';
                    if(ENTREE = '1') then
                        state_machine <= Exit_count;
                    else
                        state_machine <= Base;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
