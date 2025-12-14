library ieee;
use std.textio.all;	
use ieee.numeric_bit.all;

entity memoriaDados is
	generic (
		addressSize : natural := 8;
		dataSize    : natural := 8;
		datFileName : string  := "memDados_conteudo_inicial.dat"
	);
	port (
		clock 	: in  bit;
		wr 		: in  bit;
		addr 	: in  bit_vector (addressSize - 1 downto 0);
		data_i 	: in  bit_vector (dataSize - 1 downto 0);
		data_o 	: out bit_vector (dataSize - 1 downto 0);
        mem0_db : out bit_vector(63 downto 0);
        mem8_db : out bit_vector(63 downto 0); 
        mem16_db : out bit_vector(63 downto 0); 
        mem24_db : out bit_vector(63 downto 0); 
        mem32_db : out bit_vector(63 downto 0); 
        mem40_db : out bit_vector(63 downto 0); 
        mem48_db : out bit_vector(63 downto 0); 
        mem56_db : out bit_vector(63 downto 0); 
        mem64_db : out bit_vector(63 downto 0) 
	);
end entity memoriaDados;

architecture rtl of memoriaDados is
-- tipo memória
type mem_type is array (0 to (2**addressSize) - 1) of bit_vector (dataSize - 1 downto 0); -- 2^n - 1 posicoes de memoria, com k bits de largura

-- funcao de iniciar a memoria
impure function init_mem(arquiveName : in string) return mem_type is 
	file 		arquivo 	: text open read_mode is arquiveName;
	variable linha 	: line;
	variable temp_bv  : bit_vector(dataSize - 1 downto 0);
	variable temp_mem : mem_type;
	begin
		for i in mem_type'range loop
			readline(arquivo, linha);
			read(linha, temp_bv);
			temp_mem(i) := temp_bv;
		end loop;
		return temp_mem;
	end function;

-- funcao de conversão bit_vector para integer
function bits_to_integer(bv : bit_vector) return integer is
    variable result : integer := 0;
	variable idx    : integer := 0;
	begin
		for i in bv'reverse_range loop
			if bv(i) = '1' then
				result := result + (2**idx);
			end if;
			idx := idx + 1;
		end loop;
	return result;
end function;

-- inicializa a memoria
signal memoriaD : mem_type := init_mem(datFileName);

begin
	mem0_db  <= memoriaD(0)  & memoriaD(1)  & memoriaD(2)  & memoriaD(3)  &
			memoriaD(4)  & memoriaD(5)  & memoriaD(6)  & memoriaD(7);

	mem8_db  <= memoriaD(8)  & memoriaD(9)  & memoriaD(10) & memoriaD(11) &
			memoriaD(12) & memoriaD(13) & memoriaD(14) & memoriaD(15);

	mem16_db <= memoriaD(16) & memoriaD(17) & memoriaD(18) & memoriaD(19) &
			memoriaD(20) & memoriaD(21) & memoriaD(22) & memoriaD(23);

	mem24_db <= memoriaD(24) & memoriaD(25) & memoriaD(26) & memoriaD(27) &
			memoriaD(28) & memoriaD(29) & memoriaD(30) & memoriaD(31);

	mem32_db <= memoriaD(32) & memoriaD(33) & memoriaD(34) & memoriaD(35) &
			memoriaD(36) & memoriaD(37) & memoriaD(38) & memoriaD(39);

	mem40_db <= memoriaD(40) & memoriaD(41) & memoriaD(42) & memoriaD(43) &
			memoriaD(44) & memoriaD(45) & memoriaD(46) & memoriaD(47);

	mem48_db <= memoriaD(48) & memoriaD(49) & memoriaD(50) & memoriaD(51) &
			memoriaD(52) & memoriaD(53) & memoriaD(54) & memoriaD(55);

	mem56_db <= memoriaD(56) & memoriaD(57) & memoriaD(58) & memoriaD(59) &
			memoriaD(60) & memoriaD(61) & memoriaD(62) & memoriaD(63);

	mem64_db <= memoriaD(64) & memoriaD(65) & memoriaD(66) & memoriaD(67) &
			memoriaD(68) & memoriaD(69) & memoriaD(70) & memoriaD(71);


	process(clock)
	begin 
		if clock'event and clock='1' then 
			if wr = '1' then memoriaD(bits_to_integer(addr)) <= data_i;
			end if;
		end if;
	end process;

	data_o <= memoriaD(bits_to_integer(addr)); -- leitura da memoria 
	--(nao sei se precisa de um condicional semelhante a um: if (wr == 0) data_o bla bla bla
	-- pq em tese a unica saida eh causada pela data_o logo ela sempre estar ligada ao barramento de dados nao tem problema
	
end architecture rtl;
