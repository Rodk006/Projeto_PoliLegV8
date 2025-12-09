library ieee;
use ieee.numeric_bit.all;

entity sign_extend is
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
end entity sign_extend;

architecture rtl of sign_extend is
begin
    process(inData, inDataStart, inDataEnd)
        variable startI : integer;
        variable endI   : integer;
        variable sign   : bit;
        variable width  : integer;
        variable temp   : bit_vector(dataOSize - 1 downto 0);
    begin
        -- Converter índices
        startI := to_integer(unsigned(inDataStart));
        endI   := to_integer(unsigned(inDataEnd));

        -- Largura do campo útil
        width := startI - endI + 1;

        -- Bit de sinal
        sign := inData(startI);

        -- 1) copiar o campo útil para o LSB
        temp(width - 1 downto 0) := inData(startI downto endI);

        -- 2) preencher o resto com sign-extend
        if sign = '1' then
            temp(dataOSize - 1 downto width) := (others => '1');
        else
            temp(dataOSize - 1 downto width) := (others => '0');
        end if;

        -- saída
        outData <= temp;
    end process;

end architecture rtl;
