

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAE_control_jeu is
Port (
    clk,reset : in std_logic;
    start : in  std_logic;
    droite, gauche, haut, bas:    in std_logic;  --right, left, up, down
    
    teteH: out integer range 0 to 479; --head
    teteB: out integer range 0 to 479;
    teteG: out integer range 0 to 639;
    teteD: out integer range 0 to 639;
    
    pomH: in integer range 0 to 479;  --apple
    pomB: in integer range 0 to 479;
    pomG: in integer range 0 to 639;
    pomD: in integer range 0 to 479;
    
    nb_seg: out integer range 0 to 10;
    
    segB1: out integer range 0 to 479;
    segB2: out integer range 0 to 479;
    segB3: out integer range 0 to 479;
    segB4: out integer range 0 to 479;
    segB5: out integer range 0 to 479;
    segB6: out integer range 0 to 479;
    segB7: out integer range 0 to 479;
    segB8: out integer range 0 to 479;
    segB9: out integer range 0 to 479;
    segB10: out integer range 0 to 479;
    
    segG1: out integer range 0 to 639;
    segG2: out integer range 0 to 639;
    segG3: out integer range 0 to 639;
    segG4: out integer range 0 to 639;
    segG5: out integer range 0 to 639;
    segG6: out integer range 0 to 639;
    segG7: out integer range 0 to 639;
    segG8: out integer range 0 to 639;
    segG9: out integer range 0 to 639;
    segG10: out integer range 0 to 639;
    
    segH1: out integer range 0 to 469;
    segH2: out integer range 0 to 469;
    segH3: out integer range 0 to 469;
    segH4: out integer range 0 to 469;
    segH5: out integer range 0 to 469;
    segH6: out integer range 0 to 469;
    segH7: out integer range 0 to 469;
    segH8: out integer range 0 to 469;
    segH9: out integer range 0 to 469;
    segH10: out integer range 0 to 469;
    
    segD1: out integer range 0 to 639;
    segD2: out integer range 0 to 639;
    segD3: out integer range 0 to 639;
    segD4: out integer range 0 to 639;
    segD5: out integer range 0 to 639;
    segD6: out integer range 0 to 639;
    segD7: out integer range 0 to 639;
    segD8: out integer range 0 to 639;
    segD9: out integer range 0 to 639;
    segD10: out integer range 0 to 639;
    
    chrono, cptLose: in integer range 0 to 125000000;
    
    clkVit: out  std_logic;
    
    pause: in   std_logic
 );
end MAE_control_jeu;

architecture Behavioral of MAE_control_jeu is

-- Snake constants (initial coordianants)
    constant POSI_G: integer := 314;
    constant POSI_D: integer := POSI_G+10;
    constant POSI_H: integer := 234;
    constant POSI_B: integer := POSI_H+10;
    
-- Press directional key: signals which pass and remain at 1 when you press left, right, up, or down until the next change in direction    
    signal appuiG : std_logic := '0';
    signal appuiD : std_logic := '0';
    signal appuiH : std_logic := '0';
    signal appuiB : std_logic := '0';
    
-- Coordinates of the head of the snake
    signal teteH_s: integer range 0 to 479:= POSI_H;
    signal teteB_s: integer range 0 to 479:= POSI_B;
    signal teteG_s: integer range 0 to 639:= POSI_G;
    signal teteD_s: integer range 0 to 639:= POSI_D;
    
-- Counter for the clock controlling the speed
    signal cpt:   integer range 0 to 2500000:=0;

    
-- Clock that manages the speed of the snake
    signal clkVit_s : std_logic := '0';
    
-- Number of snake segments
    signal nb_seg_s: integer range 0 to 10 := 0;
    
-- Signal indicating a change of direction of the snake
    signal chgmt: std_logic;        

-- Coordinates of the different segments of the snake
-- Segment 1
    signal segH1_s: integer range 0 to 479;
    signal segB1_s: integer range 0 to 479;
    signal segG1_s: integer range 0 to 639;
    signal segD1_s: integer range 0 to 639;
-- Segment 2
    signal segH2_s: integer range 0 to 479;
    signal segB2_s: integer range 0 to 479;
    signal segG2_s: integer range 0 to 639;
    signal segD2_s: integer range 0 to 639;
-- Segment 3
    signal segH3_s: integer range 0 to 479;
    signal segB3_s: integer range 0 to 479;
    signal segG3_s: integer range 0 to 639;
    signal segD3_s: integer range 0 to 639;
-- Segment 4
    signal segH4_s: integer range 0 to 479;
    signal segB4_s: integer range 0 to 479;
    signal segG4_s: integer range 0 to 639;
    signal segD4_s: integer range 0 to 639;
-- Segment 5
    signal segH5_s: integer range 0 to 479;
    signal segB5_s: integer range 0 to 479;
    signal segG5_s: integer range 0 to 639;
    signal segD5_s: integer range 0 to 639;
-- Segment 6
    signal segH6_s: integer range 0 to 479;
    signal segB6_s: integer range 0 to 479;
    signal segG6_s: integer range 0 to 639;
    signal segD6_s: integer range 0 to 639;
    -- Signal 7
    signal segH7_s: integer range 0 to 479;
    signal segB7_s: integer range 0 to 479;
    signal segG7_s: integer range 0 to 639;
    signal segD7_s: integer range 0 to 639;
-- Segment 8
    signal segH8_s: integer range 0 to 479;
    signal segB8_s: integer range 0 to 479;
    signal segG8_s: integer range 0 to 639;
    signal segD8_s: integer range 0 to 639;
-- Segment 9
    signal segH9_s: integer range 0 to 479;
    signal segB9_s: integer range 0 to 479;
    signal segG9_s: integer range 0 to 639;
    signal segD9_s: integer range 0 to 639;
-- Segment 10
    signal segH10_s: integer range 0 to 479;
    signal segB10_s: integer range 0 to 479;
    signal segG10_s: integer range 0 to 639;
    signal segD10_s: integer range 0 to 639;
    
begin
--======================================--
-- Directional key press management
--======================================--
    process(clk, reset, start, droite, gauche, haut, bas, appuiD, appuiG, appuiH, appuiB) -- right left up down support
    begin
        if reset = '1'  or cptLose = 125000000 then appuiG <= '0';appuiD <= '0';appuiH <= '0';appuiB <= '0';
        elsif rising_edge(clk) then
            if start = '1' then
                if nb_seg_s = 10 then appuiG <= '0'; appuiD <= '0'; appuiH <= '0'; appuiB <= '0';
            --traitement des cas particuliers où l'ordre ne doit pas être exécuté -- Treatment of special cases where the order must not be executed
                elsif droite = '1' and appuiG = '1' then appuiG <= '1'; appuiD <= '0'; appuiH <= '0'; appuiB <= '0';
                elsif gauche = '1' and appuiD = '1' then appuiG <= '0'; appuiD <= '1'; appuiH <= '0'; appuiB <= '0';
                elsif haut = '1' and appuiB = '1' then appuiG <= '0'; appuiD <= '0'; appuiH <= '0'; appuiB <= '1';
                elsif bas = '1' and appuiH = '1' then appuiG <= '0'; appuiD <= '0'; appuiH <= '1'; appuiB <= '0';
            --on teste s'il y a appui sur une touche directionnelle et on exécute l'ordre donnée -- Test whether a directional key is pressed and execute the given order
                elsif droite = '1' then appuiG <= '0'; appuiD <= '1'; appuiH <= '0'; appuiB <= '0';
                elsif bas = '1' then appuiG <= '0'; appuiD <= '0'; appuiH <= '0'; appuiB <= '1';
                elsif gauche = '1' then appuiG <= '1'; appuiD <= '0'; appuiH <= '0'; appuiB <= '0';
                elsif haut = '1' then appuiG <= '0'; appuiD <= '0'; appuiH <= '1'; appuiB <= '0';
            --si aucune touche directionnelle n'a été enfoncé, on maintient l'ordre précédent -- If no directional key then the previous key is maintained
                elsif appuiD = '1' then appuiG <= '0'; appuiD <= '1'; appuiH <= '0'; appuiB <= '0';
                elsif appuiB = '1' then appuiG <= '0'; appuiD <= '0'; appuiH <= '0'; appuiB <= '1';
                elsif appuiG = '1' then appuiG <= '1'; appuiD <= '0'; appuiH <= '0'; appuiB <= '0';
                elsif appuiH = '1' then appuiG <= '0'; appuiD <= '0'; appuiH <= '1'; appuiB <= '0';
                end if;
            end if;
        end if;  
    end process;
    
--==================================--
-- Snake speed management
--==================================--
    process(clk,reset)
    begin
        if reset='1' then cpt <= 0;
        elsif rising_edge(clk) then
            if cpt = 2500000 then cpt <= 0; clkVit_s <= '1';
            --if cpt = 1 then cpt <= 0; clkVit_s <= '1';--pour simulation
            else cpt <= cpt+1; clkVit_s <= '0'; end if;
        end if; 
    end process;
    
--========================--
-- Snake movement
--========================--
    process(clkVit_s,reset,appuiG,appuiD,appuiH,appuiB,chgmt)
    begin
        if reset = '1' or chrono = 125000000 or cptLose = 125000000 then 
        teteH_s <= POSI_H; teteB_s <= POSI_B; teteG_s <= POSI_G; teteD_s <= POSI_D;
        segH1_s <= 0; segB1_s <= 0; segG1_s <= 0; segD1_s <= 0;
        segH2_s <= 0; segB2_s <= 0; segG2_s <= 0; segD2_s <= 0;
        segH3_s <= 0; segB3_s <= 0; segG3_s <= 0; segD3_s <= 0;
        segH4_s <= 0; segB4_s <= 0; segG4_s <= 0; segD4_s <= 0;
        segH5_s <= 0; segB5_s <= 0; segG5_s <= 0; segD5_s <= 0;
        segH6_s <= 0; segB6_s <= 0; segG6_s <= 0; segD6_s <= 0;
        segH7_s <= 0; segB7_s <= 0; segG7_s <= 0; segD7_s <= 0;
        segH8_s <= 0; segB8_s <= 0; segG8_s <= 0; segD8_s <= 0;
        segH9_s <= 0; segB9_s <= 0; segG9_s <= 0; segD9_s <= 0;
        segH10_s <= 0; segB10_s <= 0; segG10_s <= 0; segD10_s <= 0;
        
        elsif rising_edge (clkVit_s) then
            -- Head displacement
            if pause = '1' then teteG_s <= teteG_s; teteD_s <= teteD_s; teteH_s <= teteH_s; teteB_s <= teteB_s;   
            elsif appuiG='1' then --Towards the left
                -- Segment displacement
                segG1_s <= teteG_s; segD1_s <= teteD_s; segH1_s <= teteH_s; segB1_s <= teteB_s;
                segG2_s <= segG1_s; segD2_s <= segD1_s; segH2_s <= segH1_s; segB2_s <= segB1_s;
                segG3_s <= segG2_s; segD3_s <= segD2_s; segH3_s <= segH2_s; segB3_s <= segB2_s;
                segG4_s <= segG3_s; segD4_s <= segD3_s; segH4_s <= segH3_s; segB4_s <= segB3_s;
                segG5_s <= segG4_s; segD5_s <= segD4_s; segH5_s <= segH4_s; segB5_s <= segB4_s;
                segG6_s <= segG5_s; segD6_s <= segD5_s; segH6_s <= segH5_s; segB6_s <= segB5_s;
                segG7_s <= segG6_s; segD7_s <= segD6_s; segH7_s <= segH6_s; segB7_s <= segB6_s;
                segG8_s <= segG7_s; segD8_s <= segD7_s; segH8_s <= segH7_s; segB8_s <= segB7_s;
                segG9_s <= segG8_s; segD9_s <= segD8_s; segH9_s <= segH8_s; segB9_s <= segB8_s;
                segG10_s <= segG9_s; segD10_s <= segD9_s; segH10_s <= segH9_s; segB10_s <= segB9_s;
                if teteG_s - 10 < 0 then teteG_s <= 639 + teteG_s - 10; teteD_s <= teteG_s;
                else teteG_s <= teteG_s - 10; teteD_s <= teteG_s;
                end if;
            elsif appuiD = '1' then --Towards the right
                -- Displacement of segments
                segG1_s <= teteG_s; segD1_s <= teteD_s; segH1_s <= teteH_s; segB1_s <= teteB_s;
                segG2_s <= segG1_s; segD2_s <= segD1_s; segH2_s <= segH1_s; segB2_s <= segB1_s;
                segG3_s <= segG2_s; segD3_s <= segD2_s; segH3_s <= segH2_s; segB3_s <= segB2_s;
                segG4_s <= segG3_s; segD4_s <= segD3_s; segH4_s <= segH3_s; segB4_s <= segB3_s;
                segG5_s <= segG4_s; segD5_s <= segD4_s; segH5_s <= segH4_s; segB5_s <= segB4_s;
                segG6_s <= segG5_s; segD6_s <= segD5_s; segH6_s <= segH5_s; segB6_s <= segB5_s;
                segG7_s <= segG6_s; segD7_s <= segD6_s; segH7_s <= segH6_s; segB7_s <= segB6_s;
                segG8_s <= segG7_s; segD8_s <= segD7_s; segH8_s <= segH7_s; segB8_s <= segB7_s;
                segG9_s <= segG8_s; segD9_s <= segD8_s; segH9_s <= segH8_s; segB9_s <= segB8_s;
                segG10_s <= segG9_s; segD10_s <= segD9_s; segH10_s <= segH9_s; segB10_s <= segB9_s;
                if teteD_s+10 > 639 then teteD_s <= teteD_s+10-639; teteG_s <= teteD_s;
                else teteD_s <= teteD_s + 10; teteG_s <= teteD_s;
                end if;
            elsif appuiH = '1' then --Towards the top
                --Displacement of segments
                segG1_s <= teteG_s; segD1_s <= teteD_s; segH1_s <= teteH_s; segB1_s <= teteB_s;
                segG2_s <= segG1_s; segD2_s <= segD1_s; segH2_s <= segH1_s; segB2_s <= segB1_s;
                segG3_s <= segG2_s; segD3_s <= segD2_s; segH3_s <= segH2_s; segB3_s <= segB2_s;
                segG4_s <= segG3_s; segD4_s <= segD3_s; segH4_s <= segH3_s; segB4_s <= segB3_s;
                segG5_s <= segG4_s; segD5_s <= segD4_s; segH5_s <= segH4_s; segB5_s <= segB4_s;
                segG6_s <= segG5_s; segD6_s <= segD5_s; segH6_s <= segH5_s; segB6_s <= segB5_s;
                segG7_s <= segG6_s; segD7_s <= segD6_s; segH7_s <= segH6_s; segB7_s <= segB6_s;
                segG8_s <= segG7_s; segD8_s <= segD7_s; segH8_s <= segH7_s; segB8_s <= segB7_s;
                segG9_s <= segG8_s; segD9_s <= segD8_s; segH9_s <= segH8_s; segB9_s <= segB8_s;
                segG10_s <= segG9_s; segD10_s <= segD9_s; segH10_s <= segH9_s; segB10_s <= segB9_s;
                if teteH_s - 10 < 0 then teteH_s <= 479 + teteH_s - 10; teteB_s <= teteH_s;
                else teteH_s <= teteH_s - 10; teteB_s <= teteH_s;
                end if;
            elsif appuiB = '1' then --Towards the bottom
                --Displacement of segments
                segG1_s <= teteG_s; segD1_s <= teteD_s; segH1_s <= teteH_s; segB1_s <= teteB_s;
                segG2_s <= segG1_s; segD2_s <= segD1_s; segH2_s <= segH1_s; segB2_s <= segB1_s;
                segG3_s <= segG2_s; segD3_s <= segD2_s; segH3_s <= segH2_s; segB3_s <= segB2_s;
                segG4_s <= segG3_s; segD4_s <= segD3_s; segH4_s <= segH3_s; segB4_s <= segB3_s;
                segG5_s <= segG4_s; segD5_s <= segD4_s; segH5_s <= segH4_s; segB5_s <= segB4_s;
                segG6_s <= segG5_s; segD6_s <= segD5_s; segH6_s <= segH5_s; segB6_s <= segB5_s;
                segG7_s <= segG6_s; segD7_s <= segD6_s; segH7_s <= segH6_s; segB7_s <= segB6_s;
                segG8_s <= segG7_s; segD8_s <= segD7_s; segH8_s <= segH7_s; segB8_s <= segB7_s;
                segG9_s <= segG8_s; segD9_s <= segD8_s; segH9_s <= segH8_s; segB9_s <= segB8_s;
                segG10_s <= segG9_s; segD10_s <= segD9_s; segH10_s <= segH9_s; segB10_s <= segB9_s;
                if teteB_s + 10 > 479 then teteB_s <= teteB_s + 10 - 479; teteH_s <= teteB_s;
                else teteB_s <= teteB_s + 10; teteH_s <= teteB_s; 
                end if; 
            end if;
        end if;
    end process;

-- Check if head of snake is on an apple
    process(reset,clkVit_s,nb_seg_s)
    begin
        if reset = '1' or cptLose = 125000000 then nb_seg_s <= 0;
        elsif rising_edge(clkVit_s) then -- Careful to use the same clock as the one used for the movement of the snake because if you use a faster clock it can count apples multiple times 
            if nb_seg_s+1 < 11 then
            --version précise 
                --if(appuiG = '1' and (teteG_s = pomD and teteH_s = pomH))
                --or (appuiD = '1' and (teteD_s = pomG and teteH_s = pomH))
                --or (appuiH = '1' and (teteH_s = pomB and teteG_s = pomG))
                --or (appuiB = '1' and (teteB_s = pomH and teteG_s = pomG))
                --then nb_seg_s <= nb_seg_s+1; end if;
            -- version considering the eaten apple as soon as a pixel of the snake's head touches it    
                if ((pomG <= teteD_s and pomG >= teteG_s) and (pomB <= teteB_s and pomB >= teteH_s))--le coin gauche inf de la pomme est incluse dans le serpent -- the lower left corner of the apple is included in the snake 
                or ((pomG <= teteD_s and pomG >= teteG_s) and (pomH <= teteB_s and pomH >= teteH_s))--le coin gauche sup de la pomme est incluse dans le serpent -- the upper left corner of the apple is included in the snake
                or ((pomD <= teteD_s and pomD >= teteG_s) and (pomB <= teteB_s and pomB >= teteH_s))--le coin droit inf de la pomme est incluse dans le serpent -- The lower right corner of the apple is included in the snake
                or ((pomD <= teteD_s and pomD >= teteG_s) and (pomH <= teteB_s and pomH >= teteH_s))--le coin droit sup de la pomme est incluse dans le serpent -- The upper right corner of the apple is included in the snake
                then nb_seg_s <= nb_seg_s+1;
                end if;
            else nb_seg_s <= 0;
            end if;
        end if;
    end process;

-- Update snake coordinates
    teteG <= teteG_s;
    teteD <= teteD_s;
    teteH <= teteH_s;
    teteB <= teteB_s;
    
    segB1 <= segB1_s;
    segB2 <= segB2_s;
    segB3 <= segB3_s;
    segB4 <= segB4_s;
    segB5 <= segB5_s;
    segB6 <= segB6_s;
    segB7 <= segB7_s;
    segB8 <= segB8_s;
    segB9 <= segB9_s;
    segB10 <= segB10_s;
    
    segG1 <= segG1_s;
    segG2 <= segG2_s;
    segG3 <= segG3_s;
    segG4 <= segG4_s;
    segG5 <= segG5_s;
    segG6 <= segG6_s;
    segG7 <= segG7_s;
    segG8 <= segG8_s;
    segG9 <= segG9_s;
    segG10 <= segG10_s;
    
    segH1 <= segH1_s;
    segH2 <= segH2_s;
    segH3 <= segH3_s;
    segH4 <= segH4_s;
    segH5 <= segH5_s;
    segH6 <= segH6_s;
    segH7 <= segH7_s;
    segH8 <= segH8_s;
    segH9 <= segH9_s;
    segH10 <= segH10_s;
    
    segD1 <= segD1_s;
    segD2 <= segD2_s;
    segD3 <= segD3_s;
    segD4 <= segD4_s;
    segD5 <= segD5_s;
    segD6 <= segD6_s;
    segD7 <= segD7_s;
    segD8 <= segD8_s;
    segD9 <= segD9_s;
    segD10 <= segD10_s;
    
--Updated snake segment count
    nb_seg <= nb_seg_s;  

--Snake speed clock update
    clkVit <= clkVit_s;
      
end Behavioral;