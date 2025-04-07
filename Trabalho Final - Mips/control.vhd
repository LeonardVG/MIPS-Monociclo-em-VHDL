library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control is
    port (
        clk: in std_logic;                                 -- Apenas o clock (sem reset)
        opcode: in std_logic_vector(5 downto 0);           -- Operação de entrada
        reg_dest, jump, DvC, LerMem, memParaReg, EscMem, ulaFonte, EscReg: out std_logic;
        alu_op: out std_logic_vector(1 downto 0)
    );
end control;

architecture Maquina_estados of control is
    type state_type is (R_TYPE, BEQ, JUMP_state, LW, SW);  -- Removido o estado IDLE
    signal current_state, next_state : state_type;        -- Estados atual e próximo
begin
    -- Transição de estados sincronizada com a borda de subida do clock
    process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;                 -- Atualiza o estado atual
        end if;
    end process;

    -- Lógica de próximo estado com base no opcode
    process(current_state, opcode)
    begin
        case opcode is
            when "000000" => next_state <= R_TYPE;       -- R-Type
            when "000100" => next_state <= BEQ;          -- BEQ
            when "000010" => next_state <= JUMP_state;   -- Jump
            when "100011" => next_state <= LW;           -- LW
            when "101011" => next_state <= SW;           -- SW
            when others   => next_state <= R_TYPE;       -- Padrão
        end case;
    end process;

    -- Geração dos sinais de controle com base no estado atual
    process(current_state)
    begin
        case current_state is
            when R_TYPE =>
                reg_dest <= '1'; jump <= '0'; DvC <= '0'; LerMem <= '0';
                memParaReg <= '1'; EscMem <= '0'; ulaFonte <= '0'; EscReg <= '1';
                alu_op <= "10";

            when BEQ =>
                reg_dest <= '0'; jump <= '0'; DvC <= '1'; LerMem <= '0';
                memParaReg <= '0'; EscMem <= '0'; ulaFonte <= '0'; EscReg <= '0';
                alu_op <= "01";

            when JUMP_state =>
                reg_dest <= '0'; jump <= '1'; DvC <= '0'; LerMem <= '0';
                memParaReg <= '0'; EscMem <= '0'; ulaFonte <= '0'; EscReg <= '0';
                alu_op <= "00";

            when LW =>
                reg_dest <= '0'; jump <= '0'; DvC <= '0'; LerMem <= '1';
                memParaReg <= '0'; EscMem <= '0'; ulaFonte <= '1'; EscReg <= '1';
                alu_op <= "00";

            when SW =>
                reg_dest <= '0'; jump <= '0'; DvC <= '0'; LerMem <= '0';
                memParaReg <= '0'; EscMem <= '1'; ulaFonte <= '1'; EscReg <= '0';
                alu_op <= "00";

            when others =>
                reg_dest <= '0'; jump <= '0'; DvC <= '0'; LerMem <= '0';
                memParaReg <= '0'; EscMem <= '0'; ulaFonte <= '0'; EscReg <= '0';
                alu_op <= "00";
        end case;
    end process;
end Maquina_estados;