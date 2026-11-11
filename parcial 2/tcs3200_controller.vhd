library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tcs3200_controller is
    Port (
        clk             : in  STD_LOGIC;                     
        tcs_out         : in  STD_LOGIC;                     
        
        
        s2              : out STD_LOGIC;
        s3              : out STD_LOGIC;
        
        
        color_code      : out STD_LOGIC_VECTOR(1 downto 0)
    );
end tcs3200_controller;

architecture Behavioral of tcs3200_controller is

   
   
    constant VENTANA_TIEMPO : integer := 2000000;
    signal timer_cnt        : integer range 0 to VENTANA_TIEMPO := 0;

   
    signal fase_color       : integer range 0 to 2 := 0;

   
    signal freq_rojo        : integer range 0 to 131071 := 0;
    signal freq_verde       : integer range 0 to 131071 := 0;
    signal freq_azul        : integer range 0 to 131071 := 0;
    signal pulse_counter    : integer range 0 to 131071 := 0;

   
    signal tcs_sync1        : STD_LOGIC := '0';
    signal tcs_sync2        : STD_LOGIC := '0';

    signal codigo_interno   : STD_LOGIC_VECTOR(1 downto 0) := "00";

begin

   
    process(clk)
    begin
        if rising_edge(clk) then
            tcs_sync1 <= tcs_out;
            tcs_sync2 <= tcs_sync1;
        end if;
    end process;

   
    process(clk)
    begin
        if rising_edge(clk) then
   
            if (tcs_sync1 = '1' and tcs_sync2 = '0') then
                if pulse_counter < 131071 then
                    pulse_counter <= pulse_counter + 1;
                end if;
            end if;

           
            if timer_cnt >= VENTANA_TIEMPO then
                timer_cnt <= 0;
                
                case fase_color is
                    when 0 =>
                        freq_rojo  <= pulse_counter;
                        fase_color <= 1; 
                        s2 <= '1'; s3 <= '1'; 
                        
                    when 1 =>
                        freq_verde <= pulse_counter;
                        fase_color <= 2; 
                        s2 <= '0'; s3 <= '1'; 
                        
                    when 2 =>
                        freq_azul  <= pulse_counter;
                        fase_color <= 0; 
                        s2 <= '0'; s3 <= '0'; 
                        
                    when others =>
                        fase_color <= 0;
                end case;
                
                pulse_counter <= 0;
            else
                timer_cnt <= timer_cnt + 1;
            end if;
        end if;
    end process;

   
    process(freq_rojo, freq_verde, freq_azul)
   
        constant UMBRAL_MINIMO : integer := 400; 
    begin
   
        if (freq_rojo < UMBRAL_MINIMO) and (freq_verde < UMBRAL_MINIMO) and (freq_azul < UMBRAL_MINIMO) then
   
            
   
        elsif (freq_rojo > freq_verde) and (freq_rojo > freq_azul) then
            codigo_interno <= "01"; -- ROJO
            
        elsif (freq_verde > freq_rojo) and (freq_verde > freq_azul) then
            codigo_interno <= "10"; -- VERDE
            
        elsif (freq_azul > freq_rojo) and (freq_azul > freq_verde) then
            codigo_interno <= "11"; -- AZUL
            
        else
            codigo_interno <= "00";
        end if;
    end process;


    color_code <= codigo_interno;

end Behavioral;