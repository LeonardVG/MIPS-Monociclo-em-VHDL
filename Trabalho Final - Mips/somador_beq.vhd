library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity somador_beq is
    port (
        entrada_1 : in  std_logic_vector(31 downto 0); -- Primeira entrada é a saida do somador_pc (q já vai ta com o endereço atualizado)
        entrada_2 : in  std_logic_vector(31 downto 0); -- Segunda entrada é a saida do deslocamento a esquerda em 2 bits
        resultado : out std_logic_vector(31 downto 0)  -- Resultado da soma  (que depois se conecta na entrada de um mux)
    );
end somador_beq;

architecture arq of somador_beq is
begin

    resultado <= std_logic_vector(unsigned(entrada_1) + unsigned(entrada_2));
	 
end arq;