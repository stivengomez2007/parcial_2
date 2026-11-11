library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity separador_digitos is
    Port (
        bin_in    : in  STD_LOGIC_VECTOR(7 downto 0);   
        centenas  : out STD_LOGIC_VECTOR(3 downto 0);   
        decenas   : out STD_LOGIC_VECTOR(3 downto 0);   
        unidades  : out STD_LOGIC_VECTOR(3 downto 0)    
    );
end separador_digitos;

architecture Behavioral of separador_digitos is
begin

    process(bin_in)
        variable valor : integer range 0 to 255;
        variable c, d, u : integer range 0 to 9;
    begin
        
        valor := to_integer(unsigned(bin_in));
        
        
        c := valor / 100;                 
        d := (valor / 10) mod 10;         
        u := valor mod 10;                
        
        
        centenas <= std_logic_vector(to_unsigned(c, 4));
        decenas  <= std_logic_vector(to_unsigned(d, 4));
        unidades <= std_logic_vector(to_unsigned(u, 4));
        
    end process;

end Behavioral;