library ieee;
use ieee.numeric_bit.all;

entity tb_fluxoDados is
end tb_fluxoDados;

architecture tb of tb_fluxoDados is

    -- Componente a ser testado
    component fluxoDados is
        port(
            clock : in bit; -- entrada de clock
            reset : in bit; -- clear assincrono
            extendMSB : in bit_vector (4 downto 0); -- sinal de controle sign-extend
            extendLSB : in bit_vector (4 downto 0); -- sinal de controle sign-extend
            reg2Loc : in bit; -- sinal de controle MUX Read Register 2
            regWrite : in bit; -- sinal de controle Write Register
            aluSrc : in bit; -- sinal de controle MUX entrada B ULA
            alu_control : in bit_vector (3 downto 0); -- sinal de controle da ULA
            branch : in bit; -- sinal de controle desvio condicional
            uncondBranch : in bit; -- sinal de controle desvio incondicional
            memRead : in bit; -- sinal de controle leitura RAM dados
            memWrite : in bit; -- sinal de controle escrita RAM dados
            memToReg : in bit; -- sinal de controle MUX Write Data
            opcode : out bit_vector (10 downto 0) -- sinal de condição código da instrução
        );
    end component;

    -- Sinais de estímulo
    signal clk, reset, simulando, reg2Loc, regWrite, aluSrc, branch, uncondBranch, memRead, memWrite, memToReg : bit := '0';
    signal extendMSB, extendLSB : bit_vector(4 downto 0) := "00000";
    signal alu_control : bit_vector(3 downto 0) := "0000";

    -- Sinais monitorados
    signal opcode : bit_vector(10 downto 0);

    constant CLK_PERIOD : time := 10 us;

begin

    -- Instanciação da ULA
    DUT: fluxoDados port map (clk, reset, extendMSB, extendLSB, reg2Loc, regWrite, aluSrc, alu_control, branch, uncondBranch, memRead, memWrite, memToReg, opcode);

    clk <= (simulando AND (NOT clk)) after CLK_PERIOD/2;

    -- Processo de testes
    estimulos : process is
        type pattern_type is record
            --entradas
            In_extendMSB, In_extendLSB : bit_vector(4 downto 0);
            In_reg2Loc, In_regWrite, In_aluSrc, In_branch, In_uncondBranch, In_memRead, In_memWrite, In_memToReg : bit;
            In_aluc_control : bit_vector(3 downto 0);
            --saidas
            Out_opcode : bit_vector(10 downto 0);
        end record;
        
        type pattern_array is array (natural range <>) of pattern_type;

        constant patterns : pattern_array := --rw    rr1      rr2       wr            d              q1                q2
                                            (("10100", "01100", '0', '1', '1', '0', '0', '1', '0', '1', "0111", "11111000010"), -- LDUR
                                             ("10100", "01100", '0', '1', '1', '0', '0', '1', '0', '1', "0111", "11111000010"), -- LDUR
                                             ("10100", "01100", '0', '1', '1', '0', '0', '1', '0', '1', "0111", "11111000010"), -- LDUR
                                             ("10100", "01100", '0', '1', '1', '0', '0', '1', '0', '1', "0111", "11111000010"), -- LDUR
                                             ("00000", "00000", '0', '1', '0', '0', '0', '0', '0', '0', "0010", "10001011000"), -- ADD
                                             ("00000", "00000", '0', '1', '0', '0', '0', '0', '0', '0', "0110", "11001011000"), -- SUB
                                             ("00000", "00000", '0', '1', '0', '0', '0', '0', '0', '0', "0110", "11001011000"), -- SUB
                                             ("00000", "00000", '0', '1', '0', '0', '0', '0', '0', '0', "0001", "10101010000"), -- ORR
                                             ("00000", "00000", '0', '1', '0', '0', '0', '0', '0', '0', "0000", "10001010000"), -- AND
                                             ("00000", "00000", '0', '1', '0', '0', '0', '0', '0', '0', "0001", "10101010000"), -- ORR
                                             ("10111", "00101", '1', '0', '0', '1', '0', '0', '0', '0', "0011", "10110100000"), -- CBZ
                                             ("10100", "01100", '1', '0', '1', '0', '0', '0', '1', '0', "0010", "11111000000"), -- STUR
                                             ("10100", "01100", '1', '0', '1', '0', '0', '0', '1', '0', "0010", "11111000000"), -- STUR
                                             ("10100", "01100", '1', '0', '1', '0', '0', '0', '1', '0', "0010", "11111000000"), -- STUR
                                             ("10100", "01100", '1', '0', '1', '0', '0', '0', '1', '0', "0010", "11111000000"), -- STUR
                                             ("10100", "01100", '1', '0', '1', '0', '0', '0', '1', '0', "0010", "11111000000"), -- STUR
                                             ("10100", "01100", '0', '0', '0', '0', '1', '0', '0', '0', "0000", "00010100000")); -- B

    begin

        assert false report "Inicio Teste" severity note;
        
        reset <= '1';
        wait for 2*CLK_PERIOD;
        reset <='0';

        simulando <= '1';
 
        for i in patterns'range loop  --'
            extendMSB <= patterns(i).In_extendMSB;
            extendLSB <= patterns(i).In_extendLSB;
            reg2Loc <= patterns(i).In_reg2Loc;
            regWrite <= patterns(i).In_regWrite;
            aluSrc <= patterns(i).In_aluSrc;
            branch <= patterns(i).In_branch;
            uncondBranch <= patterns(i).In_uncondBranch;
            memRead <= patterns(i).In_memRead;
            memWrite <= patterns(i).In_memWrite;
            memToReg <= patterns(i).In_memToReg;
            alu_control <= patterns(i).In_aluc_control;

            wait until rising_edge(clk);

            assert opcode = patterns(i).Out_opcode report "ERRO OPCODE TESTE " & integer'image(i);

    end loop;

    simulando <= '0';
    assert false report "Teste Concluido" severity note;
    wait;        

end process;

end tb;
