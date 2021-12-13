

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk25 is
Port (
    clk, reset: in  std_logic;
    clk25:  out std_logic 
);
end clk25;

architecture Behavioral of clk25 is
signal cpt: integer range 0 to 3;

begin
    process(clk,reset)
    begin
        if reset='1' then cpt <= 0;
        elsif rising_edge (clk) then 
            if cpt = 3 then cpt <= 0; clk25 <= '1'; 
            else cpt <= cpt+1; clk25 <='0';end if;
        end if;
    end process;

end Behavioral;