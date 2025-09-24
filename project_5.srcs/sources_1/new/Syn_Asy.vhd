----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/09/23 19:41:15
-- Design Name: 
-- Module Name: Syn_Asy - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Syn_Asy is
    Port ( RESET : in STD_LOGIC;
           CLK : in STD_LOGIC;
           D : in STD_LOGIC;
           T : in STD_LOGIC;
           SR : in STD_LOGIC_VECTOR (1 downto 0);
           JK : in STD_LOGIC_VECTOR (1 downto 0);
           D_Q_Asy : out STD_LOGIC;
           D_Q_Syn : out STD_LOGIC;
           T_Q_Asy : out STD_LOGIC;
           T_Q_Syn : out STD_LOGIC;
           SR_Q_Asy : out STD_LOGIC;  -- 비동기식 리셋 JK FF 출력
           SR_Q_Syn : out STD_LOGIC;  -- 동기식 리셋 JK FF 출력
           JK_Q_Asy : out STD_LOGIC;
           JK_Q_Syn : out STD_LOGIC);
end Syn_Asy;    

architecture Behavioral of Syn_Asy is
    signal JK_q_async_sig: std_logic := '0'; -- 비동기식 리셋 JK FF 내부 출력
    signal JK_q_sync_sig : std_logic := '0'; -- 동기식 리셋 JK FF 내부 출력
    signal SR_q_async_sig: std_logic := '0';
    signal SR_q_sync_sig : std_logic := '0';
    signal T_q_async_sig : std_logic := '0';
    signal T_q_sync_sig  : std_logic := '0';
    signal D_q_async_sig : std_logic := '0';
    signal D_q_sync_sig  : std_logic := '0';
begin

    D_ASYNC_PROC : process (CLK,RESET) -- 비동기식 리셋 D FF 
    begin 
        if RESET = '1' then
            D_q_async_sig <= '0';
        elsif rising_edge(CLK) then
            D_q_async_sig <= D;
           end if;
         end process;
       D_SYNC_PROC : process (RESET,CLK)      -- 동기식 리셋 D FF
    begin
        if rising_edge(CLK) then
            if RESET = '1' then                --- RESET
                d_q_sync_sig <= '0';
            else                               --- RESET이 0이면                  
                d_q_sync_sig <= D;              ----  입력 그대로 출력  
            end if;
        end if;
    end process;   
    ----- T FF  
    T_ASYNC_PROC: process (CLK , RESET) -- 비동기식 리겟 T FF
        begin 
            if RESET = '1' then 
                T_q_async_sig <= '0';
            elsif rising_edge(CLK) then
                if T = '1' then                     
                t_q_async_sig <= not t_q_async_sig;  
                end if;
             end if;
           end process;
           
    T_SYNC_PROC: process (CLK,RESET) -- 동기식 리셋 T FF
        begin
       if rising_edge(CLK) then
            if RESET = '1' then    
                t_q_sync_sig <= '0';
                 elsif T = '1' then
                 t_q_sync_sig <= not t_q_sync_sig; 
                end if;
              end if;
          end process;
        
    ------SR FF    
    SR_ASYNC_PROC: process (CLK, RESET) --비동기식 리셋 SR FF
        begin   
            if RESET = '1' then 
                SR_q_async_sig <= '0';
             elsif rising_edge(CLK) then
                case SR is 
                    when "00" => SR_q_async_sig <= SR_q_async_sig;
                    when "01" => SR_q_async_sig <= '0'; -- 이것도 리셋임 
                    when "10" => SR_q_async_sig <=  '1'; --set 
                    when others => SR_q_async_sig <=  '0';  -- 11 이면 금지 
                    end case;
                end if;
              end process;
              
    SR_SYNC_PROC: process (CLK,RESET)--동기식 리셋 SR FF
      begin 
        if rising_edge(CLK) then    -- 동기식 리셋이라서 라이징 엣지일떄만 리셋 받으면 초기화 
            if RESET = '1' then 
                SR_q_sync_sig <= '0'; 
             else                           --- RESET이 0이면 이하 동일 
              if SR = "00" then SR_q_sync_sig <= SR_q_sync_sig; 
              elsif SR = "01" then SR_q_sync_sig <= '0';    ---  RESET 
              elsif SR = "10" then SR_q_sync_sig <= '1';    --- SET
              else SR_q_sync_sig <= '0';
              end if;
             end if;
            end if;
           end process;               
        ---- JK FF 
  JK_ASYNC_PROC: process (CLK,RESET)
    begin
        if RESET = '1' then
            jk_q_async_sig <= '0';
        elsif rising_edge(CLK) then
            case JK is
                when "00"   => JK_q_async_sig <= JK_q_async_sig;
                when "01"   => JK_q_async_sig <= '0';
                when "10"   => JK_q_async_sig <= '1';
                when others => JK_q_async_sig <= not JK_q_async_sig;
            end case;
        end if;
    end process;      
                       
    JK_SYNC_PROC : process (CLK,RESET)
    begin 
        if rising_edge(CLK) then 
        if RESET = '1' then
            JK_q_sync_sig <= '0';
        else
        case JK is
                when "00"   => JK_q_sync_sig <= JK_q_sync_sig;
                when "01"   => JK_q_sync_sig <= '0';
                when "10"   => JK_q_sync_sig <= '1';
                when others   => JK_q_sync_sig <= not JK_q_sync_sig;
            end case;
           end if;
          end if;
    end process;     
            
    D_Q_Asy  <= d_q_async_sig;
    D_Q_Syn  <= d_q_sync_sig;
    T_Q_Asy  <= t_q_async_sig;
    T_Q_Syn  <= t_q_sync_sig;
    SR_Q_Asy <= sr_q_async_sig;
    SR_Q_Syn <= sr_q_sync_sig;
    JK_Q_Asy <= jk_q_async_sig;
    JK_Q_Syn <= jk_q_sync_sig;
    
end Behavioral;
