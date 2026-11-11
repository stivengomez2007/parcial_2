library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    Port (
        clk     : in  STD_LOGIC;
        we      : in  STD_LOGIC;                      
        address : in  STD_LOGIC_VECTOR(3 downto 0);   
        data_in : in  STD_LOGIC_VECTOR(7 downto 0);   
        data_out: out STD_LOGIC_VECTOR(7 downto 0)    
    );
end ram;

architecture Behavioral of ram is
    
    type ram_type is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    signal ram_memory : ram_type := (others => (others => '0')); 
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (we = '1') then
                ram_memory(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;

    
    data_out <= ram_memory(to_integer(unsigned(address)));

end Behavioral;