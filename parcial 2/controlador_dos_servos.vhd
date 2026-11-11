library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlador_dos_servos is
    Port (
        clk           : in  STD_LOGIC;                      
        activar_servo1: in  STD_LOGIC;                      
        activar_servo2: in  STD_LOGIC;                      
        servo1_out    : out STD_LOGIC;                      
        servo2_out    : out STD_LOGIC                       
    );
end controlador_dos_servos;

architecture Behavioral of controlador_dos_servos is

    
    constant PERIODE_TOTAL   : integer := 1000000;
    
    
    constant PULSE_0GRADOS   : integer := 50000; 
    constant PULSE_180GRADOS : integer := 100000;  

    signal period_counter    : integer range 0 to PERIODE_TOTAL := 0;
    signal width_servo1      : integer range 0 to PERIODE_TOTAL := PULSE_0GRADOS;
    signal width_servo2      : integer range 0 to PERIODE_TOTAL := PULSE_0GRADOS;

begin

    
    process(clk)
    begin
        if rising_edge(clk) then
            if activar_servo1 = '1' then
                width_servo1 <= PULSE_180GRADOS;
            else
                width_servo1 <= PULSE_0GRADOS;
            end if;
        end if;
    end process;

    
    process(clk)
    begin
        if rising_edge(clk) then
            if activar_servo2 = '1' then
                width_servo2 <= PULSE_180GRADOS;
            else
                width_servo2 <= PULSE_0GRADOS;
            end if;
        end if;
    end process;

    
    process(clk)
    begin
        if rising_edge(clk) then
            if period_counter >= PERIODE_TOTAL - 1 then
                period_counter <= 0;
            else
                period_counter <= period_counter + 1;
            end if;
        end if;
    end process;

    
    process(clk)
    begin
        if rising_edge(clk) then
            if period_counter < width_servo1 then
                servo1_out <= '1';
            else
                servo1_out <= '0';
            end if;
        end if;
    end process;

    
    process(clk)
    begin
        if rising_edge(clk) then
            if period_counter < width_servo2 then
                servo2_out <= '1';
            else
                servo2_out <= '0';
            end if;
        end if;
    end process;

end Behavioral;