library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controle_ula is
    port (
        funct          : in  std_logic_vector(5 downto 0); -- Campo "funct" da instrução
        ULAOp          : in  std_logic_vector(1 downto 0); -- Identifica a classe da instrução
        operacao_daULA : out std_logic_vector(2 downto 0)  -- Operação a ser realizada pela ULA
    );
end controle_ula;

architecture arq of controle_ula is
begin
    process(funct, ULAOp)
    begin
        case ULAOp is
            when "00" =>
                -- lw/sw: realizar adição
                operacao_daULA <= "010"; -- Código para operação de soma
            when "01" =>
                -- beq: realizar subtração
                operacao_daULA <= "011"; -- Código para operação de subtração
            when "10" =>
                -- instruções do tipo R: vai depender do campo funct
                case funct is
                    when "100000" => 
                        operacao_daULA <= "010"; -- Soma
                    when "100010" => 
                        operacao_daULA <= "011"; -- Subtração
                    when "100100" => 
                        operacao_daULA <= "000"; -- AND
                    when "100101" => 
                        operacao_daULA <= "001"; -- OR
                    when "011000" => 
                        operacao_daULA <= "100"; -- Multiplicação
                    when others => 
                        operacao_daULA <= "111"; -- Operação inválida
                end case;
            when others =>
                -- Caso padrão: operação inválida
                operacao_daULA <= "111";
        end case;
    end process;
end arq;