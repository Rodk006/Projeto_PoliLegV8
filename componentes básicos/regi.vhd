library ieee;

entity reg is
    generic (dataSize : natural := 64);
    port (
        clock  : in  bit;  										-- entrada de clock
        reset  : in  bit;  										-- clear assíncrono (ativo em '1')
        enable : in  bit;  										-- write enable (carga paralela)
        d      : in  bit_vector(dataSize - 1 downto 0);	-- entrada
        q      : out bit_vector(dataSize - 1 downto 0)  	-- saída
    );
end entity reg;

architecture of reg is
    signal reg_q : bit_vector(dataSize - 1 downto 0) := (others => '0');
begin
    process(clock, reset)
    begin
        if reset = '1' then reg_q <= (others => '0'); 
        elsif rising_edge(clock) then
            if enable = '1' then -- habilita a escrita
                reg_q <= d; -- escreve no registrador
            end if;
        end if;
    end process;

    q <= reg_q; -- saída recebe a "saida temporária"

end architecture;