library ieee;

entity tb_polilegv8 is 
end entity tb_polilegv8;

architecture test of tb_polilegv8 is
    component polilegv8
        port(
            clock : in bit;
            reset : in bit
        );
    end component;

    signal s_clock : bit := '0';
    signal s_reset : bit := '0';

    constant CLK_PERIOD : time := 10 us;

    signal keep_simulating : bit := '1';    

begin 
    s_clock <= not(s_clock) and keep_simulating after CLK_PERIOD/2;

    CPU: polilegv8
        port map(s_clock, s_reset);

end test;
