Library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
--igual a de instruçoes mas tem escrita
Entity dados_memory is
generic(wlenght : integer := 32;
        words : integer := 32);
port(DataIn 	: in std_logic_vector(wlenght-1 downto 0); --Dado para escrever
     Addr 		: in std_logic_vector(words-1 downto 0);		--Onde escrever
	  clock,EscMem  : in std_logic;										-- we habilita escrita
	  DataOut 	: out std_logic_vector(wlenght-1 downto 0)
	 );
end dados_memory;

architecture arq of dados_memory is

type tipo_memoria is array (31 downto 0) of std_logic_vector(wlenght-1 downto 0); 
signal memoria : tipo_memoria := ("00000000000000000000000000000000",
											 "00000000000000000000000000000100",
											 "00000000000000000000000000000011",
											 "00000000000000000000000000000101",
											 "00000000000000000000000000000011",
											 "00000000000000000000000000000011",
											 "00000000000000000000000000000011",
											 "00000000000000000000000000000011",
											 "00000000000000000000000000000000",
											 others=>"00000000000000000000000000000000");

begin

process(clock, EscMem, addr)
begin
   if rising_edge(clock) then
	   if EscMem =  '1' then
		   memoria(conv_integer(Addr)) <= DataIn;
		end if;
		DataOut <= memoria(conv_integer(Addr));
	end if;
end process;

end arq;