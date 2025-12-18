--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.std_logic_1164.all;

entity tb_two_left_shifts is
end entity tb_two_left_shifts;

architecture testbench of tb_two_left_shifts is
    component two_left_shifts is
        generic(
        dataSize : natural := 64
    );
    port(
        input: in bit_vector(dataSize-1 downto 0);
        output: out bit_vector(dataSize-1 downto 0)
    );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal input_16 : bit_vector(15 downto 0);
    signal output_16 : bit_vector(15 downto 0);

    signal input_32 : bit_vector(31 downto 0);
    signal output_32 : bit_vector(31 downto 0);

    signal input_64 : bit_vector(63 downto 0);
    signal output_64 : bit_vector(63 downto 0);

begin
    UUT_16: two_left_shifts
        generic map(dataSize => 16)
        port map(
            input => input_16,
            output => output_16
        );

    UUT_32: two_left_shifts
        generic map (dataSize => 32)
        port map(
            input => input_32,
            output => output_32
        );

    UUT_64: two_left_shifts
        generic map (dataSize => 64)
        port map(
            input => input_64,
            output => output_64
        );

    processo_estimulo : process
    begin
        input_16   <= (others => '0');
        input_32   <= (others => '0');
        input_64   <= (others => '0');
        wait for CLK_PERIOD;

        report "Iniciando bateria de testes";

        --teste 1: entrada máxima
        input_16    <= (others => '1');
        input_32    <= (others => '1');
        input_64    <= (others => '1');
        wait for CLK_PERIOD;

        assert output_16 = X"FFFC" report "Teste de shift 16 bits com entrada máxima falhou" severity error;
        assert output_32 = X"FFFFFFFC" report "Teste de shift 32 bits com entrada máxima falhou" severity error;
        assert output_64 = X"FFFFFFFFFFFFFFFC" report "Teste de shift 64 bits com entrada máxima falhou" severity error;

        --teste 2: entrada zerada
        input_16    <= (others => '0');
        input_32    <= (others => '0');
        input_64    <= (others => '0');
        wait for CLK_PERIOD;

        assert output_16 = X"0000" report "Teste de shift 16 bits com entrada zerada falhou" severity error;
        assert output_32 = X"00000000" report "Teste de shift 32 bits com entrada zerada falhou" severity error;
        assert output_64 = X"0000000000000000" report "Teste de shift 64 bits com entrada zerada falhou" severity error;

        --teste 3: entrada intermediária
        input_16    <= X"1FFC";
        input_32    <= X"1FFFFFFC";
        input_64    <= X"1FFFFFFFFFFFFFFC";
        wait for CLK_PERIOD;

        assert output_16 = X"7FF0" report "Teste de shift 16 bits com entrada intermediária falhou" severity error;
        assert output_32 = X"7FFFFFF0" report "Teste de shift 32 bits com entrada intermediária falhou" severity error;
        assert output_64 = X"7FFFFFFFFFFFFFF0" report "Teste de shift 64 bits com entrada intermediária falhou" severity error;

        report "Fim dos testes";
        wait;
    end process;
end architecture;
