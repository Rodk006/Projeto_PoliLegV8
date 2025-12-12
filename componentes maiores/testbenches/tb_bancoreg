library ieee;
use ieee.numeric_bit.all;

entity tb_bancoreg is
end tb_bancoreg;

architecture tb of tb_bancoreg is

    -- Componente a ser testado
    component regfile is
    port (
            clock    : in  bit; 							-- entrada de clock
            reset    : in  bit; 							-- entrada de reset
            regWrite : in  bit; 							-- entrada de carga do registrador wr
            rr1      : in  bit_vector(4 downto 0);	-- entrada define registrador r1
            rr2      : in  bit_vector(4 downto 0);	-- entrada define registrador r2
            wr       : in  bit_vector(4 downto 0);	-- entrada define registrador de escrita
            d        : in  bit_vector(63 downto 0);	-- entrada de dado para carga paralela
            q1       : out bit_vector(63 downto 0); -- saida do registrador 1
            q2       : out bit_vector(63 downto 0)	-- saida do registrador 2
        );
    end component;

    -- Sinais de estímulo
    signal clk, reset, regWrite, simulando : bit := '0';
    signal rr1, rr2, wr : bit_vector(4 downto 0) := "00000";
    signal d : bit_vector(63 downto 0) := (others => '0');

    -- Sinais monitorados
    signal q1, q2 : bit_vector(63 downto 0);

    constant CLK_PERIOD : time := 10 us;

begin

    -- Instanciação da ULA
    DUT: regfile port map (clk, reset, regWrite, rr1, rr2, wr, d, q1, q2);

    clk <= (simulando AND (NOT clk)) after CLK_PERIOD/2;

    -- Processo de testes
    estimulos : process is
        type pattern_type is record
            --entradas
            In_regWrite : bit;
            In_rr1, In_rr2, In_wr : bit_vector(4 downto 0);
            In_d : bit_vector(63 downto 0);
            --saidas
            Out_q1, Out_q2 : bit_vector(63 downto 0);
        end record;
        
        type pattern_array is array (natural range <>) of pattern_type;

        constant patterns : pattern_array := --rw    rr1      rr2       wr            d              q1                q2
                                            (('0', "00000", "00000", "00000", (others => '0'), (others => '0'),(others => '0')), -- apos reset
                                             ('0', "10000", "11111", "10000", (others => '1'), (others => '0'), (others => '0')), -- ver se escreve com rw desligado, leitura X16 e X31 (XZR)
                                             ('1', "00100", "11110", "11110", (63 => '1', others => '0'), (others => '0'), (63 => '1', others => '0')), --X30 <= "10000....0", leitura X30 e X4
                                             ('1', "11110", "00000", "00000", (others => '1'), (63 => '1', others => '0'),(others => '1')), -- X0 <= "1111...1", leitura X0 e X30
                                             ('1', "00000", "11111", "11111", (others => '1'), (others => '1'),(others => '0'))) ;  -- tentativa de escrever "1111...1" em X31, leitura X0 e X31
    begin

        assert false report "Inicio Teste" severity note;
        simulando <= '1';

        reset <= '1';
        wait for 2*CLK_PERIOD;
        reset <='0';

        for i in patterns'range loop 
            regWrite <= patterns(i).In_regWrite;
            rr1 <= patterns(i).In_rr1;
            rr2 <= patterns(i).In_rr2;
            wr <= patterns(i).In_wr;
            d <= patterns(i).In_d;

            wait for 2*CLK_PERIOD;

            assert q1 = patterns(i).Out_q1 report "ERRO Q1 TESTE " & integer'image(i);
            assert q2 = patterns(i).Out_q2 report "ERRO Q2 TESTE " & integer'image(i);

    end loop;

    simulando <= '0';
    assert false report "Teste Concluido" severity note;
    wait;        

end process;

end tb;
