library ieee;

entity adder_n is
	generic (dataSize : natural := 64);
	port (
		in0  : in bit_vector(dataSize - 1 downto 0);  -- primeira parcela
		in1  : in bit_vector(dataSize - 1 downto 0);  -- segunda parcela
		sum  : out bit_vector(dataSize - 1 downto 0); -- soma 
		Cout : out bit										   -- carry
	);
end entity adder_n;

architecture rtl of adder_n is
	component fulladder
		port (
			a, b, cin: in bit;
			s, cout: out bit
		);
	end component;

	signal carry : bit_vector(dataSize downto 0);
begin
	carry(0) <= '0';

	-- geracao dos somadores 1 bit
	fulladder_gen: for i in 0 to dataSize-1 generate
		adders: fulladder
			port map (
				a => in0(i),
				b => in1(i),
				cin => carry(i),
				s => sum(i),
				cout => carry(i+1)
			);
	end generate fulladder_gen;

	Cout <= carry(dataSize);
end architecture;