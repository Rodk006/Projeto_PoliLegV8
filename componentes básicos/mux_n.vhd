--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.numeric_bit.all;

entity mux_n is
    generic (dataSize : natural := 64);
    port (
        in0   : in  bit_vector(dataSize-1 downto 0);	-- entrada de dados 0
        in1   : in  bit_vector(dataSize-1 downto 0);	-- entrada de dados 1
        sel   : in  bit;  										-- sinal de seleção
        dOut  : out bit_vector(dataSize-1 downto 0)	-- sinal de dados
    );
end entity mux_n;

architecture rtl of mux_n is
begin
    dOut <= in0 when sel = '0' else in1;

end architecture rtl;
