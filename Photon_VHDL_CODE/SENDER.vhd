library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity SENDER is
    Port ( DATA_IN1 : in STD_LOGIC_VECTOR (31 downto 0);
           DATA_IN2 : in STD_LOGIC_VECTOR (31 downto 0);
           PULSE_IN : in STD_LOGIC;
           FINISH : in STD_LOGIC;
           CLK : in STD_LOGIC;
           RE : in STD_LOGIC;
           TX : out STD_LOGIC;
           STATUS : out STD_LOGIC;
           REE : out STD_LOGIC;
           CA : in STD_LOGIC_VECTOR (7 downto 0);
           CB : in STD_LOGIC_VECTOR (7 downto 0));
end SENDER;

architecture Behavioral of SENDER is

---------------------------------------------------------------------------------- TRANSMIT
signal baud : integer := 400;
	type etat is ( Base1, Start_bit1, Valid_bit1,Stop_bit1,Exit_bit1,
	               Base2, Start_bit2, Valid_bit2,Stop_bit2,Exit_bit2,
	               Base3, Start_bit3, Valid_bit3,Stop_bit3,Exit_bit3,
	               Base4, Start_bit4, Valid_bit4,Stop_bit4,Exit_bit4,
	               Base5, Start_bit5, Valid_bit5,Stop_bit5,Exit_bit5,
	               Base6, Start_bit6, Valid_bit6,Stop_bit6,Exit_bit6,
	               Base7, Start_bit7, Valid_bit7,Stop_bit7,Exit_bit7,
	               Base8, Start_bit8, Valid_bit8,Stop_bit8,Exit_bit8,
	               BaseC1, Start_bitC1, Valid_bitC1,Stop_bitC1,Exit_bitC1,
	               BaseC2, Start_bitC2, Valid_bitC2,Stop_bitC2,Exit_bitC2);
	signal state_machine: etat := Base1;
	signal tx_clk : std_logic := '0';
	signal count : integer range 0 to 400 := 0;
	signal tx_8_data : std_logic_vector(7 downto 0) := (others => '0');
	signal cnt_bit : integer range 0 to 8 := 0;
------------------------------------------------------------------------------- DATA IN	
	signal D_IN : std_logic_vector(31 downto 0) := (others => '0');
    signal D_IN2 : std_logic_vector(31 downto 0) := (others => '0');
------------------------------------------------------------------------------- COINCI
    signal AD_PREV : std_logic_vector(31 downto 0) := (others => '0');
    signal BD_PREV : std_logic_vector(31 downto 0) := (others => '0');
------------------------------------------------------------------------------- COINCI REE
    signal C_REE : std_logic := '0';
begin

    REE <= C_REE;
    
    ------------------------------------------------- TX CLK
    clkgen : process(CLK)
	begin
		if rising_edge(CLK) then
            if (count < baud - 1) then
            	count <= count + 1;
            else
                count <= 0;
            end if;
            if (count < (baud/2) - 1) then
            	tx_clk <= '0';
            else
            	tx_clk <= '1';
            end if;
        end if;
	end process;

    ----------------------------------------------- GET DATA
	get : process(PULSE_IN)
	begin
	   if rising_edge(PULSE_IN) then
	       D_IN <= DATA_IN1;
	       D_IN2 <= DATA_IN2;
	   end if;
	end process;
	----------------------------------------------- SEND
	sending : process(tx_clk,state_machine,PULSE_IN,RE,CA,CB)
	begin		
		if RE = '1' then
			TX <= '1';
			status <= '0';
			state_machine <= BASE1;
		elsif rising_edge(tx_clk) then
				case state_machine is
				------------------------------- 1st Byte--------------------------------
    		    	when Base1 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		if PULSE_IN = '1' and FINISH = '0' then
    		    			state_machine <= Start_bit1;
    		    		else
    		    			state_machine <= BASE1;
    		    		end if;
    		    		
    		    	when Start_bit1 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN(31 downto 24);
    		    		state_machine <= Valid_bit1;
    		    	when Valid_bit1 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit1;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit1;
    		    		end if;
    		    	when Stop_bit1 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		C_REE <= '1';
    		    		state_machine <= Exit_bit1;
    		    	when Exit_bit1 =>
    		    		tx <= '1';
    		    		state_machine <= Base2;
    		    	
    		    	------------------------- 2nd byte --------------------
    		    	
    		    	when Base2 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit2;
    		    		
    		    	when Start_bit2 =>
    		    		tx <= '0';
    		    		C_REE <= '0';
    		    		tx_8_data <= D_IN(23 downto 16);
    		    		state_machine <= Valid_bit2;
    		    	when Valid_bit2 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit2;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit2;
    		    		end if;
    		    	when Stop_bit2 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit2;
    		    	when Exit_bit2 =>
    		    		tx <= '1';
    		    		state_machine <= Base3;
    		    	
    		    	---------------- 3rd Byte ---------------------
    		    	
    		    	when Base3 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit3;
    		    		
    		    	when Start_bit3 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN(15 downto 8);
    		    		state_machine <= Valid_bit3;
    		    	when Valid_bit3 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit3;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit3;
    		    		end if;
    		    	when Stop_bit3 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit3;
    		    	when Exit_bit3 =>
    		    		tx <= '1';
    		    		state_machine <= Base4;
    		    		
    		    	---------------- 4th Byte ---------------------
    		    	
    		    	when Base4 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit4;
    		    		
    		    	when Start_bit4 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN(7 downto 0);
    		    		state_machine <= Valid_bit4;
    		    	when Valid_bit4 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit4;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit4;
    		    		end if;
    		    	when Stop_bit4 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit4;
    		    	when Exit_bit4 =>
    		    		tx <= '1';
    		    		state_machine <= Base5;
    		    		
    		    	-------------------- 5th byte ------------------------
    		    	
    		    	when Base5 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit5;
    		    		
    		    	when Start_bit5 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN2(31 downto 24);
    		    		state_machine <= Valid_bit5;
    		    	when Valid_bit5 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit5;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit5;
    		    		end if;
    		    	when Stop_bit5 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit5;
    		    	when Exit_bit5 =>
    		    		tx <= '1';
    		    		state_machine <= Base6;
    		    		
    		    	-------------------- 6th byte ------------------------
    		    		
    		    	when Base6 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit6;
    		    		
    		    	when Start_bit6 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN2(23 downto 16);
    		    		state_machine <= Valid_bit6;
    		    	when Valid_bit6 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit6;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit6;
    		    		end if;
    		    	when Stop_bit6 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit6;
    		    	when Exit_bit6 =>
    		    		tx <= '1';
    		    		state_machine <= Base7;
    		    	
    		    	-------------------- 7th byte ------------------------
    		    		
    		    	when Base7 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit7;
    		    		
    		    	when Start_bit7 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN2(15 downto 8);
    		    		state_machine <= Valid_bit7;
    		    	when Valid_bit7 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit7;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit7;
    		    		end if;
    		    	when Stop_bit7 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit7;
    		    	when Exit_bit7 =>
    		    		tx <= '1';
    		    		state_machine <= Base8;
    		    		
    		    	-------------------- 8th byte ------------------------
    		         
    		        when Base8 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bit8;
    		    		
    		    	when Start_bit8 =>
    		    		tx <= '0';
    		    		tx_8_data <= D_IN2(7 downto 0);
    		    		state_machine <= Valid_bit8;
    		    	when Valid_bit8 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bit8;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bit8;
    		    		end if;
    		    	when Stop_bit8 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bit8;
    		    	when Exit_bit8 =>
    		    		tx <= '1';
    		    		state_machine <= BASEC1;
    		    		
    		    		
    		    	------------------------------------------- 9th byte : CC1
    		    	when BaseC1 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bitC1;
    		    	when Start_bitC1 =>
    		    		tx <= '0';
    		    		tx_8_data <= CA;
    		    		state_machine <= Valid_bitC1;
    		    	when Valid_bitC1 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bitC1;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bitC1;
    		    		end if;
    		    	when Stop_bitC1 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bitC1;
    		    	when Exit_bitC1 =>
    		    		tx <= '1';
    		    		state_machine <= BaseC2;

    		    	------------------------------------------- 10th byte : CC2
    		    	when BaseC2 =>
    		    		status <= '0';
    		    		tx <= '1';
    		    		state_machine <= Start_bitC2;
    		    	when Start_bitC2 =>
    		    		tx <= '0';
    		    		tx_8_data <= CB;
    		    		state_machine <= Valid_bitC2;
    		    	when Valid_bitC2 =>
    		    		tx <= tx_8_data(cnt_bit);
    		    		if(cnt_bit = 7) then
    		    			cnt_bit <= 0;
    		    			state_machine <= Stop_bitC2;
    		    		else
    		    			cnt_bit <= cnt_bit + 1;
    		    			state_machine <= Valid_bitC2;
    		    		end if;
    		    	when Stop_bitC2 =>
    		    		tx <= '1';
    		    		status <= '1';
    		    		state_machine <= Exit_bitC2;
    		    	when Exit_bitC2 =>
    		    		tx <= '1';
    		    		if PULSE_IN = '1' then
    		    			state_machine <= Exit_bitC2;
    		    		else
    		    			state_machine <= BASE1;
    		    		end if;
   ------------------------------------------------------------------FINISH
    		    end case;
			end if;
	end process;
	
end Behavioral;
