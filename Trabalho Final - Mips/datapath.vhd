library IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is

Port (
        clk,reset : in STD_LOGIC;
		  --saidas secundarias para verificação
		  SAIDA_ULA : out std_logic_vector(31 downto 0);
		  IN_DADO_REGS, REG1_LIDO,REG2_LIDO :out std_logic_vector(31 downto 0)
		
    );
end datapath;

architecture ARQ of datapath is

--=================Componentes======================

    Component banco_registradores is
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
		end Component;
--------------------------------------------------------------------------------		
		Component signal_extend is
			port (
				x: in std_logic_vector(15 downto 0);
				y: out std_logic_vector(31 downto 0)
			);
		end Component;
---------------------------------------------------------------------------------
		Component shifter is
			 generic ( 
				  regSize: integer := 32 -- Define o tamanho do registrador (32 bits)
			 );
			 Port (
				  B : in STD_LOGIC_VECTOR(regSize - 1 downto 0); -- Entrada de 32 bits
				  resultShifter : out STD_LOGIC_VECTOR(regSize - 1 downto 0) -- Saída de 32 bits
			 );
		end Component;
----------------------------------------------------------------------------------		
		Component somador_pc is
			 port (
				  pc_in    : in  std_logic_vector(31 downto 0); -- a entrada é a sasida do PC ou seja o endereço atual
				  pc_out   : out std_logic_vector(31 downto 0)  -- Saída do somador (endereço atualizado)
			 );
		end Component;
-----------------------------------------------------------------------------------
		Component somador_beq is
			 port (
				  entrada_1 : in  std_logic_vector(31 downto 0); -- Primeira entrada é a saida do somador_pc (q já vai ta com o endereço atualizado)
				  entrada_2 : in  std_logic_vector(31 downto 0); -- Segunda entrada é a saida do deslocamento a esquerda em 2 bits
				  resultado : out std_logic_vector(31 downto 0)  -- Resultado da soma  (que depois se conecta na entrada de um mux)
			 );
		end Component;
-----------------------------------------------------------------------------------
		Component program_counter is
			 port (
				  clk                : in  std_logic;                       
				  endereco_para_carregar : in  std_logic_vector(31 downto 0); -- endereço a ser carregado no PC
				  endereco_atual         : out std_logic_vector(31 downto 0)  -- endereço atual armazenado no PC
			 );
		end Component;
-----------------------------------------------------------------------------------		
		Component ula is
			 port (
				  in_1, in_2       : in  std_logic_vector(31 downto 0); -- Operandos
				  alu_control_func : in  std_logic_vector(2 downto 0);  -- Controle da operação (3 bits)
				  
				  -- Saídas: resultado da operação e flag zero
				  alu_result : out std_logic_vector(31 downto 0); -- Resultado da operação
				  zero       : out std_logic                      -- Flag que indica se o resultado é zero
			 );
		end Component;
------------------------------------------------------------------------------------		
		Component controle_ula is
			 port (
				  funct          : in  std_logic_vector(5 downto 0); -- Campo "funct" da instrução
				  ULAOp          : in  std_logic_vector(1 downto 0); -- Identifica a classe da instrução
				  operacao_daULA : out std_logic_vector(2 downto 0)  -- Operação a ser realizada pela ULA
			 );
		end Component;
-------------------------------------------------------------------------------------		
		Component control is
			 port (
				  clk	  : in std_logic;
				  opcode: in std_logic_vector(5 downto 0); -- Operação de entrada
				  reg_dest, jump, DvC, LerMem, memParaReg, EscMem, ulaFonte, EscReg: out std_logic;
				  alu_op: out std_logic_vector(1 downto 0)
			 );
		end Component;
-------------------------------------------------------------------------------------		
		Component instrucoes_memory is
			generic(wlenght : integer := 32; -- tamanho de cada posição
					  words 	 : integer := 32); -- quantidade de posiçoes
					  
			port(
					 Addr		 : in std_logic_vector(words-1 downto 0);
					 clock	 : in std_logic;	 
					 DataOut	 : out std_logic_vector(31 downto 0)
			);
		end Component;
--------------------------------------------------------------------------------------
		Component dados_memory is
		generic(wlenght : integer  := 32;
				  words 	 : integer 	:= 32);
		port(DataIn			 : in std_logic_vector(wlenght-1 downto 0); --Dado para escrever
			  Addr 		 	 : in std_logic_vector(words-1 downto 0);		--Onde escrever
			  clock,EscMem  : in std_logic;										-- we habilita escrita
			  DataOut 		 : out std_logic_vector(wlenght-1 downto 0)
			 );
		end Component;
--=====================================================================================================		
--=========================Sinais internos=============================================================	
   
signal S_dadoLido1, S_dadoLido2 : std_logic_vector (31 downto 0); -- conecta as saidas do banco de reg com as entradas da ula
signal S_reg_dest, S_jump, S_DvC, S_LerMem, S_memParaReg, S_EscMem, S_ulaFonte, S_EscReg : std_logic := '0'; --sinais de controle
signal S_alu_op : std_logic_vector(1 downto 0); --sinal de controle, escolhe a operação no controle_ula
signal mux_Rt_Rd : std_logic_vector(4 downto 0);
signal mux_memParaReg, saida_PC,Saida_SomadorPC, Saida_MemI,Saida_MemD, S_last_instr, mux_reg_ula,mux_BEQ, mux_para_PC: std_logic_vector (31 downto 0);
signal desloc_extendido, S_resultadoULA , desl_para_sum , Saida_SumBeq: std_logic_vector (31 downto 0);
signal oper_da_ula : std_logic_vector(2 downto 0); -- sinal que pega a saida dobloco de controle da ula que decide qual operação será feita
signal S_flagZero, FontePC : std_LOGIC;
--Para jump
signal S_paraDesloc2, saida_deslocJump: std_logic_vector(25 downto 0);
signal deslocJump_mais2bits : std_logic_vector (27 downto 0);
signal posicao_Jump: std_logic_vector (31 downto 0);


signal S_opcode : std_logic_vector(5 downto 0); --utilizado emm todos os tipos de instrucoes a seguir
------instruçoes tipo R----------------------------------
signal Rs, Rt, Rd : std_logic_vector(4 downto 0); --reg a ser lido 1,2, reg a ser escrito
signal funct      : std_logic_vector(5 downto 0); --qual op vai fazer
------instruçoes tipo lw ou rw----------------------------------utiliza tb rs e rt
signal deslocamento : std_logic_vector(15 downto 0);
--=======================================================================================

begin
--------------------------
PC: program_counter
			 port map(
				  clk               		 => clk,                       
				  endereco_para_carregar => mux_para_PC,
				  endereco_atual         => Saida_PC  -- sai do pc vai pra memoria de instr e somadorPC
			 );
------------------------------------------------------------------------------------------
SUM_PC: somador_pc
			 port map(
				  pc_in    => Saida_PC,
				  pc_out   => Saida_SomadorPC
			 );
------------------------------------------------------------------------------------------
MEM_INSTR: instrucoes_memory 
			generic map(
							wlenght => 32,
							words   => 32
			)			  
			port map(
					 Addr		 => Saida_PC,  -- o enderço que vai buscar vem da saida do PC
					 clock	 => clk,	 
					 DataOut	 => Saida_MemI -- a saida da memoria de instruçoes tem 32 bits e é dividida a seguir
			);
		

------------------------------------------------------
--================================================= -- pag 10 do slide sobre o bloco de controle
	S_opcode <= Saida_MemI(31 downto 26);
	Rs <= Saida_MemI(25 downto 21);
	Rt <= Saida_MemI(20 downto 16);
	Rd <= Saida_MemI(15 downto 11);
	funct <= Saida_MemI(5 downto 0);
	deslocamento <= Saida_MemI(15 downto 0);
--=================================================	
-------------------------------------------------------	
CONTROLE:	control 
	port map (
				  clk       => clk,
				  opcode 	=> S_opcode,
				  reg_dest 	=> S_reg_dest,
				  jump		=> S_jump,
				  DvC			=> S_DvC,
				  LerMem 	=> S_LerMem,
				  memParaReg=> S_memParaReg,
				  EscMem		=> S_EscMem,
				  ulaFonte	=> S_ulaFonte,
				  EscReg		=> S_EscReg, 
				  alu_op		=> S_alu_op
			 );
--------------------------------------------------------
	-- MUX entre a memoria de instruções e o banco de registradores
    mux_Rt_Rd <= Rt when S_reg_dest = '0' else Rd;
--------------------------------------------------------
	-- MUX na saida da memoria de dados e o resultado vai para dadodeEscrita do banco de registradores
    mux_memParaReg <= Saida_MemD when S_memParaReg = '0' else S_resultadoULA ;
--------------------------------------------------------
BANCO_REGs: banco_registradores				
	generic map(									
			     regSize 			=> 32,		
				  numRegs			=> 32
	)
	port map(
				  clk					=> clk,					
				  rst    			=> reset,  
				  EscReg   			=> S_EscReg,
				  Reg_a_serLido1  =>	Rs,  
				  Reg_a_serLido2  =>	Rt, 
				  Reg_a_serEscrito=> mux_Rt_Rd,
				  d_escrita			=> mux_memParaReg,---***definir o mux ali encima depois***********
				  dadoLido1  	   => S_dadoLido1,
				  dadoLido2		   => S_dadoLido2     --dado que é escrito na memoria de dados
			 );
----------------------------------------------------------
MEM_DADOS: dados_memory 
		generic map(wlenght => 32,
				  words 		  => 32
		)
		port map(DataIn		 => S_dadoLido2,
				   Addr 		 	 => S_resultadoULA, --O endereço onde vai acessar pra ler ou escrever vem do resultado da ula
				   clock			 => clk,
					EscMem  		 => S_EscMem,										
				   DataOut 		 => Saida_MemD
			 );
------------------------------------------------------------			 
EXTENSAO_SINAL: signal_extend
			port map(
				x	=> deslocamento,
				y	=> desloc_extendido
			);
---------------------------------------------------------------------------
	-- MUX entre o banco de registradores e a ULA
    mux_reg_ula <= S_dadoLido2 when S_ulaFonte = '0' else desloc_extendido; -- a siada desse mux vai pra entrada 2 da ual
---------------------------------------------------------------------------
ULA_CONTROL: controle_ula 
			 port map(
				  funct          => funct,
				  ULAOp          => S_alu_op, -- decide se vai ser uma soma subtração ou um tipo R, se for tipo R utiliza o funct
				  operacao_daULA => oper_da_ula -- saida que controla o que a ula vai fazer
			 );
---------------------------------------------------------------------------
ULA_m: ula
		port map(
				  in_1				 => S_dadoLido1,
				  in_2     			 => mux_reg_ula,
				  alu_control_func => oper_da_ula,
				  alu_result 		 => S_resultadoULA,  --vai pra entrada da memoria de dados depois
				  zero       		 => S_flagZero			-- vai pra entrada de um and pra decidir desvios futuramente
			 );
-----------------------------------------------------------------------------
DESL_beq: shifter 
			 generic map( 
				  regSize => 32 
			 )
			 Port map(
							B				  => desloc_extendido,
							resultShifter => desl_para_sum
			 );			 
-----------------------------------------------------------------------------
SUM_BEQ: somador_beq 
			 port map(
				  entrada_1 => Saida_SomadorPC,
				  entrada_2 => desl_para_sum,
				  resultado => Saida_SumBeq
			 );			 
----------------------------------------------------------------------------
--AND entre DvC e flag ZERO da ULA
FontePC <= S_DvC and S_flagZero;
----------------------------------------------------------------------------
--MUX entre os dois somadores e controlado por FontePC 
mux_BEQ <= Saida_SomadorPC when FontePC= '0' else Saida_SumBeq;
----------------------------------------------------------------------------
S_paraDesloc2 <= Saida_MemI(25 downto 0);
DESL_jump: shifter 
			 generic map( 
				  regSize => 26 
			 )
			 Port map(
							B				  => S_paraDesloc2,
							resultShifter => saida_deslocJump
			 );
deslocJump_mais2bits <= saida_deslocJump & "00";

posicao_Jump <= deslocJump_mais2bits & Saida_SomadorPC(31 downto 28);
----------------------------------------------------------------------------
--MUX final que o resultado vai na entrada do PC, decide entre jump ou (beq ou proxima posição) 
mux_para_PC <= Mux_BEQ when S_jump = '0' else posicao_Jump ; 



SAIDA_ULA    <= S_resultadoULA;
IN_DADO_REGS <= mux_memParaReg;
REG1_LIDO <= S_dadoLido1;
REG2_LIDO <= S_dadoLido2;

--===========================================================================
--SINAIS DE CONTROLE TODOS PRONTOS.
--OLHAR DA LINHA 120 A 136  E SE QUISER VERIFICAR OLHAR DA LINHA 158 A  173 (PARA TER MAIS CERTEZA DO BLOCO DE CONTROLE SÓ)

----------------Falta FAZER:-----------------------------
--OLHAR A IMAGEM DA PAGINA 40 DOS SLIDES DE CONTROLE-----

---[X] mux da saida da memoria de dados
---[X] instanciar PC e fazer toda a lligação do PC som o somador_pc e a memoria de instruçoes
---[X] parte dos desvios: condicional (beq) e incondicional(jump) -- essa parte é tranquila de fazer 
---[X] só instanciar o shifter e o somador_beq e criar os muxs e o and (ta na pag 40 dos slides de controle)			 

end ARQ;