--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;

entity tb_polilegv8 is 
end entity tb_polilegv8;

architecture test of tb_polilegv8 is
    component polilegv8
        port(
            clock : in bit;
            reset : in bit
        );
    end component;

    signal s_clock : bit := '0';
    signal s_reset : bit := '0';

    constant CLK_PERIOD : time := 10 us;

    signal keep_simulating : bit := '1';    

begin 
    s_clock <= not(s_clock) and keep_simulating after CLK_PERIOD/2;

    CPU: polilegv8
        port map(s_clock, s_reset);

end test;
