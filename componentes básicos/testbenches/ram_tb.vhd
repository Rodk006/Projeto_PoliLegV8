--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)
-------------------------------------------------------------------
-- código ADAPTADO de ram_tb.vhd (fornecido)
-------------------------------------------------------------------

library ieee;

entity tb_ram is
end entity tb_ram;

architecture test_cases of tb_ram is

    -- Componente a ser testado (DUT - Device Under Test)
    component memoriaDados is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memDados_conteudo_inicial.dat"
        );
        port (
            clock 	: in  bit;
            wr 		: in  bit;
            addr 	: in  bit_vector (addressSize - 1 downto 0);
            data_i 	: in  bit_vector (dataSize - 1 downto 0);
            data_o 	: out bit_vector (dataSize - 1 downto 0)
        );
    end component memoriaDados;

    -- Sinais de entrada para o DUT
    signal s_clk          : bit := '0';
    signal s_addr     : bit_vector(6 downto 0) := (others => '0');
    signal s_data_i : bit_vector(7 downto 0) := (others => '0');
    signal s_wr         : bit := '0';

    -- Sinal de saida do DUT
    signal s_data_o : bit_vector(7 downto 0);

    -- Constante para o periodo do clock
    constant CLK_PERIOD : time := 10 us;
    
    -- Sinal de controle de fim de simulação
    signal keep_simulating : bit := '0';    

    function int_to_bitvector(value : integer; N : natural) return bit_vector is
        variable result : bit_vector(N-1 downto 0) := (others => '0');
        variable temp   : integer := value;
    begin
        for i in 0 to N-1 loop
            if (temp mod 2) = 1 then
                result(i) := '1';
            else
                result(i) := '0';
            end if;
            temp := temp / 2;
        end loop;
        return result;
    end function;

    -- funcao de conversão bit_vector para integer
    function bitvector_to_int(bv : bit_vector) return integer is
        variable result : integer := 0;
        variable idx    : integer := 0;
        begin
            for i in bv'reverse_range loop
                if bv(i) = '1' then
                    result := result + (2**idx);
                end if;
                idx := idx + 1;
            end loop;
        return result;
    end function;


begin

    -- Geração do clock
    s_clk <= not(s_clk) and keep_simulating after CLK_PERIOD/2;

    -- Instanciacao do DUT
    UUT: memoriaDados
        generic map (
            addressSize => 7,
            dataSize  => 8,
            datFileName => "memDados_conteudo_inicial.dat"
        )
        port map (
            clock => s_clk,
            wr => s_wr,
            addr => s_addr,
            data_i => s_data_i,
            data_o => s_data_o
        );

    -- Geração de estímulos e verificação
    gera_estimulos : process
        variable expected_data : bit_vector(7 downto 0);
        variable actual_data   : bit_vector(7 downto 0);
    begin
        -- === Inicio do Teste ===
        keep_simulating <= '1';
        wait for CLK_PERIOD;
        report "Inicio do Testbench para a RAM." severity note;

        -- ==========================================================
        -- FASE 1: leitura assíncrona dos dados iniciais
        -- ==========================================================
        report "Fase de leitura incial." severity note;

        --teste 1: entrada zerada
        s_addr <= (others => '0');
        wait for CLK_PERIOD;

        assert s_data_o = "10000000" report "Teste de leitura da posição 0 falhou" severity error;

        --teste 2: entrada máxima
        s_addr <= (others => '1');
        wait for CLK_PERIOD;

        assert s_data_o = "00000000" report "Teste de leitura da posição 127 falhou" severity error;

        --teste 3: entrada intermediária
        s_addr <= "0001111";
        wait for CLK_PERIOD;

        assert s_data_o = "00001001" report "Teste de leitura da posição 15 falhou" severity error;
       

        -- ==========================================================
        -- FASE 2: Escrita dos dados na memoria
        -- ==========================================================
        report "Fase de Escrita: Escrevendo valores de 15 a 0 nos enderecos de 0 a 15." severity note;
        s_wr <= '1'; -- Ativa a escrita 
        wait until s_clk'event and s_clk = '1';

        for i in 0 to 15 loop
            s_addr     <= int_to_bitvector(i, 7);
            s_data_i <= int_to_bitvector(15 - i, 8);
            wait until s_clk'event and s_clk = '1';
        end loop;

        -- ==========================================================
        -- FASE 3: Leitura e Verificacao dos dados
        -- ==========================================================
        report "Fase de Leitura e Verificacao." severity note;
        s_wr <= '0'; -- Ativa modo de leitura
        wait until s_clk'event and s_clk = '1';

        for i in 0 to 15 loop
            -- Seleciona Endereço
            s_addr <= int_to_bitvector(i, 7);

            -- Espera até que o dado seja lido e propagado para a saida
            wait for CLK_PERIOD*3;

            expected_data := int_to_bitvector(15 - i, 8);
            actual_data := s_data_o;

            assert actual_data = expected_data
                report "Caso de Teste " & integer'image(i) & 
                       " NOK: esperado " & integer'image(bitvector_to_int(expected_data)) & 
                       " mas foi lido " & integer'image(bitvector_to_int(actual_data))
                severity error; 
        end loop;
        
        -- === Fim do Teste ===
        keep_simulating <= '0';
        report "Fim do Testbench." severity note;
        wait;
    end process gera_estimulos;

end architecture test_cases;
