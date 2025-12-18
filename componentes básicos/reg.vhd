--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.numeric_bit.all;

entity reg is
    generic (dataSize : natural := 64);
    port (
        clock  : in  bit;  										-- entrada de clock
        reset  : in  bit;  										-- clear assíncrono (ativo em '1')
        enable : in  bit;  										-- write enable (carga paralela)
        d      : in  bit_vector(dataSize - 1 downto 0);	-- entrada
        q      : out bit_vector(dataSize - 1 downto 0)  	-- saída
    );
end entity reg;

architecture rtl of reg is
    signal reg_q : bit_vector(dataSize - 1 downto 0) := (others => '0');
begin
    process(clock, reset)
    begin
        if reset = '1' then reg_q <= (others => '0'); 
        elsif clock'event and clock = '1' then
            if enable = '1' then -- habilita a escrita
                reg_q <= d; -- escreve no registrador
            end if;
        end if;
    end process;

    q <= reg_q; -- saída recebe a "saida temporária"

end architecture rtl;
