library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shifter is
    generic ( 
        regSize: integer := 32 -- Define o tamanho do registrador (32 bits)
    );
    Port (
        B : in STD_LOGIC_VECTOR(regSize - 1 downto 0); -- Entrada de 32 bits
        resultShifter : out STD_LOGIC_VECTOR(regSize - 1 downto 0) -- Saída de 32 bits
    );
end shifter;

architecture arq of shifter is
    signal temp : STD_LOGIC_VECTOR(regSize - 1 downto 0); -- Sinal temporário para o deslocamento
begin
    process(B) -- Sensibilidade apenas à entrada B
    begin
        -- Desloca 2 bits à esquerda, preenchendo com '0' nas duas posições de menor peso
        temp <= B(regSize-3 downto 0) & "00";
    end process;

    -- Atribuição do resultado do deslocamento à saída
    resultShifter <= temp;
end arq;