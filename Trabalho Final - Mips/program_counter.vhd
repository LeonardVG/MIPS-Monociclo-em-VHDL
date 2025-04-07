library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_counter is
    port (
        clk                	 : in  std_logic;                       
        endereco_para_carregar : in  std_logic_vector(31 downto 0); -- endereço a ser carregado no PC
        endereco_atual         : out std_logic_vector(31 downto 0)  -- endereço atual armazenado no PC
    );
end program_counter;

architecture arq of program_counter is
    -- Sinal interno para armazenar o endereço atual
    signal endereco : std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- Inicializado com zero
begin
    process(clk, endereco_para_carregar, endereco)
    begin
        if rising_edge(clk) then
            -- Carrega o novo endereço fornecido na entrada
            endereco <= endereco_para_carregar;
        end if;
		        -- Atualiza a saída com o endereço armazenado
        endereco_atual <= endereco;  
    end process;
end arq;