library ieee;
use std.textio.all

entity memoriaInstrucoes is
	generic (
		addressSize : natural := 8;
		dataSize    : natural := 8;
		datFileName : string := "memInstr_conteudo.dat"
	);
	port (
		addr : in bit_vector (addressSize - 1 downto 0);
		data : out bit_vector (dataSize - 1 downto 0)
	);
end entity memoriaInstrucoes

architecture of memoriaInstrucoes is 
-- tipo memória
type mem_type is array (0 to (2**addresSize) - 1) of bit_vector (dataSize - 1 downto 0); -- 2^n - 1 posicoes de memoria, com k bits de largura

-- funcao de iniciar a memoria
function init_mem(arquiveName : "memInstr_conteudo.dat") return mem_type is 
	file 		arquivo 	: text open read_mode is arquiveName;
	variable linha 	: line;
	variable temp_bv  : bit_vector(3 downto 0);
	variable temp_mem : mem_type;
	begin
		for i in mem_type'range loop
			readline(arquivo, linha);
			read(linha, temp_bv);
			temp_mem(i) := temp_bv;
		end loop;
		return temp_mem;
	end;
	
signal mem : mem_type := init_mem(datFileName); -- inicializo a memora
begin
	data <= mem(to_integer(usnigned(addr)));
end architecture;