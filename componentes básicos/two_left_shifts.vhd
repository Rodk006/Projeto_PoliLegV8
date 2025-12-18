--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

entity two_left_shifts is
    generic(
        dataSize : natural := 64
    );
    port(
        input: in bit_vector(dataSize-1 downto 0);
        output: out bit_vector(dataSize-1 downto 0)
    );
end entity two_left_shifts;

architecture rtl of two_left_shifts is
begin
    output <= bit_vector(input(dataSize-3 downto 0)) & "00";
end architecture;
