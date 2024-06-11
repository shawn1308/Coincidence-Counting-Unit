-- Set Generic g_CLKS_PER_BIT as follows:
-- CLKS_PER_BIT = (Frequency of Clk)/(Frequency of UART)
-- 100 MHz Clock, 115200 baud UART
-- (100000000)/(115200) = 868
-- (100000000)/(250000) = 400
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_RX is
  generic (
    CLKS_PER_BIT : integer := 400       -- pour 100MHz horloge et 250000 bps
    );
  port (
    clk         : in  std_logic;
    RX_Serial   : in  std_logic;
    data_send   : out std_logic;
    RX_Byte     : out std_logic_vector(7 downto 0)
	 );
end UART_RX; 
 
architecture Behavioral of UART_RX is
 
  type etat is (attente, Start_Bit, RX_Data_Bits,Stop_Bit, s_Cleanup);
							
  signal state_machine: etat;
 							
  signal r_RX_Data_R : std_logic := '0';
  signal r_RX_Data   : std_logic := '0';
   
  signal Clk_Count : integer range 0 to CLKS_PER_BIT-1 := 0;
  signal clk_count_bis : std_logic_vector(15 downto 0);
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_data_send     : std_logic := '0';
  
begin
  process (clk)
  begin
    if rising_edge(clk) then
      r_RX_Data_R <= RX_Serial;
      r_RX_Data   <= r_RX_Data_R;
   end if;
  end process;
   
  -- Purpose: Control RX state machine
  process(clk)
  begin
    if rising_edge(clk) then
         
      case state_machine is
 
        when attente =>
          r_data_send <= '0';
          Clk_Count <= 0;
          r_Bit_Index <= 0;
 
          if r_RX_Data = '0' then       -- Start bit detected
            state_machine <= Start_Bit;
          else
            state_machine <= attente;
          end if;
 
           
        -- Check middle of start bit to make sure it's still low
		  
        when Start_Bit =>
          if Clk_Count = (CLKS_PER_BIT-1)/2 then
            if r_RX_Data = '0' then
              Clk_Count <= 0;  -- reset counter since we found the middle
              state_machine   <= RX_Data_Bits;
            else
              state_machine <= attente;
            end if;
          else
            Clk_Count <= Clk_Count + 1;
            state_machine   <= Start_Bit;
          end if;
 
           
        -- Wait CLKS_PER_BIT-1 clock cycles to sample serial data
		  
        when RX_Data_Bits =>
          if Clk_Count < CLKS_PER_BIT-1 then
            Clk_Count <= Clk_Count + 1;
            state_machine   <= RX_Data_Bits;
          else
            Clk_Count <= 0;
            r_RX_Byte(r_Bit_Index) <= r_RX_Data;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              state_machine   <= RX_Data_Bits;
            else
              r_Bit_Index <= 0;
              state_machine   <= Stop_Bit;
            end if;
          end if;
 
 
        -- Receive Stop bit.  Stop bit = 1
		  
        when Stop_Bit =>
          -- Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if Clk_Count < CLKS_PER_BIT-1 then
            Clk_Count <= Clk_Count + 1;
            state_machine   <= Stop_Bit;
          else
            r_data_send <= '1';
            Clk_Count <= 0;
            state_machine   <= s_Cleanup;
          end if;
 
                   
        -- Stay here 1 clock
        when s_Cleanup =>
          state_machine <= attente;
          r_data_send <= '0';
 
             
        --when others =>
         -- state_machine <= attente;
 
      end case;
end if;	
end process;
  
   data_send <= r_data_send;
   RX_Byte <= r_RX_Byte;

end Behavioral;