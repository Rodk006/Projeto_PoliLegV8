library ieee;
use ieee.numeric_bit.all;

entity fluxoDados is
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
end entity fluxoDados;

architecture arch of fluxoDados is

    component reg
        generic(dataSize : natural := 64);
        port(
            clock  : in bit;
            reset  : in bit;
            enable : in bit;
            d      : in bit_vector(dataSize - 1 downto 0);
            q      : out bit_vector(dataSize - 1 downto 0)
        );
    end component;

    component memoriaInstrucoes 
	generic (
		addressSize : natural := 8;
		dataSize    : natural := 8;
		datFileName : string := "memInstr_conteudo.dat"
	);
	port (
		addr : in bit_vector (addressSize - 1 downto 0);
		data : out bit_vector (dataSize - 1 downto 0)
	);
    end component;

    component regfile 
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

    component sign_extend 
        generic (
            dataISize       : natural := 32;
            dataOSize       : natural := 64;
            dataMaxPosition : natural := 5
        );
        port (
            inData      : in  bit_vector(dataISize - 1 downto 0);
            inDataStart : in  bit_vector(dataMaxPosition - 1 downto 0);
            inDataEnd   : in  bit_vector(dataMaxPosition - 1 downto 0);
            outData     : out bit_vector(dataOSize - 1 downto 0)
        );
    end component;

    component ula 
	port (
		A  : in  bit_vector(63 downto 0); 	-- entrada A
		B  : in  bit_vector(63 downto 0); 	-- entrada B
		S  : in  bit_vector( 3 downto 0); 	-- seleciona operacao
		F  : out bit_vector(63 downto 0); 	-- saida
		Z  : out bit;  							-- flag zero (1 se F = 0)
		Ov : out bit;  							-- flag overflow (do MSB)
		Co : out bit   							-- carry out (do MSB)
	);
    end component;

    component mux_n 
    generic (dataSize : natural := 64);
    port (
        in0   : in  bit_vector(dataSize-1 downto 0);	-- entrada de dados 0
        in1   : in  bit_vector(dataSize-1 downto 0);	-- entrada de dados 1
        sel   : in  bit;  										-- sinal de seleção
        dOut  : out bit_vector(dataSize-1 downto 0)	-- sinal de dados
    );
    end component;

    component memoriaDados 
	generic (
		addressSize : natural := 8;
		dataSize    : natural := 8;
		datFileName : string  := "memDados_conteudo_inicial.dat"
	);
	port (
		clock 	: in  bit;
		wr 		: in  bit;
		addr 		: in  bit_vector (addressSize - 1 downto 0);
		data_i 	: in  bit_vector (dataSize - 1 downto 0);
		data_o 	: out bit_vector (dataSize - 1 downto 0)
	);
    end component;

    component adder_n 
	generic (dataSize : natural := 64);
	port (
		in0  : in bit_vector(dataSize - 1 downto 0);  -- primeira parcela
		in1  : in bit_vector(dataSize - 1 downto 0);  -- segunda parcela
		sum  : out bit_vector(dataSize - 1 downto 0); -- soma 
		Cout : out bit										   -- carry
	);
    end component;

    component two_left_shifts 
    generic(
        dataSize : natural := 64
    );
    port(
        input: in bit_vector(dataSize-1 downto 0);
        output: out bit_vector(dataSize-1 downto 0)
    );
    end component;

    signal  outPC, outPC2, outPC3, outPC4, F2, F3, F4, F5, F6, F7, F8 : bit_vector(6 downto 0);
    signal instruction : bit_vector(31 downto 0); 
    signal outMuxWD, readData1, readData2, readDataDM, A, B, F, outSL, immSE, pc4, pcBranch, outMuxPC, outMuxRegs : bit_vector(63 downto 0);
    signal zero, ov, cout, carry4, carryBR, branchControl : bit;

    begin 

        branchControl <= uncondBranch or (branch and zero);

        outPC2 <= bit_vector(unsigned(outPC) + 1);
        outPC3 <= bit_vector(unsigned(outPC) + 2);
        outPC4 <= bit_vector(unsigned(outPC) + 3);

        F2 <= bit_vector(unsigned(F(6 downto 0)) + 1);
        F3 <= bit_vector(unsigned(F(6 downto 0)) + 2);
        F4 <= bit_vector(unsigned(F(6 downto 0)) + 3);
        F5 <= bit_vector(unsigned(F(6 downto 0)) + 4);
        F6 <= bit_vector(unsigned(F(6 downto 0)) + 5);
        F7 <= bit_vector(unsigned(F(6 downto 0)) + 6);
        F8 <= bit_vector(unsigned(F(6 downto 0)) + 7);

        opcode <= instruction(31 downto 21);


        PC : reg generic map (dataSize => 7)
                 port map (clock, reset, '1', outMuxPC(6 downto 0), outPC);

        IM1 : memoriaInstrucoes generic map (addressSize => 7, 
                                            dataSize => 8,
                                            datFileName => "memInstrPolilegv8.dat")
                               port map (outPC, instruction(31 downto 24));

        IM2 : memoriaInstrucoes generic map (addressSize => 7, 
                                            dataSize => 8,
                                            datFileName => "memInstrPolilegv8.dat")
                               port map (outPC2, instruction(23 downto 16));

        IM3 : memoriaInstrucoes generic map (addressSize => 7, 
                                            dataSize => 8,
                                            datFileName => "memInstrPolilegv8.dat")
                               port map (outPC3, instruction(15 downto 8));

        IM4 : memoriaInstrucoes generic map (addressSize => 7, 
                                            dataSize => 8,
                                            datFileName => "memInstrPolilegv8.dat")
                               port map (outPC4, instruction(7 downto 0));

        Registers : regfile port map (clock, reset, regWrite, instruction(9 downto 5), outMuxRegs(4 downto 0) ,instruction(4 downto 0), outMuxWD, readData1, readData2);

        SE : sign_extend generic map (dataISize        => 32, 
                                      dataOSize        => 64,
                                      dataMaxPosition  => 5)
                         port map (instruction, extendMSB, extendLSB, immSE);

        ULA64 : ula port map (readData1, B, alu_control, F, zero, ov, cout);

        MUX_REGS : mux_n generic map (dataSize => 64)
                         port map (((63 downto 5 => '0') & instruction(20 downto 16)), ((63 downto 5 => '0') & instruction(4 downto 0)), reg2Loc, outMuxRegs);

        MUX_ULA : mux_n generic map (dataSize => 64)
                        port map (readData2, immSE, aluSrc, B);
        
        MUX_WD : mux_n generic map (dataSize => 64)
                       port map (F, readDataDM, memToReg, outMuxWD);

        MUX_PC : mux_n generic map (dataSize => 64)
                       port map (pc4, pcBranch, branchControl, outMuxPC);

        DM1 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F(6 downto 0), readData2(63 downto 56), readDataDM(63 downto 56));

        DM2 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F2, readData2(55 downto 48), readDataDM(55 downto 48));

        DM3 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F3, readData2(47 downto 40), readDataDM(47 downto 40));

        DM4 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F4, readData2(39 downto 32), readDataDM(39 downto 32));

        DM5 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F5, readData2(31 downto 24), readDataDM(31 downto 24));

        DM6 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F6, readData2(23 downto 16), readDataDM(23 downto 16));

        DM7 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F7, readData2(15 downto 8), readDataDM(15 downto 8));

        DM8 : memoriaDados generic map (addressSize => 7, 
                                        dataSize => 8,
                                        datFileName => "memDadosInicialPolilegv8.dat")
                          port map (clock, memWrite, F8, readData2(7 downto 0), readDataDM(7 downto 0));

        ADD_4 : adder_n generic map (dataSize => 64)
                        port map (((63 downto 7 => '0') & outPC), (2 => '1', others => '0'), pc4, carry4);

        ADD_BR : adder_n generic map (dataSize => 64)
                         port map (((63 downto 7 => '0') & outPC), outSL, pcBranch, carryBR);

        SL : two_left_shifts generic map (dataSize => 64)
                             port map (immSE, outSL);

end arch;

        

        
