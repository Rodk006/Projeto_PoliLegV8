--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.numeric_bit.all;

entity tb_ula64 is
end entity tb_ula64;

architecture testbench of tb_ula64 is

    component ula is
        port (
            A  : in  bit_vector(63 downto 0);
            B  : in  bit_vector(63 downto 0);
            S  : in  bit_vector(3 downto 0);
            F  : out bit_vector(63 downto 0);
            Z  : out bit;
            Ov : out bit;
            Co : out bit
        );
    end component;

    signal A, B : bit_vector(63 downto 0);
    signal S    : bit_vector(3 downto 0);

    signal F    : bit_vector(63 downto 0);
    signal Z, Ov, Co : bit;

    signal any_error : bit;

    type test_vector is record
        A, B     : bit_vector(63 downto 0);
        S        : bit_vector(3 downto 0);
        F_exp    : bit_vector(63 downto 0);
        Z_exp    : bit;
        Ov_exp   : bit;
        Co_exp   : bit;
    end record;

    type test_array is array (natural range <>) of test_vector;

    constant testes : test_array := (

        -- AND
        (X"0000000000000001", X"0000000000000001", "0000",
         X"0000000000000001", '0', '0', '0'),

        -- OR
        (X"0000000000000000", X"FFFFFFFFFFFFFFFF", "0001",
         X"FFFFFFFFFFFFFFFF", '0', '0', '0'),

        -- ADD simples
        (X"0000000000000001", X"0000000000000001", "0010",
         X"0000000000000002", '0', '0', '0'),

        -- ADD com carry
        (X"FFFFFFFFFFFFFFFF", X"0000000000000001", "0010",
         X"0000000000000000", '1', '0', '1'),

        -- SUB simples (5 - 3 = 2)
        (X"0000000000000005", X"0000000000000003", "0110",
         X"0000000000000002", '0', '0', '1'),

        -- SUB zerando
        (X"0000000000000004", X"0000000000000004", "0110",
         X"0000000000000000", '1', '0', '1'),

        -- Overflow positivo
        (X"7FFFFFFFFFFFFFFF", X"0000000000000001", "0010",
         X"8000000000000000", '0', '1', '0'),

        -- Overflow negativo
        (X"8000000000000000", X"FFFFFFFFFFFFFFFF", "0010",
         X"7FFFFFFFFFFFFFFF", '0', '1', '1'),

        -- Pass B
        (X"AAAAAAAAAAAAAAAA", X"5555555555555555", "0011",
         X"5555555555555555", '0', '0', '0')
    );

begin

    UUT : ula port map (
        A  => A,
        B  => B,
        S  => S,
        F  => F,
        Z  => Z,
        Ov => Ov,
        Co => Co
    );
    
    processo_estimulo : process
    begin
        report "Iniciando testes da ULA de 64 bits...";
        any_error <= '0';

        for i in testes'range loop
            A <= testes(i).A;
            B <= testes(i).B;
            S <= testes(i).S;

            wait for 10 ns;

            if F /= testes(i).F_exp then
                any_error <= '1';
                report "Falha no teste " & integer'image(i) &
                       ": F incorreto"
                       severity error;
            end if;

            if Z /= testes(i).Z_exp then
                any_error <= '1';
                report "Falha no teste " & integer'image(i) &
                       ": Z incorreto"
                       severity error;
            end if;

            if Ov /= testes(i).Ov_exp then
                any_error <= '1';
                report "Falha no teste " & integer'image(i) &
                       ": Overflow incorreto"
                       severity error;
            end if;

            if Co /= testes(i).Co_exp then
                any_error <= '1';
                report "Falha no teste " & integer'image(i) &
                       ": Carry-out incorreto"
                       severity error;
            end if;
        end loop;

        if any_error = '0' then
            report "Todos os testes da ULA de 64 bits passaram!";
        end if;

        report "Simulação concluída!";
        wait;
    end process;

end architecture testbench;
