library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RX_PART is
    Port (  Data_av : in STD_LOGIC;
            Data_in : in STD_LOGIC_VECTOR (7 downto 0);
            RE : out STD_LOGIC;
            FINISH : out STD_LOGIC);
end RX_PART;

architecture Behavioral of RX_PART is
    signal RES : std_logic :='1';
    signal FIN : std_logic :='0';
begin
	process(Data_av)
	begin
		if rising_edge(Data_av) then
			if(Data_in = x"53") then
				RES <='0';
			elsif (Data_in = x"52") then
				RES <='1';
				FIN <='0';
			elsif (Data_in = x"46") then
				FIN <='1';
			end if;
		end if;
	end process;
	FINISH <= FIN;
    RE <= RES;

end Behavioral;
