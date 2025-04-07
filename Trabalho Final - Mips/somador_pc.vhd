library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity somador_pc is
    port (
        pc_in    : in  std_logic_vector(31 downto 0); -- a entrada é a sasida do PC ou seja o endereço atual
        pc_out   : out std_logic_vector(31 downto 0)  -- Saída do somador (endereço atualizado)
    );
end somador_pc; 

architecture beh of somador_pc is
    -- Define a constante 4 em 32 bits
    constant constante_4 : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";-- Como a memoria mudou o endereçamento agora o pc evolui de 1 em 1
begin
    -- Soma a entrada pc_in com a constante 4 e atribui o resultado a pc_out
    pc_out <= std_logic_vector(unsigned(pc_in) + unsigned(constante_4));
end beh;