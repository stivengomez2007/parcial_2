library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clasificador_piezas_completo is
    Port (
        clk             : in  STD_LOGIC;                      
        
       
        ir_difuso_in    : in  STD_LOGIC;
        ir_barrera_in   : in  STD_LOGIC;
        

        tcs_out         : in  STD_LOGIC;
        s2              : out STD_LOGIC;
        s3              : out STD_LOGIC;
        

        selector_modo   : in  STD_LOGIC_VECTOR(2 downto 0);   
        
        
        selector_tiempo : in  STD_LOGIC_VECTOR(1 downto 0);   
        
        
        seg_centenas    : out STD_LOGIC_VECTOR(6 downto 0);
        seg_decenas     : out STD_LOGIC_VECTOR(6 downto 0);
        seg_unidades    : out STD_LOGIC_VECTOR(6 downto 0);
        
        
        servo1_out      : out STD_LOGIC;
        servo2_out      : out STD_LOGIC;
        
        
        led_ciclo       : out STD_LOGIC
    );
end clasificador_piezas_completo;

architecture Behavioral of clasificador_piezas_completo is

    
    component sistema_secuencial_top is
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
    end component;

    component registro_pieza is
        Port (
            clk             : in  STD_LOGIC;
            guardar_en      : in  STD_LOGIC;
            color_in        : in  STD_LOGIC_VECTOR(3 downto 0);
            tamano_in       : in  STD_LOGIC_VECTOR(1 downto 0);
            color_out       : out STD_LOGIC_VECTOR(3 downto 0);
            tamano_out      : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component ram is
        Port (
            clk             : in  STD_LOGIC;
            we              : in  STD_LOGIC;
            address         : in  STD_LOGIC_VECTOR(3 downto 0);
            data_in         : in  STD_LOGIC_VECTOR(7 downto 0);
            data_out        : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component rom is
        Port (
            clk             : in  STD_LOGIC;
            address         : in  STD_LOGIC_VECTOR(3 downto 0);
            data_out        : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component controlador_dos_servos is
        Port (
            clk           : in  STD_LOGIC;
            activar_servo1: in  STD_LOGIC;
            activar_servo2: in  STD_LOGIC;
            servo1_out    : out STD_LOGIC;
            servo2_out    : out STD_LOGIC
        );
    end component;

    component separador_digitos is
        Port (
            bin_in          : in  STD_LOGIC_VECTOR(7 downto 0);
            centenas        : out STD_LOGIC_VECTOR(3 downto 0);
            decenas         : out STD_LOGIC_VECTOR(3 downto 0);
            unidades        : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component bcd_a_7seg is
        Port (
            bcd_in          : in  STD_LOGIC_VECTOR(3 downto 0);
            segments        : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    
    signal w_color_det      : STD_LOGIC_VECTOR(1 downto 0);
    signal w_tamano_det     : STD_LOGIC_VECTOR(1 downto 0);
    signal w_ciclo_term     : STD_LOGIC;
    
    
    signal w_reg_color      : STD_LOGIC_VECTOR(3 downto 0);
    signal w_reg_tamano     : STD_LOGIC_VECTOR(1 downto 0);
    
  
    signal w_ram_we         : STD_LOGIC := '0';
    signal w_ram_addr       : STD_LOGIC_VECTOR(3 downto 0);
    signal addr_escritura   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal addr_lectura     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    signal w_ram_din        : STD_LOGIC_VECTOR(7 downto 0);
    signal w_ram_dout       : STD_LOGIC_VECTOR(7 downto 0);
    signal w_rom_dout       : STD_LOGIC_VECTOR(7 downto 0);
    
  
    type estado_ram_t is (ESPERAR_CICLO, CALCULAR_DIR, ESCRIBIR_RAM, ACTUALIZAR_TOTAL, ESCRIBIR_TOTAL, ESPERAR_LIBRE);
    signal estado_ram : estado_ram_t := ESPERAR_CICLO;

  
    signal w_tiempo_sistema : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal contador_ms      : integer range 0 to 50000000 := 0;
    
  
    signal flag_activar_s1  : STD_LOGIC := '0';
    signal flag_activar_s2  : STD_LOGIC := '0';
    signal contador_servo1  : integer range 0 to 500000000 := 0;
    signal contador_servo2  : integer range 0 to 500000000 := 0;
    signal limite_tiempo    : integer range 0 to 500000000 := 0;
    signal temp_activo_s1   : STD_LOGIC := '0';
    signal temp_activo_s2   : STD_LOGIC := '0';

  
    signal dato_a_mostrar   : STD_LOGIC_VECTOR(7 downto 0);
    signal bcd_C, bcd_D, bcd_U : STD_LOGIC_VECTOR(3 downto 0);
    signal escribiendo_ram  : STD_LOGIC := '0';

begin

  
    process(clk)
    begin
        if rising_edge(clk) then
            if contador_ms = 50000000 - 1 then
                contador_ms <= 0;
                w_tiempo_sistema <= std_logic_vector(unsigned(w_tiempo_sistema) + 1);
            else
                contador_ms <= contador_ms + 1;
            end if;
        end if;
    end process;

  
    U_SISTEMA_SEC: sistema_secuencial_top
        port map (
            clk             => clk,
            ir_difuso_in    => ir_difuso_in,
            ir_barrera_in   => ir_barrera_in,
            tcs_out         => tcs_out,
            s2              => s2,
            s3              => s3,
            color_out       => w_color_det,
            tamanio_out     => w_tamano_det,
            ciclo_terminado => w_ciclo_term
        );

  
    U_REG_PIEZA: registro_pieza
        port map (
            clk             => clk,
            guardar_en      => w_ciclo_term,
            color_in        => "00" & w_color_det,
            tamano_in       => w_tamano_det,
            color_out       => w_reg_color,
            tamano_out      => w_reg_tamano
        );

  
    U_RAM_INVENTARIO: ram
        port map (
            clk             => clk,
            we              => w_ram_we,
            address         => w_ram_addr,
            data_in         => w_ram_din,
            data_out        => w_ram_dout
        );

  
    U_ROM_INSTRUCCIONES: rom
        port map (
            clk             => clk,
            address         => "0" & selector_modo,
            data_out        => w_rom_dout
        );

  
    U_SERVOS: controlador_dos_servos
        port map (
            clk            => clk,
            activar_servo1 => flag_activar_s1,
            activar_servo2 => flag_activar_s2,
            servo1_out     => servo1_out,
            servo2_out     => servo2_out
        );

  
    process(selector_tiempo)
    begin
        case selector_tiempo is
            when "01"   => limite_tiempo <= 200000000; -- 4 segundos (4 * 50M)
            when "10"   => limite_tiempo <= 300000000; -- 6 segundos (6 * 50M)
            when "11"   => limite_tiempo <= 500000000; -- 10 segundos (10 * 50M)
            when others => limite_tiempo <= 0;         -- Desactivado ("00")
        end case;
    end process;

    
    process(clk)
    begin
        if rising_edge(clk) then
            if w_ciclo_term = '1' then
                if w_tamano_det = "01" and w_color_det = "01" then
                    if selector_tiempo /= "00" then
                        flag_activar_s1 <= '1';
                        temp_activo_s1  <= '1';
                        contador_servo1 <= 0;
                    end if;
                end if;
            end if;

            if temp_activo_s1 = '1' then
                if contador_servo1 >= limite_tiempo - 1 then
                    flag_activar_s1 <= '0';
                    temp_activo_s1  <= '0';
                    contador_servo1 <= 0;
                else
                    contador_servo1 <= contador_servo1 + 1;
                end if;
            end if;
        end if;
    end process;

    
    process(clk)
    begin
        if rising_edge(clk) then
            if w_ciclo_term = '1' then
                if w_tamano_det = "11" and w_color_det = "11" then
                    if selector_tiempo /= "00" then
                        flag_activar_s2 <= '1';
                        temp_activo_s2  <= '1';
                        contador_servo2 <= 0;
                    end if;
                end if;
            end if;

            if temp_activo_s2 = '1' then
                if contador_servo2 >= limite_tiempo - 1 then
                    flag_activar_s2 <= '0';
                    temp_activo_s2  <= '0';
                    contador_servo2 <= 0;
                else
                    contador_servo2 <= contador_servo2 + 1;
                end if;
            end if;
        end if;
    end process;

    -- Máquina de Estados de la RAM
    process(clk)
        variable dir_v : integer range 0 to 15 := 0;
    begin
        if rising_edge(clk) then
            case estado_ram is
                when ESPERAR_CICLO =>
                    w_ram_we        <= '0';
                    escribiendo_ram <= '0';
                    if w_ciclo_term = '1' then
                        escribiendo_ram <= '1';
                        estado_ram      <= CALCULAR_DIR;
                    end if;

                when CALCULAR_DIR =>
                    escribiendo_ram <= '1';
                    if w_tamano_det = "11" then
                        if w_color_det = "01"    then dir_v := 1; 
                        elsif w_color_det = "10" then dir_v := 2; 
                        elsif w_color_det = "11" then dir_v := 3; -- Azul Grande
                        else dir_v := 0;
                        end if;
                    elsif w_tamano_det = "01" then
                        if w_color_det = "01"    then dir_v := 4; -- Rojo Pequeño
                        elsif w_color_det = "10" then dir_v := 5; 
                        elsif w_color_det = "11" then dir_v := 6; 
                        else dir_v := 0;
                        end if;
                    else
                        dir_v := 0;
                    end if;
                    
                    addr_escritura <= std_logic_vector(to_unsigned(dir_v, 4));
                    estado_ram     <= ESCRIBIR_RAM;

                when ESCRIBIR_RAM =>
                    escribiendo_ram <= '1';
                    w_ram_din       <= std_logic_vector(unsigned(w_ram_dout) + 1);
                    w_ram_we        <= '1'; 
                    estado_ram      <= ACTUALIZAR_TOTAL;

                when ACTUALIZAR_TOTAL =>
                    escribiendo_ram <= '1';
                    w_ram_we        <= '0'; 
                    addr_escritura  <= "0111"; 
                    estado_ram      <= ESCRIBIR_TOTAL;

                when ESCRIBIR_TOTAL =>
                    escribiendo_ram <= '1';
                    w_ram_din       <= std_logic_vector(unsigned(w_ram_dout) + 1);
                    w_ram_we        <= '1'; 
                    estado_ram      <= ESPERAR_LIBRE;

                when ESPERAR_LIBRE =>
                    w_ram_we        <= '0';
                    escribiendo_ram <= '0';
                    if w_ciclo_term = '0' then
                        estado_ram  <= ESPERAR_CICLO;
                    end if;

                when others =>
                    estado_ram      <= ESPERAR_CICLO;
                    escribiendo_ram <= '0';
            end case;
        end if;
    end process;

    
    process(selector_modo)
    begin
        case selector_modo is
            when "001" => addr_lectura <= "0001"; 
            when "010" => addr_lectura <= "0100"; 
            when "011" => addr_lectura <= "0010"; 
            when "100" => addr_lectura <= "0101"; 
            when "101" => addr_lectura <= "0011"; 
            when "110" => addr_lectura <= "0110"; 
            when "111" => addr_lectura <= "0111"; 
            when others => addr_lectura <= "0000";
        end case;
    end process;

    w_ram_addr <= addr_escritura when (escribiendo_ram = '1') else addr_lectura;

    
    process(selector_modo, w_tiempo_sistema, w_reg_color, w_reg_tamano, w_ram_dout)
    begin
        case selector_modo is
            when "000" => 
                dato_a_mostrar <= "00" & w_reg_tamano & w_reg_color; 
            when "001" | "010" | "011" | "100" | "101" | "110" | "111" => 
                dato_a_mostrar <= w_ram_dout;
            when others =>
                dato_a_mostrar <= (others => '0');
        end case;
    end process;

    
    U_SEP: separador_digitos
        port map (
            bin_in   => dato_a_mostrar,
            centenas => bcd_C,
            decenas  => bcd_D,
            unidades => bcd_U
        );

    
    U_7SEG_C: bcd_a_7seg port map ( bcd_in => bcd_C, segments => seg_centenas );
    U_7SEG_D: bcd_a_7seg port map ( bcd_in => bcd_D, segments => seg_decenas );
    U_7SEG_U: bcd_a_7seg port map ( bcd_in => bcd_U, segments => seg_unidades );

    led_ciclo <= w_ciclo_term;

end Behavioral;