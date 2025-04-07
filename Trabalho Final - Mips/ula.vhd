library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
    port (
        in_1, in_2       : in  std_logic_vector(31 downto 0); -- Operandos
        alu_control_func : in  std_logic_vector(2 downto 0);  -- Controle da operação (3 bits)
        
        -- Saídas: resultado da operação e flag zero
        alu_result : out std_logic_vector(31 downto 0); -- Resultado da operação
        zero       : out std_logic                      -- Flag que indica se o resultado é zero
    );
end ula;

-- Arquitetura comportamental
architecture arq of ula is
begin
    process(in_1, in_2, alu_control_func)
    variable result : std_logic_vector(31 downto 0); 
    begin
        -- Verifica o comando no alu_control_func para decidir a operação
        case alu_control_func is
            when "000" => 
                -- Operação AND
                result := in_1 and in_2;
            when "001" => 
                -- Operação OR
                result := in_1 or in_2;
            when "010" => 
                -- Operação de soma
                result := std_logic_vector(unsigned(in_1) + unsigned(in_2)); -- Conversão para soma
            when "011" => 
                -- Operação de subtração
                result := std_logic_vector(unsigned(in_1) - unsigned(in_2)); -- Conversão para subtração
           -- when "100" => --***NÃO FUNCIONA POIS A SAIDA TEM QUE TER 32 BITS E MULT DE DOIS DE 32BITS DA 64***
                -- Operação de multiplicação
            --   result := std_logic_vector(unsigned(in_1) * unsigned(in_2)); -- Conversão para multiplicação
				when "100" =>
					 -- Operação de multiplicação com truncamento para os 32 bits menos significativos
					 result := std_logic_vector(resize(unsigned(in_1) * unsigned(in_2), result'length));	 
				when others => 
                -- Caso padrão: resultado zerado
                result := (others => '0');
        end case;

        -- Atribuição do resultado final à saída
        alu_result <= result;

        -- Configuração do flag zero: ativo se o resultado for igual a zero
        if result = "00000000000000000000000000000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;
end arq;