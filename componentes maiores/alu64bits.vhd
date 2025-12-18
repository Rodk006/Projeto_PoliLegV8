--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.numeric_bit.all; 

entity ula is
	port (
		A  : in  bit_vector(63 downto 0); 	-- entrada A
		B  : in  bit_vector(63 downto 0); 	-- entrada B
		S  : in  bit_vector( 3 downto 0); 	-- seleciona operacao
		F  : out bit_vector(63 downto 0); 	-- saida
		Z  : out bit;  							-- flag zero (1 se F = 0)
		Ov : out bit;  							-- flag overflow (do MSB)
		Co : out bit   							-- carry out (do MSB)
	);
end entity ula;

architecture structural of ula is
	component ula1bit
		port (
			a        : in  bit;
			b        : in  bit;
			cin      : in  bit;
			ainvert  : in  bit;
			binvert  : in  bit;
			operation: in  bit_vector(1 downto 0);
			result   : out bit;
			cout     : out bit;
			overflow : out bit
		);
	end component;

	-- vetor dos carry da ula1bit(i), portanto carry(0) eh o carry inicial (1 se B invertido) e o carry(64) eh o carry final
	signal carry : bit_vector(64 downto 0);

	-- vetor de saidas overflow de cada ula1bit(i), na pratica imagino que o overflow seja "levado de ula pra ula" ent talvez seja possivel ter apenas 1 bit ao inves de um vetor
	signal ov_bits : bit_vector(63 downto 0);
	
	signal zeros : bit_vector(63 downto 0) := (others => '0');

	signal tempF : bit_vector(63 downto 0);

begin
	-- carry inicial
	carry(0) <= S(2);

	-- geracao das alu
	alu_gen: for i in 0 to 63 generate
		bit_inst: ula1bit
			port map (
				a         => A(i),
				b         => B(i),
				cin       => carry(i),
				ainvert   => S(3),
				binvert   => S(2),
				operation => S(1 downto 0),
				result    => tempF(i),
				cout      => carry(i+1),
				overflow  => ov_bits(i)
			);
	end generate alu_gen;
	
	-- carry(i)   -> entrada 
	-- carry(i+1) -> saida
	-- logo a saida de um eh conectado a entrada do outro 
	
	-- carry out ultimo carry do vetor de carry
	Co <= carry(64);

	Ov <= carry(63) xor carry(64);

	Z <= '1' when tempF = zeros else '0';

	F <= tempF;

end architecture structural;
