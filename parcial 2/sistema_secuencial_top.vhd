library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sistema_secuencial_top is
    Port (
        clk             : in  STD_LOGIC;                      
        

        ir_difuso_in    : in  STD_LOGIC;                      
        ir_barrera_in   : in  STD_LOGIC;                      
        
        
        tcs_out         : in  STD_LOGIC;                      
        s2              : out STD_LOGIC;                      
        s3              : out STD_LOGIC;                      
        

        color_out       : out STD_LOGIC_VECTOR(1 downto 0);   
        tamanio_out     : out STD_LOGIC_VECTOR(1 downto 0);   
        ciclo_terminado : out STD_LOGIC                       
    );
end sistema_secuencial_top;

architecture Behavioral of sistema_secuencial_top is

    
    component tcs3200_controller is
        Port (
            clk         : in  STD_LOGIC;
            tcs_out     : in  STD_LOGIC;
            s2          : out STD_LOGIC;
            s3          : out STD_LOGIC;
            color_code  : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    
    signal difuso_sync1, difuso_sync2   : STD_LOGIC := '1';
    signal barrera_sync1, barrera_sync2 : STD_LOGIC := '0';

    signal difuso_detectado : STD_LOGIC;
    signal barrera_activo   : STD_LOGIC;
    signal tamanio_crudo    : STD_LOGIC_VECTOR(1 downto 0);
    signal color_crudo      : STD_LOGIC_VECTOR(1 downto 0);

    
    constant TIEMPO_ESTABLE : integer := 2000000; 
    signal cnt_estabilidad  : integer range 0 to TIEMPO_ESTABLE := 0;

    
    signal barrera_fue_activada : STD_LOGIC := '0';

    
    signal tamanio_guardado : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal color_guardado   : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal reg_ciclo        : STD_LOGIC := '0';

    
    type estado_t is (
        ESPERANDO_LIBRE,
        ESPERANDO_PIEZA,
        MIDIENDO_TAMANO,
        MIDIENDO_COLOR, 
        MOSTRAR_RESULTADO
    );
    signal estado : estado_t := ESPERANDO_LIBRE;

begin

    
    process(clk)
    begin
        if rising_edge(clk) then
            difuso_sync1  <= ir_difuso_in;
            difuso_sync2  <= difuso_sync1;
            barrera_sync1 <= ir_barrera_in;
            barrera_sync2 <= barrera_sync1;
        end if;
    end process;

    
    
    
    difuso_detectado <= not difuso_sync2;
    barrera_activo   <= barrera_sync2; 

    
    process(difuso_detectado, barrera_activo)
    begin
        if (difuso_detectado = '1' and barrera_activo = '1') then
            tamanio_crudo <= "11"; 
        elsif (difuso_detectado = '1' and barrera_activo = '0') then
            tamanio_crudo <= "01"; 
        else
            tamanio_crudo <= "00"; 
        end if;
    end process;

   
    inst_sistema_col: tcs3200_controller
        port map (
            clk         => clk,
            tcs_out     => tcs_out,
            s2          => s2,
            s3          => s3,
            color_code  => color_crudo
        );

   
    process(clk)
    begin
        if rising_edge(clk) then
            case estado is
                
   
                when ESPERANDO_LIBRE =>
                    reg_ciclo        <= '0';
                    tamanio_guardado <= "00";
                    color_guardado   <= "00";
                    cnt_estabilidad  <= 0;
                    
                    if tamanio_crudo = "00" then
                        estado <= ESPERANDO_PIEZA;
                    end if;

                
                when ESPERANDO_PIEZA =>
                    reg_ciclo            <= '0';
                    tamanio_guardado     <= "00";
                    color_guardado       <= "00";
                    cnt_estabilidad      <= 0;
                    barrera_fue_activada <= '0';
                    
                    if tamanio_crudo /= "00" then
                        estado <= MIDIENDO_TAMANO;
                    end if;

                
                when MIDIENDO_TAMANO =>
                    if tamanio_crudo = "00" then
                        estado <= ESPERANDO_PIEZA; 
                    else
                        if barrera_activo = '1' then
                            barrera_fue_activada <= '1';
                        end if;

                        if cnt_estabilidad >= TIEMPO_ESTABLE then
                            if barrera_fue_activada = '1' or barrera_activo = '1' then
                                tamanio_guardado <= "11"; 
                            else
                                tamanio_guardado <= "01"; 
                            end if;

                            cnt_estabilidad  <= 0;
                            estado           <= MIDIENDO_COLOR;
                        else
                            cnt_estabilidad <= cnt_estabilidad + 1;
                        end if;
                    end if;

                
                when MIDIENDO_COLOR =>
                    if color_crudo /= "00" then
                        if cnt_estabilidad >= TIEMPO_ESTABLE then
                            color_guardado  <= color_crudo; 
                            cnt_estabilidad <= 0;
                            estado          <= MOSTRAR_RESULTADO;
                        else
                            cnt_estabilidad <= cnt_estabilidad + 1;
                        end if;
                    else
                        if cnt_estabilidad >= (TIEMPO_ESTABLE * 2) then
                            color_guardado  <= "11"; 
                            cnt_estabilidad <= 0;
                            estado          <= MOSTRAR_RESULTADO;
                        else
                            cnt_estabilidad <= cnt_estabilidad + 1;
                        end if;
                    end if;

                
                when MOSTRAR_RESULTADO =>
                    reg_ciclo <= '1'; 
                    
                    if tamanio_crudo /= "00" then
                        estado <= ESPERANDO_PIEZA;
                    end if;

                when others =>
                    estado <= ESPERANDO_LIBRE;
                    
            end case;
        end if;
    end process;

    
    tamanio_out     <= tamanio_guardado;
    color_out       <= color_guardado;
    ciclo_terminado <= reg_ciclo;

end Behavioral;