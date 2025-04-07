library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity banco_registradores is
    generic ( 
        regSize : integer := 32;
        numRegs : integer :=32
    );
    Port (
        clk    : in STD_LOGIC;  -- Clock					
        rst    : in STD_LOGIC;  -- Reset assíncrono   | --> não sei se rst são necessarios	  
		  EscReg   			   : in STD_LOGIC;  -- controla a escrita
        Reg_a_serLido1     : in STD_LOGIC_VECTOR(4 downto 0);  
        Reg_a_serLido2     : in STD_LOGIC_VECTOR(4 downto 0);  
        Reg_a_serEscrito   : in STD_LOGIC_VECTOR(4 downto 0);  
        d_escrita			   : in STD_LOGIC_VECTOR(regSize - 1 downto 0);  -- Dado vindo da memoria de dados depois de passar pelo mux memParaReg
        dadoLido1  	      : out STD_LOGIC_VECTOR(regSize - 1 downto 0); 
        dadoLido2		      : out STD_LOGIC_VECTOR(regSize - 1 downto 0)  
    );
end banco_registradores;

architecture arq of banco_registradores is
    -- Define o tipo da array para os registradores
    type regArray is array (0 to numRegs - 1) of STD_LOGIC_VECTOR(regSize - 1 downto 0);
    -- Declara os registradores usando o tipo criado
    signal registers : regArray := (others => (others => '0'));

begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reseta todos os registradores para 0
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if EscReg = '1' then
                -- Escreve no registrador selecionado
                registers(to_integer(unsigned(Reg_a_serEscrito))) <= d_escrita;
            end if;
        end if;
    end process;

    -- Lendo os valores dos registradores especificados
	 --O banco de registradores esta sempre com os dados 1 e 2 na saida, se vai ser usado ou não 
	 --é o bloco de controle q decde
    dadoLido1 <= registers(to_integer(unsigned(Reg_a_serLido1)));
    dadoLido2 <= registers(to_integer(unsigned(Reg_a_serLido2)));

end arq;