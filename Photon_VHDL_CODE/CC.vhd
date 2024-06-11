library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity CC is
    Port ( CLK : in STD_LOGIC;
           RE : in STD_LOGIC;
           REE : in STD_LOGIC;
           EA : in STD_LOGIC;
           EB : in STD_LOGIC;
           CA : out STD_LOGIC_VECTOR (7 downto 0);
           CB : out STD_LOGIC_VECTOR (7 downto 0));
end CC;
architecture Behavioral of CC is

    signal cnt1_1: std_logic_vector(7 downto 0):=(others => '0');
    signal cnt1_2: std_logic_vector(7 downto 0):=(others => '1');
    signal prev1_B:std_logic := '1';
    signal A_DEC:std_logic := '0';
    signal AD_temp: std_logic_vector(31 downto 0):=(others => '0');
    
    type etat is (BASE,COINCI);
    signal state_machine: etat := BASE;
    
    signal cnt2_1: std_logic_vector(7 downto 0):=(others => '0');
    signal cnt2_2: std_logic_vector(7 downto 0):=(others => '1');
    signal prev2_A:std_logic := '1';
    signal B_DEC:std_logic := '0';
    signal BD_temp: std_logic_vector(31 downto 0):=(others => '0');
    
    signal state_machine2: etat := BASE;
begin

    CA <= cnt1_2;
    C1: process(CLK,EA,EB)
    begin
        if RE = '1' or REE = '1' then
            A_DEC <= '0';
            cnt1_1 <= (others => '0');
            cnt1_2 <= (others => '1');
        else
            case state_machine is
                when BASE =>
                    A_DEC <= '0';
                    cnt1_1 <= "00000000";
                    if rising_edge(EA) then
                        state_machine <= COINCI;
                    end if;
                when COINCI =>
                    if rising_edge(CLK) then
                        if prev1_B = '0' and EB = '1' then
                            A_DEC <= '1';
                            cnt1_2 <= cnt1_1;
                            state_machine <= BASE;
                        else
                            if cnt1_1 < "00110010" then --50
                                state_machine <= COINCI;  
                            else
                                state_machine <= BASE;
                            end if;
                            cnt1_1 <= cnt1_1 + 1;
                        end if;
                        prev1_B <= EB;
                    end if;
            end case;
        end if;
    end process;
    
    --------------------  2eme ----------------------------
    CB <= cnt2_2;
    C2: process(CLK,EA,EB)
    begin
        if RE = '1' or REE = '1' then
            B_DEC <= '0';
            cnt2_1 <= (others => '0');
            cnt2_2 <= (others => '1');
        else
            case state_machine2 is
                when BASE =>
                    B_DEC <= '0';
                    cnt2_1 <= "00000000";
                    if rising_edge(EB) then
                        state_machine2 <= COINCI;
                    end if;
                when COINCI =>
                    if rising_edge(CLK) then
                        if prev2_A = '0' and EA = '1' then
                            B_DEC <= '1';
                            cnt2_2 <= cnt2_1;
                            state_machine2 <= BASE;
                        else
                            if cnt2_1 < "00110010" then
                                state_machine2 <= COINCI;  
                            else
                                state_machine2 <= BASE;
                            end if;
                            cnt2_1 <= cnt2_1 + 1;
                        end if;
                        prev2_A <= EA;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
