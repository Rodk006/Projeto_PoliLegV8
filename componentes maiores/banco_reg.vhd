library ieee;
use ieee.numeric_bit.all;

entity regfile is
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
end entity regfile;

architecture banco_reg of regfile is
    -- decodificador 5x32 (habilita um único registrador para escrita)
    signal dec_wr : bit_vector(31 downto 0);

	 --##--
	 
    -- registradores X0 ate X30 
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

    -- registradores X0 ate X30 (exclui-se X31, pois ele nao pode ser sobrescrito)
    signal regs_q : array (0 to 30) of bit_vector(63 downto 0); --array com as saidas de cada registrador

    -- registrador X31 (XZR)
    constant reg31 : bit_vector(63 downto 0) := (others => '0'); 
	 -- na minha cabeca isso funciona como registrador ligado ao terra

    --##--
	 
    -- mux 32x1 (para q1 e q2)
    function mux32x64 (
        sel : bit_vector(4 downto 0);
        reg_array : array (0 to 30) of bit_vector(63 downto 0)
    ) return bit_vector is
        variable n : integer := to_integer(unsigned(sel));
    begin
        if n = 31 then
            return reg_31;  -- leitura de XZR
        else
            return reg_array(n);
        end if;
    end function;
	 -- dado q as saidas desse mux sao apenas regitradores a entrada sempre pertencerá ao vetor regs_q
	 -- que possui os registradores.

begin
    -- decodificador 5x32
    process(wr)
        variable n : integer;
    begin
        dec_wr <= (others => '0');
        n := to_integer(unsigned(wr));
        if n >= 0 and n <= 31 then
            dec_wr(n) <= '1'; -- apenas o registrador do apontado por wr (XXXXX, 5 bits -> inteiro 0 ate 32)
        end if;
    end process;

    --##--
	 
    -- registradores X0 ate X30
    gen_regs : for i in 0 to 30 generate
        reg_i : reg
            generic map(dataSize => 64)
            port map(
                clock  => clock,
                reset  => reset,
                enable => regWrite AND dec_wr(i),
                d      => d,
                q      => regs_q(i) 
            );
    end generate;
	-- creio q por serem componentes registradores a permissao de escrita deles ja esta dito no arquivo reg.vhd
	-- mas para ter certeza teria que testar com o testbench
	 
	 --##--
	 
    -- leitura das saidas dos registradores
    q1 <= mux32x64(rr1, regs_q);
    q2 <= mux32x64(rr2, regs_q);

end architecture banco_reg;
