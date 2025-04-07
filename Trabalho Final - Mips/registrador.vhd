library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registrador is
    generic ( 
        regSize : integer := 32 
    );
    Port (
        clk   : in STD_LOGIC;  -- Clock
        rst   : in STD_LOGIC;  -- Reset assíncrono
        load  : in STD_LOGIC;  -- Habilita a escrita no registrador
        d_in  : in STD_LOGIC_VECTOR(regSize - 1 downto 0); -- Dado de entrada
        q_out : out STD_LOGIC_VECTOR(regSize - 1 downto 0) -- Dado armazenado
    );
end registrador;

architecture arq of registrador is
    signal q_reg : STD_LOGIC_VECTOR(regSize - 1 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            q_reg <= (others => '0');  -- Reset do registrador
        elsif rising_edge(clk) then
            if load = '1' then
                q_reg <= d_in; -- Carrega novo valor
            end if;
        end if;
    end process;

    q_out <= q_reg; -- Saída do registrador
end arq;