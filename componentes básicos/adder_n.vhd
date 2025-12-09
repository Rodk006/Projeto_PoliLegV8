library ieee;

entity adder_n is
	generic (dataSize : natural := 64);
	port (
		in0  : in bit_vector(dataSize - 1 downto 0)  -- primeira parcela
		in1  : in bit_vector(dataSize - 1 downto 0)  -- segunda parcela
		sum  : out bit_vector(dataSize - 1 downto 0) -- soma 
		Cout : out bit										   -- carry
	);
end entity adder_n;

architecture of adder_n is
signal in0_extended : unsigned(dataSize downto 0) := unsigned('0' & in0) -- dado de entrada com uma 1 bit a mais para que receba o carry da soma
signal in1_extended : unsigned(dataSize downto 0) := unsigned('0' & in1) -- dado de entrada com uma 1 bit a mais para que receba o carry da soma
signal sum_temp 	  : unsigned(dataSize downto 0)
begin
	sum_temp <= in0_extended + in1_extended
	sum 		<= bit_vector(sum_temp(dataSize - 1 downto 0))
	Cout 		<= bit_vector(sum_temp(dataSize))
end architecture;