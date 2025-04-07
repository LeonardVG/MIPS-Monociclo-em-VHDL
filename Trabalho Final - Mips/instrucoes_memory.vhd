Library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

-- 2^32 posições de 32 bits cada
Entity instrucoes_memory is
generic(wlenght : integer := 32; -- tamanho de cada posição
        words 	 : integer := 32); -- quantidade de posiçoes
		  
port(
		 Addr		 : in std_logic_vector(words-1 downto 0);
		 clock	 : in std_logic;	 
		 DataOut	 : out std_logic_vector(31 downto 0)
);
end instrucoes_memory;


architecture arq of instrucoes_memory is

type tipo_memoria is array (31 downto 0) of std_logic_vector(wlenght-1 downto 0);
--signal memoria : tipo_memoria;

--inicializando a memoria manualmente
signal memoria : tipo_memoria := (
   "10001100000010000000000000000000", --   # lw $t0, 0($zero)
	"10001100000010010000000000000000", --  # lw $t1, 4($zero)
	"00000001000010010101000000100000", -- 	# add $t2, $t0, $t1
	"10101100000010100000000000001000", --   # sw $t2, 8($zero)
	"00001000000000000000000000000010",--     # j end
	"00000000000000000000000000000000",--      # nop
  others => "00000000000000000000000000000000" -- Zeros no restante
);--fazendo posição 0 + posição 4 , resultado no 8

begin

process(clock, addr)
begin
   if rising_edge(clock) then
	
		DataOut <= memoria(conv_integer(Addr));
		
	end if;
	
end process;
end arq;