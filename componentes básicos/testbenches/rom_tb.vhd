library ieee;
use ieee.std_logic_1164.all;

entity tb_rom is
end entity tb_rom;

architecture testbench of tb_rom is
    component memoriaInstrucoes is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string := "memInstr_conteudo.dat"
        );
        port (
            addr : in bit_vector (addressSize - 1 downto 0);
            data : out bit_vector (dataSize - 1 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal input : bit_vector(5 downto 0);
    signal output : bit_vector(7 downto 0);

begin
    UUT: memoriaInstrucoes 
        generic map (
            addressSize => 6,
            dataSize => 8,
            datFileName => "memInstr_conteudo.dat"
        )
        port map (
            addr => input,
            data => output
        );
    processo_estimulo : process
    begin
        input <= (others => '0');
        wait for CLK_PERIOD;

        report "Iniciando bateria de testes";

        --teste 1: entrada zerada
        input <= (others => '0');
        wait for CLK_PERIOD;

        assert output = "11111000" report "Teste de leitura da posição 0 falhou" severity error;

        --teste 2: entrada máxima
        input <= (others => '1');
        wait for CLK_PERIOD;

        assert output = "00000000" report "Teste de leitura da posição 63 falhou" severity error;

        --teste 3: entrada intermediária
        input <= "000111";
        wait for CLK_PERIOD;

        assert output = "11100010" report "Teste de leitura da posição 7 falhou" severity error;
        
        report "Fim dos testes";
        wait;
    end process;
end architecture;
