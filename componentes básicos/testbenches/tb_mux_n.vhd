--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.numeric_bit.all;

entity tb_mux_n is
end entity tb_mux_n;

architecture testbench of tb_mux_n is

    component mux_n is
        generic (dataSize : natural := 64);
        port (
            in0   : in  bit_vector(dataSize-1 downto 0);
            in1   : in  bit_vector(dataSize-1 downto 0);
            sel   : in  bit;
            dOut  : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    -- parâmetro de tempo (não há clock no MUX, mas mantemos estilo)
    constant STEP : time := 10 ns;

    signal simulando : bit := '1';

    signal sel_tb : bit;

    signal in0_16, in1_16, dout_16 : bit_vector(15 downto 0);
    signal in0_32, in1_32, dout_32 : bit_vector(31 downto 0);
    signal in0_64, in1_64, dout_64 : bit_vector(63 downto 0);

begin

    UUT_16 : mux_n
        generic map (dataSize => 16)
        port map (
            in0  => in0_16,
            in1  => in1_16,
            sel  => sel_tb,
            dOut => dout_16
        );

    UUT_32 : mux_n
        generic map (dataSize => 32)
        port map (
            in0  => in0_32,
            in1  => in1_32,
            sel  => sel_tb,
            dOut => dout_32
        );

    UUT_64 : mux_n
        generic map (dataSize => 64)
        port map (
            in0  => in0_64,
            in1  => in1_64,
            sel  => sel_tb,
            dOut => dout_64
        );

    ---------------------------------------------------------------------
    -- Processo de estímulo
    ---------------------------------------------------------------------
    stim_proc : process
    begin
        -- inicialização
        sel_tb <= '0';
        in0_16 <= (others => '0'); in1_16 <= (others => '0');
        in0_32 <= (others => '0'); in1_32 <= (others => '0');
        in0_64 <= (others => '0'); in1_64 <= (others => '0');
        wait for STEP;

        report "Iniciando bateria de testes do multiplexador";

        sel_tb <= '0';
        in0_16 <= (others => '1');  in1_16 <= (others => '0');
        in0_32 <= (others => '1');  in1_32 <= (others => '0');
        in0_64 <= (others => '1');  in1_64 <= (others => '0');
        wait for STEP;

        assert dout_16 = X"FFFF" report "Erro MUX16: sel=0 não selecionou in0!" severity error;
        assert dout_32 = X"FFFFFFFF" report "Erro MUX32: sel=0 não selecionou in0!" severity error;
        assert dout_64 = X"FFFFFFFFFFFFFFFF" report "Erro MUX64: sel=0 não selecionou in0!" severity error;


        sel_tb <= '1';
        in0_16 <= (others => '0');  in1_16 <= (others => '1');
        in0_32 <= (others => '0');  in1_32 <= (others => '1');
        in0_64 <= (others => '0');  in1_64 <= (others => '1');
        wait for STEP;

        assert dout_16 = X"FFFF" report "Erro MUX16: sel=1 não selecionou in1!" severity error;
        assert dout_32 = X"FFFFFFFF" report "Erro MUX32: sel=1 não selecionou in1!" severity error;
        assert dout_64 = X"FFFFFFFFFFFFFFFF" report "Erro MUX64: sel=1 não selecionou in1!" severity error;

        -----------------------------------------------------------------
        -- Teste 3: Padrões alternados
        -----------------------------------------------------------------

        in0_16 <= X"AAAA"; in1_16 <= X"5555";
        in0_32 <= X"AAAAAAAA"; in1_32 <= X"55555555";
        in0_64 <= X"AAAAAAAAAAAAAAAA"; in1_64 <= X"5555555555555555";

        -- Seleciona in0
        sel_tb <= '0';
        wait for STEP;

        assert dout_16 = X"AAAA" report "Erro MUX16: padrão alternado com sel=0" severity error;
        assert dout_32 = X"AAAAAAAA" report "Erro MUX32: padrão alternado com sel=0" severity error;
        assert dout_64 = X"AAAAAAAAAAAAAAAA" report "Erro MUX64: padrão alternado com sel=0" severity error;

        -- Seleciona in1
        sel_tb <= '1';
        wait for STEP;

        assert dout_16 = X"5555" report "Erro MUX16: padrão alternado com sel=1" severity error;
        assert dout_32 = X"55555555" report "Erro MUX32: padrão alternado com sel=1" severity error;
        assert dout_64 = X"5555555555555555" report "Erro MUX64: padrão alternado com sel=1" severity error;

        -----------------------------------------------------------------
        -- Fim da simulação
        -----------------------------------------------------------------

        report "Testes finalizados!";
        simulando <= '0';
        report "Simulação finalizada" severity note;
        wait;

    end process;

end architecture testbench;
