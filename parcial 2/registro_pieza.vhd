library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registro_pieza is
    Port (
        clk             : in  STD_LOGIC;                      
        guardar_en      : in  STD_LOGIC;                      
        
        
        color_in        : in  STD_LOGIC_VECTOR(3 downto 0);   
        tamano_in       : in  STD_LOGIC_VECTOR(1 downto 0);   
        
        
        color_out       : out STD_LOGIC_VECTOR(3 downto 0);
        tamano_out      : out STD_LOGIC_VECTOR(1 downto 0)
    );
end registro_pieza;

architecture Behavioral of registro_pieza is
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if guardar_en = '1' then
                color_out  <= color_in;
                tamano_out <= tamano_in;
            end if;
            
        end if;
    end process;

end Behavioral;