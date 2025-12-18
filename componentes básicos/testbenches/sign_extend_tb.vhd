-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : tb_sign_extend.vhd
-- Projeto   : AF12 Parte 1 SDII 2025 - biblioteca de componentes para construção de um processador
-------------------------------------------------------------------------
-- Descricao : testbench para o extensor de sinal de tamanho cofigurável
--             testa alocando o componente como 16bits:16bits; 16bits:32bits e 32bits:64bits 
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/11/2025  1.0     Pedro Mendes      versão inicial
------------------------------------------------------------------------

--Grupo: T2G02

--14606485	Rodrigo Kenzo Haruna	(Turma 1)
--15487356	Rodrigo Oshima Asatsuma	(Turma 1)
--15487759	Sami Barbosa Adissi	(Turma 1)
--15453977	Gabriel Tagawa Francisco	(Turma 2)
--15637613	Gustavo Pinha Letizio	(Turma 2)
--15497416	Pedro de Oliveira Sousa	(Turma 2)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity tb_sign_extend is
end entity tb_sign_extend;

architecture testbench of tb_sign_extend is
    component sign_extend is
        generic (
            dataISize       : natural;
            dataOSize       : natural;
            dataMaxPosition : natural
        );
        port (
            inData      : in  bit_vector(dataISize-1 downto 0);
            inDataStart : in  bit_vector(dataMaxPosition-1 downto 0);
            inDataEnd   : in  bit_vector(dataMaxPosition-1 downto 0);
            outData     : out bit_vector(dataOSize-1 downto 0)
        );
    end component;

    type test_vector_16_16 is record
        inData      : bit_vector(15 downto 0);
        inDataStart : bit_vector(3 downto 0); 
        inDataEnd   : bit_vector(3 downto 0);
        outData_expected : bit_vector(15 downto 0);
    end record;

    type test_vector_16_32 is record
        inData      : bit_vector(15 downto 0);
        inDataStart : bit_vector(3 downto 0);
        inDataEnd   : bit_vector(3 downto 0);
        outData_expected : bit_vector(31 downto 0);
    end record;

    type test_vector_32_64 is record
        inData      : bit_vector(31 downto 0);
        inDataStart : bit_vector(4 downto 0); 
        inDataEnd   : bit_vector(4 downto 0);
        outData_expected : bit_vector(63 downto 0);
    end record;

    type test_array_16_16 is array (natural range <>) of test_vector_16_16;
    type test_array_16_32 is array (natural range <>) of test_vector_16_32;
    type test_array_32_64 is array (natural range <>) of test_vector_32_64;

    -- function to_bstring(s : signed) return string;
    -- Baseado em:
    -- https://stackoverflow.com/questions/26575986/vhdl-coding-conversion-from-integer-to-bit-vector
    -- https://stackoverflow.com/questions/24329155/is-there-a-way-to-print-the-values-of-a-signal-to-a-file-from-a-modelsim-simulat

    function to_bstring(bt : bit) return string is
        variable b_str_v : string(1 to 3);
    begin
        b_str_v := bit'image(bt);
        return "" & b_str_v(2);
    end function;

    function to_bstring(bv : bit_vector) return string is
        alias    bv_norm : bit_vector(1 to bv'length) is bv;
        variable b_str_v : string(1 to 1);
        variable res_v   : string(1 to bv'length);
    begin
        for idx in bv_norm'range loop
            b_str_v := to_bstring(bv_norm(idx));
            res_v(idx) := b_str_v(1);
        end loop;
        return res_v;
    end function;

    constant testes_16_16 : test_array_16_16 := (
        (x"0070", "0111", "0000", x"0070"),
        (x"008F", "0111", "0000", x"FF8F"),
        (x"7FFF", "1111", "0000", x"7FFF"),
        (x"8000", "1111", "0000", x"8000"),
        (x"70FF", "1111", "1000", x"0070"),
        (x"F0FF", "1111", "1000", x"FFF0"),
        (x"F70F", "1011", "0100", x"0070"),
        (x"FF0F", "1011", "0100", x"FFF0")
    );

    constant testes_16_32 : test_array_16_32 := (
        (x"0070", "0111", "0000", x"00000070"),
        (x"008F", "0111", "0000", x"FFFFFF8F"),
        (x"7FFF", "1111", "0000", x"00007FFF"),
        (x"8000", "1111", "0000", x"FFFF8000"),
        (x"70FF", "1111", "1000", x"00000070"),
        (x"F0FF", "1111", "1000", x"FFFFFFF0"),
        (x"F70F", "1011", "0100", x"00000070"),
        (x"FF0F", "1011", "0100", x"FFFFFFF0")
    );

    constant testes_32_64 : test_array_32_64 := (
        (x"00007000", "01111", "00000", x"0000000000007000"),
        (x"00008FFF", "01111", "00000", x"FFFFFFFFFFFF8FFF"),
        (x"70000000", "11111", "00000", x"0000000070000000"),
        (x"8FFFFFFF", "11111", "00000", x"FFFFFFFF8FFFFFFF"),
        (x"70FFFFFF", "11111", "10000", x"00000000000070FF"),
        (x"F0FFFFFF", "11111", "10000", x"FFFFFFFFFFFFF0FF"),
        (x"0070FFFF", "10111", "01000", x"00000000000070FF"),
        (x"00F0FFFF", "10111", "01000", x"FFFFFFFFFFFFF0FF")
    );


    signal inData_16      : bit_vector(15 downto 0);
    signal inDataStart_16 : bit_vector(3 downto 0);
    signal inDataEnd_16   : bit_vector(3 downto 0);
    signal outData_16     : bit_vector(15 downto 0);

    signal inData_16_32      : bit_vector(15 downto 0);
    signal inDataStart_16_32 : bit_vector(3 downto 0);
    signal inDataEnd_16_32   : bit_vector(3 downto 0);
    signal outData_16_32     : bit_vector(31 downto 0);

    signal inData_32_64      : bit_vector(31 downto 0);
    signal inDataStart_32_64 : bit_vector(4 downto 0);
    signal inDataEnd_32_64   : bit_vector(4 downto 0);
    signal outData_32_64     : bit_vector(63 downto 0);

begin
    UUT_16_16: sign_extend 
        generic map (16, 16, 4)
        port map (inData_16, inDataStart_16, inDataEnd_16, outData_16);

    UUT_16_32: sign_extend 
        generic map (16, 32, 4)
        port map (inData_16_32, inDataStart_16_32, inDataEnd_16_32, outData_16_32);

    UUT_32_64: sign_extend 
        generic map (32, 64, 5)
        port map (inData_32_64, inDataStart_32_64, inDataEnd_32_64, outData_32_64);

    processo_estimulo : process
    begin
        report "Iniciando testes do sign_extend...";
        
        report "Testando configuração 16 bits de entrada para 16 bits de saída...";
        for i in testes_16_16'range loop
            inData_16 <= testes_16_16(i).inData;
            inDataStart_16 <= testes_16_16(i).inDataStart;
            inDataEnd_16 <= testes_16_16(i).inDataEnd;
            
            wait for 10 ns;
            
            if outData_16 /= testes_16_16(i).outData_expected then
                report "Falha no teste 16_16-" & integer'image(i) & 
                       ": outData = 0x" & to_bstring(outData_16) & 
                       ", Esperado = 0x" & to_bstring(testes_16_16(i).outData_expected) &
                       " (inData=0x" & to_bstring(testes_16_16(i).inData) & 
                       ", Start=" & integer'image(to_integer(unsigned(testes_16_16(i).inDataStart))) &
                       ", End=" & integer'image(to_integer(unsigned(testes_16_16(i).inDataEnd))) & ")"
                       severity error;
            else
                report "Sucesso no teste 16_16-" & integer'image(i) severity note;
            end if;
        end loop;

        report "Testando configuração 16 bits de entrada para 32 bits de saída...";
        for i in testes_16_32'range loop
            inData_16_32 <= testes_16_32(i).inData;
            inDataStart_16_32 <= testes_16_32(i).inDataStart;
            inDataEnd_16_32 <= testes_16_32(i).inDataEnd;
            
            wait for 10 ns;
            
            if outData_16_32 /= testes_16_32(i).outData_expected then
                report "Falha no teste 16_32-" & integer'image(i) & 
                       ": outData = 0x" & to_bstring(outData_16_32) & 
                       ", Esperado = 0x" & to_bstring(testes_16_32(i).outData_expected) &
                       " (inData=0x" & to_bstring(testes_16_32(i).inData) & 
                       ", Start=" & integer'image(to_integer(unsigned(testes_16_32(i).inDataStart))) &
                       ", End=" & integer'image(to_integer(unsigned(testes_16_32(i).inDataEnd))) & ")"
                       severity error;
            else
                report "Sucesso no teste 16_32-" & integer'image(i) severity note;
            end if;
        end loop;

        report "Testando configuração 32 bits de entrada para 64 bits de saída...";
        for i in testes_32_64'range loop
            inData_32_64 <= testes_32_64(i).inData;
            inDataStart_32_64 <= testes_32_64(i).inDataStart;
            inDataEnd_32_64 <= testes_32_64(i).inDataEnd;
            
            wait for 10 ns;
            
            if outData_32_64 /= testes_32_64(i).outData_expected then
                report "Falha no teste 32_64-" & integer'image(i) & 
                       ": outData = 0x" & to_bstring(outData_32_64) & 
                       ", Esperado = 0x" & to_bstring(testes_32_64(i).outData_expected) &
                       " (inData=0x" & to_bstring(testes_32_64(i).inData) & 
                       ", Start=" & integer'image(to_integer(unsigned(testes_32_64(i).inDataStart))) &
                       ", End=" & integer'image(to_integer(unsigned(testes_32_64(i).inDataEnd))) & ")"
                       severity error;
            else
                report "Sucesso no teste 32_64-" & integer'image(i) severity note;
            end if;
        end loop;
        
        report "Simulação concluída!";
        wait;
    end process;

end architecture testbench;
