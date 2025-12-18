--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.std_logic_1164.all;

entity testbench_uc is
end testbench_uc;

architecture behavior of testbench_uc is
    -- Component Declaration for the Unit Under Test (UUT)
    component unidadeControle
    port(
        opcode : in bit_vector (10 downto 0);
        extendMSB : out bit_vector (4 downto 0);
        extendLSB : out bit_vector (4 downto 0);
        reg2Loc : out bit;
        regWrite : out bit;
        aluSrc : out bit;
        alu_control : out bit_vector (3 downto 0);
        branch : out bit;
        uncondBranch : out bit;
        memRead : out bit;
        memWrite : out bit;
        memToReg : out bit
    );
    end component;

    -- Inputs
    signal opcode : bit_vector(10 downto 0) := (others => '0');

    -- Outputs
    signal extendMSB : bit_vector(4 downto 0);
    signal extendLSB : bit_vector(4 downto 0);
    signal reg2Loc : bit;
    signal regWrite : bit;
    signal aluSrc : bit;
    signal alu_control : bit_vector(3 downto 0);
    signal branch : bit;
    signal uncondBranch : bit;
    signal memRead : bit;
    signal memWrite : bit;
    signal memToReg : bit;

    -- Clock period definitions (if needed)
    constant clock_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: unidadeControle port map (
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

    -- Stimulus process
    stim_proc: process
    begin
        -- Teste 1: Instrução B (000101XXXXX)
        report "Teste 1: Instrução B";
        opcode <= "00010100000"; -- B
        wait for clock_period;
        assert uncondBranch = '1' report "Erro B: uncondBranch" severity error;
        assert branch = '0' report "Erro B: branch" severity error;
        
        -- Teste 2: Instrução CBZ (10110100XXX)
        report "Teste 2: Instrução CBZ";
        opcode <= "10110100000"; -- CBZ
        wait for clock_period;
        assert branch = '1' report "Erro CBZ: branch" severity error;
        assert uncondBranch = '0' report "Erro CBZ: uncondBranch" severity error;
        
        -- Teste 3: Instrução STUR (11111000000)
        report "Teste 3: Instrução STUR";
        opcode <= "11111000000"; -- STUR
        wait for clock_period;
        assert memWrite = '1' report "Erro STUR: memWrite" severity error;
        assert memRead = '0' report "Erro STUR: memRead" severity error;
        assert regWrite = '0' report "Erro STUR: regWrite" severity error;
        
        -- Teste 4: Instrução LDUR (11111000010)
        report "Teste 4: Instrução LDUR";
        opcode <= "11111000010"; -- LDUR
        wait for clock_period;
        assert memRead = '1' report "Erro LDUR: memRead" severity error;
        assert memWrite = '0' report "Erro LDUR: memWrite" severity error;
        assert regWrite = '1' report "Erro LDUR: regWrite" severity error;
        assert memToReg = '1' report "Erro LDUR: memToReg" severity error;
        
        -- Teste 5: Instrução ORR (10101010000)
        report "Teste 5: Instrução ORR";
        opcode <= "10101010000"; -- ORR
        wait for clock_period;
        assert regWrite = '1' report "Erro ORR: regWrite" severity error;
        assert alu_control = "0001" report "Erro ORR: alu_control" severity error;
        
        -- Teste 6: Instrução AND (10001010000)
        report "Teste 6: Instrução AND";
        opcode <= "10001010000"; -- AND
        wait for clock_period;
        assert regWrite = '1' report "Erro AND: regWrite" severity error;
        assert alu_control = "0000" report "Erro AND: alu_control" severity error;
        
        -- Teste 7: Instrução SUB (11001011000)
        report "Teste 7: Instrução SUB";
        opcode <= "11001011000"; -- SUB
        wait for clock_period;
        assert regWrite = '1' report "Erro SUB: regWrite" severity error;
        assert alu_control = "0110" report "Erro SUB: alu_control" severity error;
        
        -- Teste 8: Instrução ADD (10001011000)
        report "Teste 8: Instrução ADD";
        opcode <= "10001011000"; -- ADD
        wait for clock_period;
        assert regWrite = '1' report "Erro ADD: regWrite" severity error;
        assert alu_control = "0010" report "Erro ADD: alu_control" severity error;
        
        -- Teste 9: Instrução desconhecida (default)
        report "Teste 9: Instrução desconhecida";
        opcode <= "11111111111"; -- Instrução inválida
        wait for clock_period;
        assert regWrite = '0' report "Erro default: regWrite" severity error;
        assert memRead = '0' report "Erro default: memRead" severity error;
        assert memWrite = '0' report "Erro default: memWrite" severity error;
        
        -- Teste 10: CBZ com bits 2-0 diferentes
        report "Teste 10: Outro caso CBZ";
        opcode <= "10110100001"; -- CBZ com Rt = 001
        wait for clock_period;
        assert branch = '1' report "Erro CBZ2: branch" severity error;
        
        -- Teste 11: Mais casos de B
        report "Teste 11: Outro caso B";
        opcode <= "00010111111"; -- B com bits diferentes
        wait for clock_period;
        assert uncondBranch = '1' report "Erro B2: uncondBranch" severity error;
        
        report "=== Fim dos testes ===";
        wait;
    end process;

end behavior;
