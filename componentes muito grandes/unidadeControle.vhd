library ieee;

entity unidadeControle is
    port(
        opcode : in bit_vector (10 downto 0); -- sinal de condição código da instrução
        extendMSB : out bit_vector (4 downto 0); -- sinal de controle sign-extend
        extendLSB : out bit_vector (4 downto 0); -- sinal de controle sign-extend
        reg2Loc : out bit; -- sinal de controle MUX Read Register 2
        regWrite : out bit; -- sinal de controle Write Register
        aluSrc : out bit; -- sinal de controle MUX entrada B ULA
        alu_control : out bit_vector (3 downto 0); -- sinal de controle da ULA
        branch : out bit; -- sinal de controle desvio condicional
        uncondBranch : out bit; -- sinal de controle desvio incondicional
        memRead : out bit; -- sinal de controle leitura RAM dados
        memWrite : out bit; -- sinal de controle escrita RAM dados
        memToReg : out bit -- sinal de controle MUX Write Data
    );
end entity unidadeControle;

architecture arch of unidadeControle is
    signal vetor_controle : bit_vector(21 downto 0);

begin
    -- optou-se, arbitrariamente, por zerar os don't cares
    vetor_controle <= "0000000100001100100000" when opcode(10 downto 5) = "000101" else -- B
                "1000001000111011100101" when opcode(10 downto 3) = "10110100" else -- CBZ
                "1100010000101010001100" when opcode = "11111000000" else --STUR
                "0111100000101010001100" when opcode = "11111000010" else --LDUR
                "0001000000010000000000" when opcode = "10101010000" else -- ORR
                "0001000000000000000000" when opcode = "10001010000" else -- AND
                "0001000001100000000000" when opcode = "11001011000" else -- SUB
                "0001000000100000000000" when opcode = "10001011000" else -- ADD
                "0000000000000000000000"; -- zera por default 

    reg2Loc <= vetor_controle(21);
    aluSrc <= vetor_controle(20);
    memToReg <= vetor_controle(19);
    regWrite <= vetor_controle(18);
    memRead <= vetor_controle(17);
    memWrite <= vetor_controle(16);
    branch <= vetor_controle(15);
    uncondBranch <= vetor_controle(14);
    alu_control <= vetor_controle(13 downto 10);
    extendMSB <= vetor_controle(9 downto 5);
    extendLSB <= vetor_controle(4 downto 0);

end arch;
