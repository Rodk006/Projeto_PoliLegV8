-------------------------------------------------------------------
-- Arquivo: tb_ram_generica.vhd
-- Descricao: Testbench para a memoria RAM sincrona de tamanho parametrizável, alocando o tamanho 16x4
--
-- Comportamento do Testbench:
-- 1. Escreve os dados de 15 a 0 nos enderecos de 0 a 15.
-- 2. Le cada um dos enderecos de 0 a 15.
-- 3. Verifica se o dado lido e o mesmo que foi escrito.
-- 4. Indica o sucesso ou a falha para cada caso de teste.
--
-- código ADAPTADO de tb_ram_16x4.vhd 
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Revisoes:
-- Data       Versao Autor               Descricao
-- 07/10/2025 1.0    Pedro H. F. Mendes  Versão inicial para PCS3225
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ram_generica is
end entity tb_ram_generica;

architecture test_cases of tb_ram_generica is

    -- Componente a ser testado (DUT - Device Under Test)
    component ram_generica is
        generic (
            tamanhoEndereco : natural := 4;
            tamanhoPalavra  : natural := 4
        );
        port (
            clk          : in  std_logic;
            endereco     : in  std_logic_vector(tamanhoEndereco-1 downto 0);
            dado_entrada : in  std_logic_vector(tamanhoPalavra-1 downto 0);
            n_we         : in  std_logic;
            n_cs         : in  std_logic;
            dado_saida   : out std_logic_vector(tamanhoPalavra-1 downto 0)
        );
    end component ram_generica;

    -- Sinais de entrada para o DUT
    signal s_clk          : std_logic := '0';
    signal s_endereco     : std_logic_vector(3 downto 0) := (others => '0');
    signal s_dado_entrada : std_logic_vector(3 downto 0) := (others => '0');
    signal s_n_we         : std_logic := '1';
    signal s_n_cs         : std_logic := '1';

    -- Sinal de saida do DUT
    signal s_dado_saida : std_logic_vector(3 downto 0);

    -- Constante para o periodo do clock
    constant CLK_PERIOD : time := 10 us;
    
    -- Sinal de controle de fim de simulação
    signal keep_simulating : std_logic := '0';    

begin

    -- Geração do clock
    s_clk <= not(s_clk) and keep_simulating after CLK_PERIOD/2;

    -- Instanciacao do DUT
    dut_ram : ram_generica
        generic map (
            tamanhoEndereco => 4,
            tamanhoPalavra  => 4
        )
        port map (
            clk          => s_clk,
            endereco     => s_endereco,
            dado_entrada => s_dado_entrada,
            n_we         => s_n_we,
            n_cs         => s_n_cs,
            dado_saida   => s_dado_saida
        );

    -- Geração de estímulos e verificação
    gera_estimulos : process
        variable expected_data : std_logic_vector(3 downto 0);
        variable actual_data   : std_logic_vector(3 downto 0);
    begin
        -- === Inicio do Teste ===
        keep_simulating <= '1';
        wait for CLK_PERIOD;
        report "Inicio do Testbench para a RAM Generica 16x4." severity note;

        -- ==========================================================
        -- FASE 1: Escrita dos dados na memoria
        -- ==========================================================
        report "Fase de Escrita: Escrevendo valores de 15 a 0 nos enderecos de 0 a 15." severity note;
        s_n_cs <= '0'; -- Ativa o chip
        s_n_we <= '0'; -- Ativa a escrita 
        wait until rising_edge(s_clk);

        for i in 0 to 15 loop
            s_endereco     <= std_logic_vector(to_unsigned(i, 4));
            s_dado_entrada <= std_logic_vector(to_unsigned(15 - i, 4));
            wait until rising_edge(s_clk);
        end loop;

        -- ==========================================================
        -- FASE 2: Leitura e Verificacao dos dados
        -- ==========================================================
        report "Fase de Leitura e Verificacao." severity note;
        s_n_cs <= '0'; -- Ativa o chip
        s_n_we <= '1'; -- Ativa modo de leitura
        wait until rising_edge(s_clk);

        for i in 0 to 15 loop
            -- Seleciona Endereço
            s_endereco <= std_logic_vector(to_unsigned(i, 4));

            -- Espera até que o dado seja lido e propagado para a saida
            wait for CLK_PERIOD*3;

            expected_data := std_logic_vector(to_unsigned(15 - i, 4));
            actual_data := s_dado_saida;

            assert actual_data = expected_data
                report "Caso de Teste " & integer'image(i) & 
                       " NOK: esperado " & integer'image(to_integer(unsigned(expected_data))) & 
                       " mas foi lido " & integer'image(to_integer(unsigned(actual_data)))
                severity error; 
        end loop;
        
        -- ==========================================================
        -- FASE 3: Verifica se a saida e' 'Z' com /CS = 1.
        -- ==========================================================
        s_n_cs <= '1';
        wait for CLK_PERIOD*3;
        
        -- Verificação de alta impedância sem usar 'image'
        if s_dado_saida /= "ZZZZ" then
            report "Caso de Teste de Alta Impedância NOK: esperado 'ZZZZ'"
                severity error;
        end if;
        
        -- === Fim do Teste ===
        keep_simulating <= '0';
        report "Fim do Testbench." severity note;
        wait;
    end process gera_estimulos;

end architecture test_cases;