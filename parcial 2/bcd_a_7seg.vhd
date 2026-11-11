library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_a_7seg is
    Port (
        bcd_in    : in  STD_LOGIC_VECTOR(3 downto 0);   -- Dígito BCD de entrada (0 a 9)
        segments  : out STD_LOGIC_VECTOR(6 downto 0)    -- Salida para los segmentos (g, f, e, d, c, b, a)
    );
end bcd_a_7seg;

architecture Behavioral of bcd_a_7seg is
begin
    -- Tabla de verdad para Displays de ÁNODO COMÚN (Enciende con '0')
    process(bcd_in)
    begin
        case bcd_in is
            when "0000" => segments <= "1000000"; -- Muestra '0' (Enciende a, b, c, d, e, f)
            when "0001" => segments <= "1111001"; -- Muestra '1' (Enciende b, c)
            when "0010" => segments <= "0100100"; -- Muestra '2' (Enciende a, b, d, e, g)
            when "0011" => segments <= "0110000"; -- Muestra '3' (Enciende a, b, c, d, g)
            when "0100" => segments <= "0011001"; -- Muestra '4' (Enciende b, c, f, g)
            when "0101" => segments <= "0010010"; -- Muestra '5' (Enciende a, c, d, f, g)
            when "0110" => segments <= "0000010"; -- Muestra '6' (Enciende a, c, d, e, f, g)
            when "0111" => segments <= "1111000"; -- Muestra '7' (Enciende a, b, c)
            when "1000" => segments <= "0000000"; -- Muestra '8' (Enciende todos)
            when "1001" => segments <= "0010000"; -- Muestra '9' (Enciende a, b, c, d, f, g)
            when others => segments <= "1111111"; -- Apagado total (todos en '1') para valores no válidos
        end case;
    end process;

end Behavioral;