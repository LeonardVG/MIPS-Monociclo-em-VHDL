library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity signal_extend is
	port (
		x: in std_logic_vector(15 downto 0);
		y: out std_logic_vector(31 downto 0)
	);
end signal_extend;

architecture arq of signal_extend is
	begin
	y <= std_logic_vector(resize(signed(x), y'length));
end arq;