--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

entity ula1bit is
    port (
        a : in bit ;
        b : in bit ;
        cin : in bit ;
        ainvert : in bit ;
        binvert : in bit ;
        operation : in bit_vector (1 downto 0 ) ;
        result : out bit ;
        cout : out bit ;
        overflow : out bit
    ) ;
end ula1bit;

architecture arch of ula1bit is

    component fulladder is 
    port (A,B,Cin : in bit; S,Cout : out bit);
    end component;

    signal INa,INb, soma, carry, carryout : bit;  

    begin

        INa <= (a) when (ainvert = '0') else
               (not a); 

        INb <= (b) when (binvert = '0') else
               (not b); 

        Sum : fulladder port map (INa, INb, cin, soma, carry);

        with operation select
            result <= (INa and INb) when "00",
                      (INa or INb)  when "01",
                      (soma)        when "10",
                      (b)         when "11";
        
        cout <= carry when (operation = "10") else
                '0';
		
        overflow <= cin xor carry;

end arch;
