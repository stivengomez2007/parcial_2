library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    Port (
        clk     : in  STD_LOGIC;
        address : in  STD_LOGIC_VECTOR(3 downto 0); -- 16 direcciones (4 bits)
        data_out: out STD_LOGIC_VECTOR(7 downto 0)  -- Ancho de palabra de 8 bits
    );
end rom;

architecture Behavioral of rom is
    -- Tipo para la matriz de la ROM (16 posiciones de 8 bits)
    type rom_type is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    
    -- Inicialización de la ROM (Aquí puedes precargar las instrucciones del programa si es necesario)
    constant ROM_DATA : rom_type := (
        0 => "00000001", -- Instrucción de ejemplo 0
        1 => "00000010", -- Instrucción de ejemplo 1
        others => (others => '0')
    );
begin

    process(clk)
    begin
        if rising_edge(clk) then
            data_out <= ROM_DATA(to_integer(unsigned(address)));
        end if;
    end process;

end Behavioral;