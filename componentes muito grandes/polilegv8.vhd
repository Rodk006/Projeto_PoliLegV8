library ieee;

entity polilegv8 is 
    port(
        clock : in bit;
        reset : in bit
    );
end entity polilegv8;

architecture arch of polilegv8 is
    component fluxoDados
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

    component unidadeControle
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
    end component;

    -- sinais internos para realizar as conexões
    signal extendMSB : bit_vector (4 downto 0); 
    signal extendLSB : bit_vector (4 downto 0); 
    signal reg2Loc :  bit;
    signal regWrite : bit; 
    signal aluSrc : bit; 
    signal alu_control : bit_vector (3 downto 0);
    signal branch : bit;
    signal uncondBranch : bit; 
    signal memRead : bit; 
    signal memWrite : bit; 
    signal memToReg : bit;
    signal opcode : bit_vector (10 downto 0);

begin
    FD: fluxoDados port map(
        clock => clock,
        reset => reset,
        extendMSB => extendMSB,
        extendLSB => extendLSB,
        reg2Loc => reg2Loc,
        regWrite => regWrite,
        aluSrc => aluSrc,
        alu_control => alu_control,
        branch => branch,
        uncondBranch => uncondBranch,
        memRead => memRead,
        memWrite => memWrite,
        memToReg => memToReg,
        opcode => opcode
    );
    UC: unidadeControle port map(
        opcode => opcode,
        extendMSB => extendMSB,
        extendLSB => extendLSB,
        reg2Loc => reg2Loc,
        regWrite => regWrite,
        aluSrc => aluSrc,
        alu_control => alu_control,
        branch => branch,
        uncondBranch => uncondBranch,
        memRead => memRead,
        memWrite => memWrite,
        memToReg => memToReg
    );
end arch;