library ieee;
use ieee.std_logic_1164.all;

entity tb_adder_n is
end entity tb_adder_n;

architecture testbench of tb_adder_n is
    component adder_n is
    generic(
        dataSize : natural := 64
    );
    port(
        in0  : in bit_vector(dataSize - 1 downto 0); -- primeira parcela
		in1  : in bit_vector(dataSize - 1 downto 0);  -- segunda parcela
		sum  : out bit_vector(dataSize - 1 downto 0); -- soma 
		Cout : out bit
    );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal in0_16 : bit_vector(15 downto 0);
    signal in1_16 : bit_vector(15 downto 0);
    signal sum_16 : bit_vector(15 downto 0);
    signal cout_16 : bit;

    signal in0_32 : bit_vector(31 downto 0);
    signal in1_32 : bit_vector(31 downto 0);
    signal sum_32 : bit_vector(31 downto 0);
    signal cout_32 : bit;

    signal in0_64 : bit_vector(63 downto 0);
    signal in1_64 : bit_vector(63 downto 0);
    signal sum_64 : bit_vector(63 downto 0);
    signal cout_64 : bit;

begin
    UUT_16:adder_n
        generic map(dataSize => 16)
        port map(
            in0 => in0_16,
            in1 => in1_16,
            sum => sum_16,
            Cout => cout_16
        );

    UUT_32: adder_n
        generic map (dataSize => 32)
        port map(
            in0 => in0_32,
            in1 => in1_32,
            sum => sum_32,
            Cout => cout_32
        );

    UUT_64: adder_n
        generic map (dataSize => 64)
        port map(
            in0 => in0_64,
            in1 => in1_64,
            sum => sum_64,
            Cout => cout_64
        );

    processo_estimulo : process
    begin
        in0_16 <= (others => '0');
        in1_16 <= (others => '0');
        in0_32 <= (others => '0');
        in1_32 <= (others => '0');
        in0_64 <= (others => '0');
        in1_64 <= (others => '0');
        wait for CLK_PERIOD;

        report "Iniciando bateria de testes";

        --teste 1: entrada zerada
        in0_16 <= (others => '0');
        in1_16 <= (others => '0');
        in0_32 <= (others => '0');
        in1_32 <= (others => '0');
        in0_64 <= (others => '0');
        in1_64 <= (others => '0');
        wait for CLK_PERIOD;

        assert sum_16 = X"0000" report "sum 16 bits com entrada zerada falhou" severity error;
        assert cout_16 = '0' report "cout 16 bits com entrada zerada falhou" severity error;
        assert sum_32 = X"00000000" report "sum 32 bits com entrada zerada falhou" severity error;
        assert cout_32 = '0' report "cout 32 bits com entrada zerada falhou" severity error;
        assert sum_64 = X"0000000000000000" report "sum 64 bits com entrada zerada falhou" severity error;
        assert cout_64 = '0' report "cout 64 bits com entrada zerada falhou" severity error;
        
        --teste 2: entrada máxima
        in0_16 <= (others => '1');
        in1_16 <= (others => '1');
        in0_32 <= (others => '1');
        in1_32 <= (others => '1');
        in0_64 <= (others => '1');
        in1_64 <= (others => '1');
        wait for CLK_PERIOD;

        assert sum_16 = X"FFFE" report "sum 16 bits com entrada máxima falhou" severity error;
        assert cout_16 = '1' report "cout 16 bits com entrada máxima falhou" severity error;
        assert sum_32 = X"FFFFFFFE" report "sum 32 bits com entrada máxima falhou" severity error;
        assert cout_32 = '1' report "cout 32 bits com entrada máxima falhou" severity error;
        assert sum_64 = X"FFFFFFFFFFFFFFFE" report "sum 64 bits com entrada máxima falhou" severity error;
        assert cout_64 = '1' report "cout 64 bits com entrada máxima falhou" severity error;
        

        --teste 3: caso intermediário com cout = 0
        -- no caso, 15 + 15 = 30 
        in0_16 <= X"000F"; 
        in1_16 <= X"000F";
        in0_32 <= X"0000000F";
        in1_32 <= X"0000000F";
        in0_64 <= X"000000000000000F";
        in1_64 <= X"000000000000000F";
        wait for CLK_PERIOD;

        assert sum_16 = X"001E" report "sum 16 bits 15+15 falhou" severity error;
        assert cout_16 = '0' report "cout 16 bits 15+15 falhou" severity error;
        assert sum_32 = X"0000001E" report "sum 32 bits 15+15 falhou" severity error;
        assert cout_32 = '0' report "cout 32 bits 15+15 falhou" severity error;
        assert sum_64 = X"000000000000001E" report "sum 64 bits 15+15 falhou" severity error;
        assert cout_64 = '0' report "cout 64 bits 15+15 falhou" severity error;

        --teste 4: caso intermediário com cout = 1
        -- no caso, MAX + 1 = 0, cout=1 
        in0_16 <= (others => '1'); 
        in1_16 <= X"0001";
        in0_32 <= (others => '1');
        in1_32 <= X"00000001";
        in0_64 <= (others => '1');
        in1_64 <= X"0000000000000001";
        wait for CLK_PERIOD;

        assert sum_16 = X"0000" report "sum 16 bits MAX + 1 falhou" severity error;
        assert cout_16 = '1' report "cout 16 bits MAX + 1 falhou" severity error;
        assert sum_32 = X"00000000" report "sum 32 bits MAX + 1 falhou" severity error;
        assert cout_32 = '1' report "cout 32 bits MAX + 1 falhou" severity error;
        assert sum_64 = X"0000000000000000" report "sum 64 bits MAX + 1 falhou" severity error;
        assert cout_64 = '1' report "cout 64 bits MAX + 1 falhou" severity error;
        
        report "Fim dos testes";
        wait;
    end process;

end architecture;
        