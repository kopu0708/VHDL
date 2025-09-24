----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/09/24 20:58:38
-- Design Name: 
-- Module Name: TB_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

entity TB_Syn_Asy is
--  Port ( );
end TB_Syn_Asy;

architecture Behavioral of TB_Syn_Asy is
    component Syn_Asy is
        Port (
            RESET : in  STD_LOGIC; CLK : in  STD_LOGIC; D : in  STD_LOGIC; T : in  STD_LOGIC;
            SR    : in  STD_LOGIC_VECTOR (1 downto 0); JK    : in  STD_LOGIC_VECTOR (1 downto 0);
            D_Q_Asy  : out STD_LOGIC; D_Q_Syn  : out STD_LOGIC; T_Q_Asy  : out STD_LOGIC; T_Q_Syn  : out STD_LOGIC;
            SR_Q_Asy : out STD_LOGIC; SR_Q_Syn : out STD_LOGIC; JK_Q_Asy : out STD_LOGIC; JK_Q_Syn : out STD_LOGIC
        );
    end component;

    -- UUT의 포트에 연결할 신호들
    signal CLK   : std_logic := '0';
    signal RESET : std_logic := '0';
    signal D     : std_logic := '0';
    signal T     : std_logic := '0';
    signal SR    : std_logic_vector(1 downto 0) := "00";
    signal JK    : std_logic_vector(1 downto 0) := "00";
    signal D_Q_Asy, D_Q_Syn, T_Q_Asy, T_Q_Syn, SR_Q_Asy, SR_Q_Syn, JK_Q_Asy, JK_Q_Syn : std_logic;

begin
    -- UUT (Unit Under Test) 인스턴스화
    UUT : Syn_Asy PORT MAP(
        RESET => RESET, CLK => CLK, D => D, T => T, SR => SR, JK => JK,
        D_Q_Asy => D_Q_Asy, D_Q_Syn => D_Q_Syn, T_Q_Asy => T_Q_Asy, T_Q_Syn => T_Q_Syn,
        SR_Q_Asy => SR_Q_Asy, SR_Q_Syn => SR_Q_Syn, JK_Q_Asy => JK_Q_Asy, JK_Q_Syn => JK_Q_Syn
    );
  CLK_PROC : process
    begin
        CLK <= '0';
        wait for 50 ns; -- 100ns 주기의 절반
        CLK <= '1';
        wait for 50 ns; -- 100ns 주기의 절반
    end process;
  RESET_PROC : process
    begin
        wait for 400ns;
        RESET <= not RESET;
        end process;
        
    D_PROC : process
    begin 
        D <= '1'; wait for 100ns;
        D <= '0'; wait for 100ns;
        D <= '1'; wait for 300ns;
    end process;
    
    T_PROC : process 
    begin 
        T <= '1'; wait for 200ns;
        T <= '0'; wait for 100ns;
    end process;
     
    SR_PROC : process   
    begin
        SR <= "10"; wait for 100ns; -- 1 되고
        SR <= "00"; wait for 100ns; -- 유지하고
        SR <= "01"; wait for 100ns; -- 초기화
        SR <= "11"; wait for 50ns; -- 금지된 입력 (동작 확인용)
        SR <= "10"; wait for 200ns; -- RESET 확인 
    end process;
     
   JK_PROC : process 
    begin 
        JK <= "10"; wait for 100ns;
        JK <= "00"; wait for 100ns;
        JK <= "01"; wait for 100ns;
        JK <= "11"; wait for 100ns;
    end process;
    
    end Behavioral;


