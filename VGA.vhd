library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity VGA is
port(
	R,G,B:		out	std_logic_vector (3 downto 0);
	HSync:	    out	std_logic := '1';
	VSync:	    out	std_logic := '1';
	clk,reset:	in	std_logic;
	cmd:		in	std_logic_vector(5 downto 0);
	play:       in std_logic;
	droite:     in std_logic;
	gauche:     in std_logic;
	haut:       in std_logic;
	bas:        in std_logic;
	pause:      in  std_logic;
	led15,led14,led5,led4,led3,led2,led1,led0: out std_logic
	);
end VGA;

architecture behavioral of VGA is
--==========--
-- CONSTANT --
--==========--
    -- Constants for display
    constant TS_H : integer := 799; -- 799 # of pixels per line
    constant TDISP_H : integer := 639;  --  639   Horizontal Display (640)
	constant TFP_H : integer := 21;         --   16   Right border (front porch)
	constant TPW_H : integer := 96;       --   96   Sync pulse (Retrace)
	constant TBP_H : integer := 48;        --   48   Left boarder (back porch)
	
	constant TS_V: integer := 520; -- 520 # of pixels per column
	constant TDISP_V : integer := 479;   --  479   Vertical Display (480)
	constant TFP_V : integer := 5;       	 --   10   Right border (front porch)
	constant TPW_V : integer := 2;				 --    2   Sync pulse (Retrace)
	constant TBP_V : integer := 29;       --   29   Left boarder (back porch)
	
	-- Constants for obstacles
	constant BORD: integer := 1; -- Obstacle edge size
	-- Top Island
	--constant LIM_G1: integer := 214; -- Left limit of the obstacle
	--constant LIM_D1: integer := LIM_G1+206; --Right limit of the obsacle
	--constant LIM_H1: integer := 33; -- Upper limit of the obstacle
    --constant LIM_B1: integer := LIM_H1+10; -- Lower limit of the obstacle
    -- Bottom Island
    --constant LIM_G2: integer := 214; -- Left limit of the obstacle
	--constant LIM_D2: integer := LIM_G2+206; -- Right limit of the obstacle
	--constant LIM_H2: integer := 435; -- Upper limit of the obstacle
    --constant LIM_B2: integer := LIM_H2+10; -- Lower limit of the obstacle
    -- Left Island
  --  constant LIM_G3: integer := 63; -- Left limit of the obstacle
--	constant LIM_D3: integer := LIM_G3+10; -- Right limit of the obstacle
--	constant LIM_H3: integer := 135; -- Upper limit of the obstacle
 --   constant LIM_B3: integer := LIM_H3+208; -- Lower limit of the obstacle
    -- Right Island
   -- constant LIM_G4: integer := 565; -- Left limit of the obstacle
	--constant LIM_D4: integer := LIM_G4+10; -- Right limit of the obstacle
	--constant LIM_H4: integer := 135; -- Upper limit of the obstacle
    --constant LIM_B4: integer := LIM_H4+208; -- Lower limit of the obstacle
    
    constant LIM_G5: integer := 11; -- Left limit of the obstacle
	constant LIM_D5: integer := LIM_G5+206; -- Right limit of the obstacle
	constant LIM_H5: integer := 11; -- Upper limit of the obstacle
    constant LIM_B5: integer := LIM_H5+10; -- Lower limit of the obstacle
    
    constant LIM_G6: integer := 421; -- Left limit of the obstacle
	constant LIM_D6: integer := LIM_G6+206; -- Right limit of the obstacle
	constant LIM_H6: integer := 11; -- Upper limit of the obstacle
    constant LIM_B6: integer := LIM_H6+10; -- Lower limit of the obstacle
    -- Lower Left to Lower Right
    constant LIM_G7: integer := 11; -- Left limit of the obstacle
	constant LIM_D7: integer := LIM_G7+206; -- Right limit of the obstacle
	constant LIM_H7: integer := 458; -- Upper limit of the obstacle
    constant LIM_B7: integer := LIM_H7+10; -- Lower limit of the obstacle
    -- Lower Right to lower left
    constant LIM_G8: integer := 421; -- Left limit of the obstacle -- 421
	constant LIM_D8: integer := LIM_G8+206; -- Right limit of the obstacle
	constant LIM_H8: integer := 458; -- Upper limit of the obstacle
    constant LIM_B8: integer := LIM_H8+10; -- Lower limit of the obstacle
    -- Uper left to lower left
    --constant LIM_G9: integer := 11; -- Left limit of the obstacle
	--constant LIM_D9: integer := LIM_G9+10; -- Right limit of the obstacle
	--constant LIM_H9: integer := 21; -- Upper limit of the obstacle
   -- constant LIM_B9: integer := LIM_H9+195; -- Lower limit of the obstacle
   
    -- Lower left to upper left (Changed to whole left)
    constant LIM_G10: integer := 11; -- Left limit of the obstacle
	constant LIM_D10: integer := LIM_G10+10; -- Right limit of the obstacle
	constant LIM_H10: integer := 21; -- Upper limit of the obstacle ; 263
    constant LIM_B10: integer := 458; -- Lower limit of the obstacle ; LIM_H10+195
    -- Lower right to top right (Changed to whole right)
    constant LIM_G11: integer := 617; -- Left limit of the obstacle
	constant LIM_D11: integer := LIM_G11+10; -- Right limit of the obstacle
	constant LIM_H11: integer := 21; -- Upper limit of the obstacle -- 263
    constant LIM_B11: integer := 458; -- Lower limit of the obstacle --LIM_H11+195
    --Top Right to Lower Right
   -- constant LIM_G12: integer := 617; -- Left limit of the obstacle
	--constant LIM_D12: integer := LIM_G12+10; -- Right limit of the obstacle
	--constant LIM_H12: integer := 21; -- Upper limit of the obstacle
    --constant LIM_B12: integer := LIM_H12+195; -- Lower limit of the obstacle
    
        
    -- Snake Constants
    constant POSI_G: integer := 314;
    constant POSI_D: integer := POSI_G+10;
    constant POSI_H: integer := 234;
    constant POSI_B: integer := POSI_H+10; 
--========--
-- SIGNAL --
--========--
	signal clk25_s:    std_logic := '0'; -- 25MHz Clock
	
	--Current Pixel Coordinates
	signal hcord:  integer range 0 to TS_H := 0; -- horizontal coordinates
	signal vcord:  integer range 0 to TS_V := 0; -- vertical coordinates
	
	signal visible: std_logic; -- Signal indicating that the current pixel is in the visible area
	
	-- Buffered VGA signals
	signal R_s,G_s,B_s: std_logic_vector(3 downto 0);
    
     -- Snake head coordinates
    signal teteH_s: integer range 0 to 469;
    signal teteB_s: integer range 9 to 479;
    signal teteG_s: integer range 0 to 629;
    signal teteD_s: integer range 9 to 639;
    
    -- Apple coordinates
    signal pomD_s:   integer range 0 to 639;
    signal pomG_s:   integer range 0 to 639;
    signal pomH_s:   integer range 0 to 479;
    signal pomB_s:   integer range 0 to 479;
    
    signal win_s:    std_logic; -- Signal indicating that all 10 apples have been eaten
    
    signal nb_seg_s:  integer range 0 to 10;-- Number of snake segments
    
    signal chrono_s: integer range 0 to 125000000; -- Counter for the display of the victory screen
    
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

-- Signal changing to 1 in case of colision of the snake with one of the obstacles or itself
    signal lose_s: std_logic; 
    
-- Clock controlling the speed of the snake 
    signal clkVit_s: std_logic;

-- Counter to control the display time of the loss screen
    signal cptLose_s: integer range 0 to 125000000;   

-- Signal controlling the display of the pause screen
    signal  pause_s: std_logic;

-- Signal for flashing leds
    signal cptLed: integer range 0 to 120000000; 
    signal clkLed: std_logic;
                
begin

-- We use a 100MHz clock or we need a 25MHz signal so we divide the clock by 4
--=====================--
--  Clock divider --
--=====================--
    ClkDiv: entity work.clk25
            port map(
                clk => clk,
                reset => reset,
                clk25 => clk25_s);

--====================--
-- Pixel counter --
--====================--
    process(clk25_s,reset)
    begin
    if reset = '1' then hcord <= 0; vcord <= 0;
    elsif rising_edge(clk25_s) then
        -- We go to the next horizontal pixel if it is not the last of the line
        if hcord < TS_H then hcord <= hcord+1;
        -- Otherwise we check that we are not on the last line
        elsif vcord < TS_V then 
        -- Next line
        vcord <= vcord+1;
        -- First horizontal pixel of the line
        hcord <= 0;
        -- Otherwise we go to pixel 0,0 of the screen
        else vcord <= 0; hcord <= 0;
        end if;       
    end if;
    end process;

--===========================================--
-- SYNCHRONIZATION SIGNALS --
--===========================================--
    process(clk25_s,reset)
    begin
    if reset='1' then HSync <= '1'; VSync <= '1';
    elsif rising_edge(clk25_s) then
        if hcord > TDISP_H+TFP_H and hcord <= TDISP_H+TFP_H+TPW_H then HSync <= '0'; else HSync <= '1';end if;
        if vcord > TDISP_V+TFP_V and vcord <= TDISP_V+TFP_V+TPW_V then VSync <= '0'; else VSync <= '1';end if;
    end if;
    end process;

--==================================--
-- SIGNAL COMMAND GENERATION --
--==================================--
    process(clk25_s,reset)
    begin
    if reset = '1' then visible <='0';
    elsif rising_edge(clk25_s) then
        if hcord <=TDISP_H and vcord <=TDISP_V then visible <= '1'; else visible <= '0'; end if;
    end if;
    end process;

--==============================--
-- COLOR MANAGEMENT --
--==============================--
    process(clk25_s,reset,visible)
    begin
    if reset='1' then R_s<="0000"; G_s<="0000"; B_s<="0000";
    elsif rising_edge(clk25_s) then
        if visible = '1' then 
            if cmd(1 downto 0)="00" then R_s <= "0001";
            elsif cmd(1 downto 0)="01" then R_s <= "0011";
            elsif cmd(1 downto 0)="10" then R_s <= "0111";
            elsif cmd(1 downto 0)="11" then R_s <= "1111";
            else R_s <= "0000"; 
            end if;
            
            if cmd(3 downto 2)="00" then G_s <= "0001";
            elsif cmd(3 downto 2)="01" then G_s <= "0011";
            elsif cmd(3 downto 2)="10" then G_s <= "0111";
            elsif cmd(3 downto 2)="11" then G_s <= "1111";
            else G_s <= "0000"; 
            end if;
            
            if cmd(5 downto 4)="00" then B_s <= "0001";
            elsif cmd(5 downto 4)="01" then B_s <= "0011";
            elsif cmd(5 downto 4)="10" then B_s <= "0111";
            elsif cmd(5 downto 4)="11" then B_s <= "1111";
            else B_s <= "0000"; 
            end if;
        else R_s<="0000"; G_s<="0000"; B_s<="0000"; 
        end if;
    end if;
    end process;

--===============================================--
-- INSTANCING SNAKE CONTROL --
--===============================================--
ControlSerpent:  entity work.MAE_control_jeu
                port map (
                clk => clk25_s,
                reset => reset,
                start => play,
                droite => droite, 
                gauche => gauche, 
                haut => haut, 
                bas => bas,
                
                teteH => teteH_s,
                teteB => teteB_s,
                teteG => teteG_s,
                teteD => teteD_s,
                
                pomD => pomD_s,
                pomG    => pomG_s,
                pomH    => pomH_s,
                pomB    => pomB_s,
                
                nb_seg => nb_seg_s,
                
                chrono => chrono_s,
                
                segB1 => segB1_s,
                segB2 => segB2_s,
                segB3 => segB3_s,
                segB4 => segB4_s,
                segB5 => segB5_s,
                segB6 => segB6_s,
                segB7 => segB7_s,
                segB8 => segB8_s,
                segB9 => segB9_s,
                segB10 => segB10_s,
                
                segG1 => segG1_s,
                segG2 => segG2_s,
                segG3 => segG3_s,
                segG4 => segG4_s,
                segG5 => segG5_s,
                segG6 => segG6_s,
                segG7 => segG7_s,
                segG8 => segG8_s,
                segG9 => segG9_s,
                segG10 => segG10_s,
                
                segH1 => segH1_s,
                segH2 => segH2_s,
                segH3 => segH3_s,
                segH4 => segH4_s,
                segH5 => segH5_s,
                segH6 => segH6_s,
                segH7 => segH7_s,
                segH8 => segH8_s,
                segH9 => segH9_s,
                segH10 => segH10_s,
                
                segD1 => segD1_s,
                segD2 => segD2_s,
                segD3 => segD3_s,
                segD4 => segD4_s,
                segD5 => segD5_s,
                segD6 => segD6_s,
                segD7 => segD7_s,
                segD8 => segD8_s,
                segD9 => segD9_s,
                segD10 => segD10_s,
                
                clkVit => clkVit_s,
                
                cptLose => cptLose_s, 
                
                pause => pause_s
            );

--===============================================================--
-- INSTANCING THE APPLE DISPLAY CONTROL MODULE --
--===============================================================--
ControlPomme:   entity work.pomme(behavioral)
                    port map(
                        reset   => reset, 
                        clk25   => clk25_s,
                        nb_seg  => nb_seg_s,
                        pomD    => pomD_s,
                        pomG    => pomG_s,
                        pomH    => pomH_s,
                        pomB    => pomB_s,
                        win    => win_s, 
                        chrono => chrono_s
                    );

--========================================--
-- INSTANCING THE COLLISION DETECTOR --
--========================================--
CollisionDetector:  entity work.collision(behavioral)
                    port map(
                        teteH => teteH_s,
                        teteB => teteB_s,
                        teteG => teteG_s,
                        teteD => teteD_s,
                        segB1 => segB1_s,
                        segB2 => segB2_s,
                        segB3 => segB3_s,
                        segB4 => segB4_s,
                        segB5 => segB5_s,
                        segB6 => segB6_s,
                        segB7 => segB7_s,
                        segB8 => segB8_s,
                        segB9 => segB9_s,
                        segB10 => segB10_s,
                        
                        segG1 => segG1_s,
                        segG2 => segG2_s,
                        segG3 => segG3_s,
                        segG4 => segG4_s,
                        segG5 => segG5_s,
                        segG6 => segG6_s,
                        segG7 => segG7_s,
                        segG8 => segG8_s,
                        segG9 => segG9_s,
                        segG10 => segG10_s,
                        
                        segH1 => segH1_s,
                        segH2 => segH2_s,
                        segH3 => segH3_s,
                        segH4 => segH4_s,
                        segH5 => segH5_s,
                        segH6 => segH6_s,
                        segH7 => segH7_s,
                        segH8 => segH8_s,
                        segH9 => segH9_s,
                        segH10 => segH10_s,
                        
                        segD1 => segD1_s,
                        segD2 => segD2_s,
                        segD3 => segD3_s,
                        segD4 => segD4_s,
                        segD5 => segD5_s,
                        segD6 => segD6_s,
                        segD7 => segD7_s,
                        segD8 => segD8_s,
                        segD9 => segD9_s,
                        segD10 => segD10_s,
                        
                        clkVit => clkVit_s,
                        reset   => reset, 
                        clk25   => clk25_s,
                        lose => lose_s,
                        cpt => cptLose_s
                    );

--==============================--
-- OBSTACLE AND SNAKE DISPLAY --
--==============================--
    process(clk25_s,reset,play,hcord,vcord,win_s,nb_seg_s)
    begin
        if reset='1' then R<="0000"; G<="0000"; B<="0000";
        -- victory screen display
        elsif visible = '1' and win_s = '1' then
        -- letter display
            -- Left branch y display
            if ((hcord >= 249 and hcord < 249+10) and (vcord >= 169 and vcord < 169+2))
            or ((hcord >= 249+1 and hcord < 249+10+1) and (vcord >= 169+2 and vcord < 169+2+2)) 
            or ((hcord >= 249+2 and hcord < 249+10+2) and (vcord >= 169+4 and vcord < 169+2+4)) 
            or ((hcord >= 249+3 and hcord < 249+10+3) and (vcord >= 169+6 and vcord < 169+2+6)) 
            or ((hcord >= 249+4 and hcord < 249+10+4) and (vcord >= 169+8 and vcord < 169+2+8)) 
            or ((hcord >= 249+5 and hcord < 249+10+5) and (vcord >= 169+10 and vcord < 169+2+10)) 
            or ((hcord >= 249+6 and hcord < 249+10+6) and (vcord >= 169+12 and vcord < 169+2+12)) 
            or ((hcord >= 249+7 and hcord < 249+10+7) and (vcord >= 169+14 and vcord < 169+2+14)) 
            or ((hcord >= 249+8 and hcord < 249+10+8) and (vcord >= 169+16 and vcord < 169+2+16)) 
            or ((hcord >= 249+9 and hcord < 249+10+9) and (vcord >= 169+18 and vcord < 169+2+18))
            or ((hcord >= 249+10 and hcord < 249+10+10) and (vcord >= 169+20 and vcord < 169+2+20))
            or ((hcord >= 249+11 and hcord < 249+10+11) and (vcord >= 169+22 and vcord < 169+2+22))
            or ((hcord >= 249+12 and hcord < 249+10+12) and (vcord >= 169+24 and vcord < 169+2+24))
            or ((hcord >= 249+13 and hcord < 249+10+13) and (vcord >= 169+26 and vcord < 169+2+26))
            or ((hcord >= 249+14 and hcord < 249+10+14) and (vcord >= 169+28 and vcord < 169+2+18))
            --Right hand y display
            or ((hcord >= 249+30 and hcord < 249+30+10) and (vcord >= 169 and vcord < 169+2))
            or ((hcord >= 249+30-1 and hcord < 249+30+10-1) and (vcord >= 169+2 and vcord < 169+2+2)) 
            or ((hcord >= 249+30-2 and hcord < 249+30+10-2) and (vcord >= 169+4 and vcord < 169+2+4)) 
            or ((hcord >= 249+30-3 and hcord < 249+30+10-3) and (vcord >= 169+6 and vcord < 169+2+6)) 
            or ((hcord >= 249+30-4 and hcord < 249+30+10-4) and (vcord >= 169+8 and vcord < 169+2+8)) 
            or ((hcord >= 249+30-5 and hcord < 249+30+10-5) and (vcord >= 169+10 and vcord < 169+2+10)) 
            or ((hcord >= 249+30-6 and hcord < 249+30+10-6) and (vcord >= 169+12 and vcord < 169+2+12)) 
            or ((hcord >= 249+30-7 and hcord < 249+30+10-7) and (vcord >= 169+14 and vcord < 169+2+14)) 
            or ((hcord >= 249+30-8 and hcord < 249+30+10-8) and (vcord >= 169+16 and vcord < 169+2+16)) 
            or ((hcord >= 249+30-9 and hcord < 249+30+10-9) and (vcord >= 169+18 and vcord < 169+2+18))
            or ((hcord >= 249+30-10 and hcord < 249+30+10-10) and (vcord >= 169+20 and vcord < 169+2+20))
            or ((hcord >= 249+30-11 and hcord < 249+30+10-11) and (vcord >= 169+22 and vcord < 169+2+22))
            or ((hcord >= 249+30-12 and hcord < 249+30+10-12) and (vcord >= 169+24 and vcord < 169+2+24))
            or ((hcord >= 249+30-13 and hcord < 249+30+10-13) and (vcord >= 169+26 and vcord < 169+2+26))
            or ((hcord >= 249+30-14 and hcord < 249+30+10-14) and (vcord >= 169+28 and vcord < 169+2+18)) 
            --Vertical branch y display
            or ((hcord >= 249+15 and hcord < 249+15+10) and (vcord >= 169+20 and vcord < 169+60)) 
            
            -- Display of upper O bar 
            or ((hcord >= 309 and hcord < 309+20) and (vcord >= 169 and vcord < 169+10)) 
            -- Display of lower O bar 
            or ((hcord >= 309 and hcord < 309+20) and (vcord >= 169+50 and vcord < 169+10+50)) 
            -- Display of left O bar 
            or ((hcord >= 299 and hcord < 299+10) and (vcord >= 179 and vcord < 179+40)) 
            -- Display of right O bar 
            or ((hcord >= 299+30 and hcord < 299+10+30) and (vcord >= 179 and vcord < 179+40)) 
            
            -- Display of Left U bar 
            or ((hcord >= 349 and hcord < 349+10) and (vcord >= 169 and vcord < 169+50)) 
            -- Display of Right U bar 
            or ((hcord >= 349+30 and hcord < 349+10+30) and (vcord >= 169 and vcord < 169+50)) 
            --Display of Lower U bar 
            or ((hcord >= 349+10 and hcord < 349+10+20) and (vcord >= 169+50 and vcord < 169+50+10)) 
            
            --Display of left W bar
            or ((hcord >= 249 and hcord < 249+10) and (vcord >= 249 and vcord < 249+4))
            or ((hcord >= 249+1 and hcord < 249+10+1) and (vcord >= 249+4 and vcord < 249+8))
            or ((hcord >= 249+2 and hcord < 249+10+2) and (vcord >= 249+8 and vcord < 249+12))
            or ((hcord >= 249+3 and hcord < 249+10+3) and (vcord >= 249+12 and vcord < 249+16))
            or ((hcord >= 249+4 and hcord < 249+10+4) and (vcord >= 249+16 and vcord < 249+20))
            or ((hcord >= 249+5 and hcord < 249+10+5) and (vcord >= 249+20 and vcord < 249+24))
            or ((hcord >= 249+6 and hcord < 249+10+6) and (vcord >= 249+24 and vcord < 249+28))
            or ((hcord >= 249+7 and hcord < 249+10+7) and (vcord >= 249+28 and vcord < 249+32))
            or ((hcord >= 249+8 and hcord < 249+10+8) and (vcord >= 249+32 and vcord < 249+36))
            or ((hcord >= 249+9 and hcord < 249+10+9) and (vcord >= 249+36 and vcord < 249+40))
            or ((hcord >= 249+10 and hcord < 249+10+10) and (vcord >= 249+40 and vcord < 249+44))
            or ((hcord >= 249+11 and hcord < 249+10+11) and (vcord >= 249+44 and vcord < 249+48))
            or ((hcord >= 249+12 and hcord < 249+10+12) and (vcord >= 249+48 and vcord < 249+52))
            or ((hcord >= 249+13 and hcord < 249+10+13) and (vcord >= 249+52 and vcord < 249+56))
            or ((hcord >= 249+14 and hcord < 249+10+14) and (vcord >= 249+56 and vcord < 249+60))
            -- Display of central W bar
            or ((hcord >= 249+10+14 and hcord < 249+10+14+2) and (vcord >= 249+60-4 and vcord < 249+60)) 
            or ((hcord >= 249+10+14+2 and hcord < 249+10+14+4) and (vcord >= 249+60-8 and vcord < 249+60-4)) 
            or ((hcord >= 249+10+14+4 and hcord < 249+10+14+8) and (vcord >= 249+60-12 and vcord < 249+60-8)) 
            -- Display of Left W bar
            or ((hcord >= 249+10+14+8 and hcord < 249+10+14+10) and (vcord >= 249+60-12 and vcord < 249+60-8)) 
            or ((hcord >= 249+10+14+10 and hcord < 249+10+14+12) and (vcord >= 249+60-8 and vcord < 249+60-4)) 
            or ((hcord >= 249+10+14+12 and hcord < 249+10+14+14) and (vcord >= 249+60-4 and vcord < 249+60))
            --Display of Right W bar
            or ((hcord >= 287 and hcord < 287+10) and (vcord >= 249+56 and vcord < 249+60))
            or ((hcord >= 287+1 and hcord < 287+10+1) and (vcord >= 249+52 and vcord < 249+56))
            or ((hcord >= 287+2 and hcord < 287+10+2) and (vcord >= 249+48 and vcord < 249+52))
            or ((hcord >= 287+3 and hcord < 287+10+3) and (vcord >= 249+44 and vcord < 249+48))
            or ((hcord >= 287+4 and hcord < 287+10+4) and (vcord >= 249+40 and vcord < 249+44))
            or ((hcord >= 287+5 and hcord < 287+10+5) and (vcord >= 249+36 and vcord < 249+40))
            or ((hcord >= 287+6 and hcord < 287+10+6) and (vcord >= 249+32 and vcord < 249+36))
            or ((hcord >= 287+7 and hcord < 287+10+7) and (vcord >= 249+28 and vcord < 249+32))
            or ((hcord >= 287+8 and hcord < 287+10+8) and (vcord >= 249+24 and vcord < 249+28))
            or ((hcord >= 287+9 and hcord < 287+10+9) and (vcord >= 249+20 and vcord < 249+24))
            or ((hcord >= 287+10 and hcord < 287+10+10) and (vcord >= 249+16 and vcord < 249+20))
            or ((hcord >= 287+11 and hcord < 287+10+11) and (vcord >= 249+12 and vcord < 249+16))
            or ((hcord >= 287+12 and hcord < 287+10+12) and (vcord >= 249+8 and vcord < 249+12))
            or ((hcord >= 287+13 and hcord < 287+10+13) and (vcord >= 249+4 and vcord < 249+8))
            or ((hcord >= 287+14 and hcord < 287+10+14) and (vcord >= 249 and vcord < 249+4))
            
            -- I point display
            or ((hcord >= 321 and hcord < 321+10) and (vcord >= 249 and vcord < 249+10))
            -- I body display
            or ((hcord >= 321 and hcord < 321+10) and (vcord >= 249+20 and vcord < 249+60))
            
            -- N left bar display
            or ((hcord >= 347 and hcord < 347+10) and (vcord >= 249 and vcord < 249+60))
            -- N right bar display
            or ((hcord >= 347+30 and hcord < 347+30+10) and (vcord >= 249 and vcord < 249+60))
            -- display of N slash
            or ((hcord >= 347+5 and hcord < 347+15) and (vcord >= 249 and vcord < 249+3))
            or ((hcord >= 347+5+1 and hcord < 347+15+1) and (vcord >= 249+3 and vcord < 249+3+6))
            or ((hcord >= 347+5+2 and hcord < 347+15+2) and (vcord >= 249+6 and vcord < 249+3+9))
            or ((hcord >= 347+5+3 and hcord < 347+15+3) and (vcord >= 249+9 and vcord < 249+3+12))
            or ((hcord >= 347+5+4 and hcord < 347+15+4) and (vcord >= 249+12 and vcord < 249+3+15))
            or ((hcord >= 347+5+5 and hcord < 347+15+5) and (vcord >= 249+15 and vcord < 249+3+18))
            or ((hcord >= 347+5+6 and hcord < 347+15+6) and (vcord >= 249+18 and vcord < 249+3+21))
            or ((hcord >= 347+5+7 and hcord < 347+15+7) and (vcord >= 249+21 and vcord < 249+3+24))
            or ((hcord >= 347+5+8 and hcord < 347+15+8) and (vcord >= 249+24 and vcord < 249+3+27))
            or ((hcord >= 347+5+9 and hcord < 347+15+9) and (vcord >= 249+27 and vcord < 249+3+30))
            or ((hcord >= 347+5+10 and hcord < 347+15+10) and (vcord >= 249+30 and vcord < 249+3+33))
            or ((hcord >= 347+5+11 and hcord < 347+15+11) and (vcord >= 249+33 and vcord < 249+3+36))
            or ((hcord >= 347+5+12 and hcord < 347+15+12) and (vcord >= 249+36 and vcord < 249+3+39))
            or ((hcord >= 347+5+13 and hcord < 347+15+13) and (vcord >= 249+39 and vcord < 249+3+42))
            or ((hcord >= 347+5+14 and hcord < 347+15+14) and (vcord >= 249+42 and vcord < 249+3+45))
            or ((hcord >= 347+5+15 and hcord < 347+15+15) and (vcord >= 249+45 and vcord < 249+3+48))
            or ((hcord >= 347+5+16 and hcord < 347+15+16) and (vcord >= 249+48 and vcord < 249+3+51))
            or ((hcord >= 347+5+17 and hcord < 347+15+17) and (vcord >= 249+51 and vcord < 249+3+54))
            or ((hcord >= 347+5+18 and hcord < 347+15+18) and (vcord >= 249+53 and vcord < 249+3+57))
            then R <= "1111";G <= "1111";B <= "0011";
        -- bottom display
            else R <= "0000"; G <= "1111"; B <= "0000";
            end if;
        
        -- Loss screen display
        elsif visible ='1' and lose_s = '1' then
        -- letter display
            -- Left branch Y display
            if ((hcord >= 249 and hcord < 249+10) and (vcord >= 169 and vcord < 169+2))
            or ((hcord >= 249+1 and hcord < 249+10+1) and (vcord >= 169+2 and vcord < 169+2+2)) 
            or ((hcord >= 249+2 and hcord < 249+10+2) and (vcord >= 169+4 and vcord < 169+2+4)) 
            or ((hcord >= 249+3 and hcord < 249+10+3) and (vcord >= 169+6 and vcord < 169+2+6)) 
            or ((hcord >= 249+4 and hcord < 249+10+4) and (vcord >= 169+8 and vcord < 169+2+8)) 
            or ((hcord >= 249+5 and hcord < 249+10+5) and (vcord >= 169+10 and vcord < 169+2+10)) 
            or ((hcord >= 249+6 and hcord < 249+10+6) and (vcord >= 169+12 and vcord < 169+2+12)) 
            or ((hcord >= 249+7 and hcord < 249+10+7) and (vcord >= 169+14 and vcord < 169+2+14)) 
            or ((hcord >= 249+8 and hcord < 249+10+8) and (vcord >= 169+16 and vcord < 169+2+16)) 
            or ((hcord >= 249+9 and hcord < 249+10+9) and (vcord >= 169+18 and vcord < 169+2+18))
            or ((hcord >= 249+10 and hcord < 249+10+10) and (vcord >= 169+20 and vcord < 169+2+20))
            or ((hcord >= 249+11 and hcord < 249+10+11) and (vcord >= 169+22 and vcord < 169+2+22))
            or ((hcord >= 249+12 and hcord < 249+10+12) and (vcord >= 169+24 and vcord < 169+2+24))
            or ((hcord >= 249+13 and hcord < 249+10+13) and (vcord >= 169+26 and vcord < 169+2+26))
            or ((hcord >= 249+14 and hcord < 249+10+14) and (vcord >= 169+28 and vcord < 169+2+18))
            -- Right branch Y display
            or ((hcord >= 249+30 and hcord < 249+30+10) and (vcord >= 169 and vcord < 169+2))
            or ((hcord >= 249+30-1 and hcord < 249+30+10-1) and (vcord >= 169+2 and vcord < 169+2+2)) 
            or ((hcord >= 249+30-2 and hcord < 249+30+10-2) and (vcord >= 169+4 and vcord < 169+2+4)) 
            or ((hcord >= 249+30-3 and hcord < 249+30+10-3) and (vcord >= 169+6 and vcord < 169+2+6)) 
            or ((hcord >= 249+30-4 and hcord < 249+30+10-4) and (vcord >= 169+8 and vcord < 169+2+8)) 
            or ((hcord >= 249+30-5 and hcord < 249+30+10-5) and (vcord >= 169+10 and vcord < 169+2+10)) 
            or ((hcord >= 249+30-6 and hcord < 249+30+10-6) and (vcord >= 169+12 and vcord < 169+2+12)) 
            or ((hcord >= 249+30-7 and hcord < 249+30+10-7) and (vcord >= 169+14 and vcord < 169+2+14)) 
            or ((hcord >= 249+30-8 and hcord < 249+30+10-8) and (vcord >= 169+16 and vcord < 169+2+16)) 
            or ((hcord >= 249+30-9 and hcord < 249+30+10-9) and (vcord >= 169+18 and vcord < 169+2+18))
            or ((hcord >= 249+30-10 and hcord < 249+30+10-10) and (vcord >= 169+20 and vcord < 169+2+20))
            or ((hcord >= 249+30-11 and hcord < 249+30+10-11) and (vcord >= 169+22 and vcord < 169+2+22))
            or ((hcord >= 249+30-12 and hcord < 249+30+10-12) and (vcord >= 169+24 and vcord < 169+2+24))
            or ((hcord >= 249+30-13 and hcord < 249+30+10-13) and (vcord >= 169+26 and vcord < 169+2+26))
            or ((hcord >= 249+30-14 and hcord < 249+30+10-14) and (vcord >= 169+28 and vcord < 169+2+18)) 
            -- Y branch vertical display
            or ((hcord >= 249+15 and hcord < 249+15+10) and (vcord >= 169+20 and vcord < 169+60)) 
            
            -- display of 0 bar above
            or ((hcord >= 309 and hcord < 309+20) and (vcord >= 169 and vcord < 169+10)) 
            -- Display of 0 lower bar
            or ((hcord >= 309 and hcord < 309+20) and (vcord >= 169+50 and vcord < 169+10+50)) 
            -- 0 bar left display
            or ((hcord >= 299 and hcord < 299+10) and (vcord >= 179 and vcord < 179+40)) 
            -- 0 bar right display
            or ((hcord >= 299+30 and hcord < 299+10+30) and (vcord >= 179 and vcord < 179+40)) 
            
            -- U bar left display
            or ((hcord >= 349 and hcord < 349+10) and (vcord >= 169 and vcord < 169+50)) 
            -- U bar right display
            or ((hcord >= 349+30 and hcord < 349+10+30) and (vcord >= 169 and vcord < 169+50)) 
            -- U bar lower display
            or ((hcord >= 349+10 and hcord < 349+10+20) and (vcord >= 169+50 and vcord < 169+50+10)) 
            
            -- L barre left display
            or ((hcord >= 219 and hcord < 219+10) and (vcord >= 249 and vcord < 249+50))
            -- L bar lower display
            or ((hcord >= 219+10 and hcord < 219+40) and (vcord >= 249+50 and vcord < 249+60))
            
            -- O bar upper display
            or ((hcord >= 219+60 and hcord < 219+60+20) and (vcord >= 249 and vcord < 249+10))
            -- O bar lower display
            or ((hcord >= 219+60 and hcord < 219+60+20) and (vcord >= 249+50 and vcord < 249+60))
            -- O bar left display
            or ((hcord >= 219+50 and hcord < 219+50+10) and (vcord >= 249+10 and vcord < 249+10+40))
            -- O bar right display
            or ((hcord >= 219+50+30 and hcord < 219+50+30+10) and (vcord >= 249+10 and vcord < 249+10+40))
            
            -- S bar upper display
            or ((hcord >= 219+100+10 and hcord < 219+100+10+20) and (vcord >= 249 and vcord < 249+10))
            -- S bar environment display
            or ((hcord >= 219+100+10 and hcord < 219+100+10+20) and (vcord >= 249+25 and vcord < 249+10+25))
            -- S bar lower display
            or ((hcord >= 219+100+10 and hcord < 219+100+10+20) and (vcord >= 249+50 and vcord < 249+10+50))
            -- S bar left display
            or ((hcord >= 219+100 and hcord < 219+100+10) and (vcord >= 249+10 and vcord < 249+10+15))
            -- S bar right display
            or ((hcord >= 219+100+30 and hcord < 219+100+40) and (vcord >= 249+35 and vcord < 249+35+15))
            
            -- E bar upper display
            or ((hcord >= 219+150+10 and hcord < 219+150+10+30) and (vcord >= 249 and vcord < 249+10))
            -- E bar environment display
            or ((hcord >= 219+150+10 and hcord < 219+150+10+30) and (vcord >= 249+25 and vcord < 249+10+25))
            -- E bar lower display
            or ((hcord >= 219+150+10 and hcord < 219+150+10+30) and (vcord >= 249+50 and vcord < 249+10+50))
            -- E bar upper left display
            or ((hcord >= 219+150 and hcord < 219+150+10) and (vcord >= 249+10 and vcord < 249+10+15))
            -- E bar lower left display
            or ((hcord >= 219+150 and hcord < 219+150+10) and (vcord >= 249+35 and vcord < 249+50))
             
            then R <= "1111";G <= "1111";B <= "0011";
        
        -- Red background poster
            else  R <= "1111"; G <= "0000"; B <= "0000";
            end if;
           
        elsif rising_edge (clk25_s) then
            -- Obstacle display
                --Top island
             --   if (hcord >= LIM_G1 and hcord <LIM_D1) and (vcord >= LIM_H1 and vcord<LIM_B1) then R<="1111"; G<="0000"; B<="1111"; end if; --affichage centre obstacle
             --   if (hcord >= LIM_G1-BORD and hcord <LIM_G1) and (vcord >= LIM_H1-BORD and vcord<LIM_B1+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
             --   if (hcord >= LIM_D1 and hcord <LIM_D1+BORD) and (vcord >= LIM_H1-BORD and vcord<LIM_B1+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
             --   if (hcord >= LIM_G1 and hcord <LIM_D1) and (vcord >= LIM_H1-BORD and vcord<LIM_H1) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
             --   if (hcord >= LIM_G1 and hcord <LIM_D1) and (vcord >= LIM_B1 and vcord<LIM_B1+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                -- Bottom Island
             --   if (hcord >= LIM_G2 and hcord <LIM_D2) and (vcord >= LIM_H2 and vcord<LIM_B2) then R<="1111"; G<="0000"; B<="1111"; end if; --affichage centre obstacle
             --   if (hcord >= LIM_G2-BORD and hcord <LIM_G2) and (vcord >= LIM_H2-BORD and vcord<LIM_B2+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
             --   if (hcord >= LIM_D2 and hcord <LIM_D2+BORD) and (vcord >= LIM_H2-BORD and vcord<LIM_B2+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
             --   if (hcord >= LIM_G2 and hcord <LIM_D2) and (vcord >= LIM_H2-BORD and vcord<LIM_H2) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
             --   if (hcord >= LIM_G2 and hcord <LIM_D2) and (vcord >= LIM_B2 and vcord<LIM_B2+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
              --  if (hcord >= LIM_G3 and hcord <LIM_D3) and (vcord >= LIM_H3 and vcord<LIM_B3) then R<="0000"; G<="0000"; B<="1111"; end if; --affichage centre obstacle
               -- if (hcord >= LIM_G3-BORD and hcord <LIM_G3) and (vcord >= LIM_H3-BORD and vcord<LIM_B3+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                --if (hcord >= LIM_D3 and hcord <LIM_D3+BORD) and (vcord >= LIM_H3-BORD and vcord<LIM_B3+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                --if (hcord >= LIM_G3 and hcord <LIM_D3) and (vcord >= LIM_H3-BORD and vcord<LIM_H3) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                --if (hcord >= LIM_G3 and hcord <LIM_D3) and (vcord >= LIM_B3 and vcord<LIM_B3+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
                --if (hcord >= LIM_G4 and hcord <LIM_D4) and (vcord >= LIM_H4 and vcord<LIM_B4) then R<="1111"; G<="0000"; B<="1111"; end if; --affichage centre obstacle
                --if (hcord >= LIM_G4-BORD and hcord <LIM_G4) and (vcord >= LIM_H4-BORD and vcord<LIM_B4+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                --if (hcord >= LIM_D4 and hcord <LIM_D4+BORD) and (vcord >= LIM_H4-BORD and vcord<LIM_B4+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                --if (hcord >= LIM_G4 and hcord <LIM_D4) and (vcord >= LIM_H4-BORD and vcord<LIM_H4) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                --if (hcord >= LIM_G4 and hcord <LIM_D4) and (vcord >= LIM_B4 and vcord<LIM_B4+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
                if (hcord >= LIM_G5 and hcord <LIM_D5) and (vcord >= LIM_H5 and vcord<LIM_B5) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
                if (hcord >= LIM_G5-BORD and hcord <LIM_G5) and (vcord >= LIM_H5-BORD and vcord<LIM_B5+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                if (hcord >= LIM_D5 and hcord <LIM_D5+BORD) and (vcord >= LIM_H5-BORD and vcord<LIM_B5+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                if (hcord >= LIM_G5 and hcord <LIM_D5) and (vcord >= LIM_H5-BORD and vcord<LIM_H5) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                if (hcord >= LIM_D5 and hcord <LIM_D5) and (vcord >= LIM_B5 and vcord<LIM_B5+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
                if (hcord >= LIM_G6 and hcord <LIM_D6) and (vcord >= LIM_H6 and vcord<LIM_B6) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
                if (hcord >= LIM_G6-BORD and hcord <LIM_G6) and (vcord >= LIM_H6-BORD and vcord<LIM_B6+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                if (hcord >= LIM_D6 and hcord <LIM_D6+BORD) and (vcord >= LIM_H6-BORD and vcord<LIM_B6+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                if (hcord >= LIM_G6 and hcord <LIM_D6) and (vcord >= LIM_H6-BORD and vcord<LIM_H6) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
              --  if (hcord >= LIM_G6 and hcord <LIM_G12) and (vcord >= LIM_B6 and vcord<LIM_B6+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
                if (hcord >= LIM_G7 and hcord <LIM_D7) and (vcord >= LIM_H7 and vcord<LIM_B7) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
                if (hcord >= LIM_G7-BORD and hcord <LIM_G7) and (vcord >= LIM_H7-BORD and vcord<LIM_B7+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                if (hcord >= LIM_D7 and hcord <LIM_D7+BORD) and (vcord >= LIM_H7-BORD and vcord<LIM_B7+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                if (hcord >= LIM_D7 and hcord <LIM_D7) and (vcord >= LIM_H7-BORD and vcord<LIM_H7) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                if (hcord >= LIM_G7 and hcord <LIM_D7) and (vcord >= LIM_B7 and vcord<LIM_B7+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
                if (hcord >= LIM_G8 and hcord <LIM_D8) and (vcord >= LIM_H8 and vcord<LIM_B8) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
                if (hcord >= LIM_G8-BORD and hcord <LIM_G8) and (vcord >= LIM_H8-BORD and vcord<LIM_B8+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                if (hcord >= LIM_D8 and hcord <LIM_D8+BORD) and (vcord >= LIM_H8-BORD and vcord<LIM_B8+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                if (hcord >= LIM_G8 and hcord <LIM_G11) and (vcord >= LIM_H8-BORD and vcord<LIM_H8) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                if (hcord >= LIM_G8 and hcord <LIM_D8) and (vcord >= LIM_B8 and vcord<LIM_B8+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
               -- if (hcord >= LIM_G9 and hcord <LIM_D9) and (vcord >= LIM_H9 and vcord<LIM_B9) then R<="1111"; G<="0000"; B<="0001"; end if; --affichage centre obstacle
               -- if (hcord >= LIM_G9-BORD and hcord <LIM_G9) and (vcord >= LIM_H9 and vcord<LIM_B9+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
               -- if (hcord >= LIM_D9 and hcord <LIM_D9+BORD) and (vcord >= LIM_H9 and vcord<LIM_B9+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
               -- if (hcord >= LIM_G9 and hcord <LIM_D9) and (vcord >= LIM_B9 and vcord<LIM_B9+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
                
                if (hcord >= LIM_G10 and hcord <LIM_D10) and (vcord >= LIM_H10 and vcord<LIM_B10) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
                if (hcord >= LIM_G10-BORD and hcord <LIM_G10) and (vcord >= LIM_H10-BORD and vcord<LIM_B10) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                if (hcord >= LIM_D10 and hcord <LIM_D10+BORD) and (vcord >= LIM_H10-BORD and vcord<LIM_B10) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                if (hcord >= LIM_G10 and hcord <LIM_D10) and (vcord >= LIM_H10-BORD and vcord<LIM_H10) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                
                if (hcord >= LIM_G11 and hcord <LIM_D11) and (vcord >= LIM_H11 and vcord<LIM_B11) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
                if (hcord >= LIM_G11-BORD and hcord <LIM_G11) and (vcord >= LIM_H11-BORD and vcord<LIM_B11) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
                if (hcord >= LIM_D11 and hcord <LIM_D11+BORD) and (vcord >= LIM_H11-BORD and vcord<LIM_B11) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
                if (hcord >= LIM_G11 and hcord <LIM_D11) and (vcord >= LIM_H11-BORD and vcord<LIM_H11) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord sup
                
               -- if (hcord >= LIM_G12 and hcord <LIM_D12) and (vcord >= LIM_H12 and vcord<LIM_B12) then R<="1111"; G<="0000"; B<="0000"; end if; --affichage centre obstacle
               -- if (hcord >= LIM_G12-BORD and hcord <LIM_G12) and (vcord >= LIM_H12 and vcord<LIM_B12+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord gauche
               -- if (hcord >= LIM_D12 and hcord <LIM_D12+BORD) and (vcord >= LIM_H12 and vcord<LIM_B12+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord droit
               -- if (hcord >= LIM_G12 and hcord <LIM_D12) and (vcord >= LIM_B12 and vcord<LIM_B12+BORD) then R<="0000"; G<="0000"; B<="0000"; end if; --affichage bord inf
            --affichage du fond -- Bottom Display
               -- if((hcord < LIM_G1-BORD or hcord >=LIM_D1+BORD) or (vcord < LIM_H1-BORD or vcord >= LIM_B1+BORD)) --si on n'est ni sur l'obstacle 1
               -- if ((hcord < LIM_G2-BORD or hcord >=LIM_D2+BORD) or (vcord < LIM_H2-BORD or vcord >= LIM_B2+BORD)) --si on n'est ni sur l'obstacle 2
              --  and ((hcord < LIM_G3-BORD or hcord >=LIM_D3+BORD) or (vcord < LIM_H3-BORD or vcord >= LIM_B3+BORD)) --si on n'est ni sur l'obstacle 3 
               -- if ((hcord < LIM_G4-BORD or hcord >=LIM_D4+BORD) or (vcord < LIM_H4-BORD or vcord >= LIM_B4+BORD)) --si on n'est ni sur l'obstacle 4
                if ((hcord < LIM_G5-BORD or hcord >=LIM_D5+BORD) or (vcord < LIM_H5-BORD or vcord >= LIM_B5+BORD)) --si on n'est ni sur l'obstacle 5
                and ((hcord < LIM_G6-BORD or hcord >=LIM_D6+BORD) or (vcord < LIM_H6-BORD or vcord >= LIM_B6+BORD)) --si on n'est ni sur l'obstacle 6
                and ((hcord < LIM_G7-BORD or hcord >=LIM_D7+BORD) or (vcord < LIM_H7-BORD or vcord >= LIM_B7+BORD)) --si on n'est ni sur l'obstacle 7
                and ((hcord < LIM_G8-BORD or hcord >=LIM_D8+BORD) or (vcord < LIM_H8-BORD or vcord >= LIM_B8+BORD)) --si on n'est ni sur l'obstacle 8
                -- and ((hcord < LIM_G9-BORD or hcord >=LIM_D9+BORD) or (vcord < LIM_H9-BORD or vcord >= LIM_B9+BORD)) --si on n'est ni sur l'obstacle 9
                and ((hcord < LIM_G10-BORD or hcord >=LIM_D10+BORD) or (vcord < LIM_H10-BORD or vcord >= LIM_B10+BORD)) --si on n'est ni sur l'obstacle 10
                and ((hcord < LIM_G11-BORD or hcord >=LIM_D11+BORD) or (vcord < LIM_H11-BORD or vcord >= LIM_B11+BORD)) --si on n'est ni sur l'obstacle 11
               -- and ((hcord < LIM_G12-BORD or hcord >=LIM_D12+BORD) or (vcord < LIM_H12-BORD or vcord >= LIM_B12+BORD)) --si on n'est ni sur l'obstacle 12
                then R <= R_s; G <= G_s; B <= B_s;end if; --on affiche le fond 
                
            -- Snake and apple display according to play
                if play='1' then
                -- Diplay of the head
                    if (hcord >= teteG_s and hcord <teteD_s) and (vcord >= teteH_s and vcord<teteB_s) then R<="0000"; G<="1111"; B<="0000"; end if; --si on est au niveau de la tête => affihcage tête serpent
                -- Diplsay of the apple
                    if (hcord >= pomG_s and hcord <pomD_s) and (vcord >= pomH_s and vcord<pomB_s) then R<="1111"; G<="0000"; B<="0000"; end if; --si on est au niveau de la pomme on affiche la pomme
                -- Display of the segments of the snake
                    if nb_seg_s >= 1 and (hcord >= segG1_s and hcord <segD1_s) and (vcord >= segH1_s and vcord<segB1_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment1
                    if nb_seg_s >= 2 and (hcord >= segG2_s and hcord <segD2_s) and (vcord >= segH2_s and vcord<segB2_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment2
                    if nb_seg_s >= 3 and (hcord >= segG3_s and hcord <segD3_s) and (vcord >= segH3_s and vcord<segB3_s) then R<="1111"; G<="0111"; B<="0000"; end if;--affichage segment3
                    if nb_seg_s >= 4 and (hcord >= segG4_s and hcord <segD4_s) and (vcord >= segH4_s and vcord<segB4_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment4
                    if nb_seg_s >= 5 and (hcord >= segG5_s and hcord <segD5_s) and (vcord >= segH5_s and vcord<segB5_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment5
                    if nb_seg_s >= 6 and (hcord >= segG6_s and hcord <segD6_s) and (vcord >= segH6_s and vcord<segB6_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment6
                    if nb_seg_s >= 7 and (hcord >= segG7_s and hcord <segD7_s) and (vcord >= segH7_s and vcord<segB7_s) then R<="1111"; G<="0111"; B<="0000"; end if;--affichage segment7
                    if nb_seg_s >= 8 and (hcord >= segG8_s and hcord <segD8_s) and (vcord >= segH8_s and vcord<segB8_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment8
                    if nb_seg_s >= 9 and (hcord >= segG9_s and hcord <segD9_s) and (vcord >= segH9_s and vcord<segB9_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment9
                    if nb_seg_s = 10 and (hcord >= segG10_s and hcord <segD10_s) and (vcord >= segH10_s and vcord<segB10_s) then R<="0000"; G<="0111"; B<="0000"; end if;--affichage segment10
                end if;
                -- Pause screen display
                if pause_s = '1' and visible = '1' then 
                    -- display of a black banner
                    if ((hcord >= 0 and hcord <= 639) and (vcord >= 186 and vcord < 293)) 
                    then  R<="0000"; G<="0000"; B<="0000";
                    end if;
                    
                    --affichage du P, barre de gauche
                    if ((hcord >= 154 and hcord < 154+15) and (vcord >= 239-43+15 and vcord < 239+44))
                    --affichage du P, barre de droite
                    or ((hcord >= 154+43 and hcord < 154+43+15) and (vcord >= 239-43+15 and vcord < 239-43+15+21))
                    --affichage du P, barre du haut
                    or ((hcord >= 154+15 and hcord < 154+15+28) and (vcord >= 239-43 and vcord < 239-43+15))
                    --affichage du P, barre du milieu
                    or ((hcord >= 154+15 and hcord < 154+15+28) and (vcord >= 239-43+36 and vcord < 239-43+36+15))
                    
                    --affichage du A, barre de gauche
                    or ((hcord >= 222 and hcord < 222+15) and (vcord >= 239-43+15 and vcord < 239-43+87))
                    --affichage du A, barre de droite
                    or ((hcord >= 222+28+15 and hcord < 222+28+30) and (vcord >= 239-43+15 and vcord < 239-43+87))
                    --affichage du A, barre du haut
                    or ((hcord >= 222+15 and hcord < 222+15+28) and (vcord >= 239-43 and vcord < 239-43+15))
                    --affichage du A, barre du milieu
                    or ((hcord >= 222+15 and hcord < 222+15+28) and (vcord >= 239-43+36 and vcord < 239-43+36+15))
                    
                    --affichage du U, barre de gauche
                    or ((hcord >= 290 and hcord < 290+15) and (vcord >= 239-43 and vcord < 239-43+72))
                    --affichage du U, barre de droite
                    or ((hcord >= 290+43 and hcord < 290+43+15) and (vcord >= 239-43 and vcord < 239-43+72))
                    --affichage du U, barre du bas
                    or ((hcord >= 290+15 and hcord < 290+15+28) and (vcord >= 239-43+72 and vcord < 239-43+87))
                    
                    --affichage du S barre du haut
                    or ((hcord >= 358+15 and hcord < 358+15+28) and (vcord >= 239-43 and vcord < 239-43+15))
                    --affichage du S barre du milieu
                    or ((hcord >= 358+15 and hcord < 358+15+28) and (vcord >= 239-43+36 and vcord < 239-43+15+36))
                    --affichage du S barre du bas
                    or ((hcord >= 358+15 and hcord < 358+15+28) and (vcord >= 239-43+72 and vcord < 239-43+15+72))
                    --affichage du S barre de gauche
                    or ((hcord >= 358 and hcord < 358+15) and (vcord >= 239-43+15 and vcord < 239-43+36))
                    --affichage du S barre de droite
                    or ((hcord >= 358+43 and hcord < 358+15+43) and (vcord >= 239-43+51 and vcord < 239-43+51+21))
                    
                    --affichage du E, barre du haut
                    or ((hcord >= 426+15 and hcord < 426+15+43) and (vcord >= 239-43 and vcord < 239-43+15))
                    --affichage du E, barre du milieu
                    or ((hcord >= 426+15 and hcord < 426+15+43) and (vcord >= 239-43+36 and vcord < 239-43+36+15))
                    --affichage du E, barre du bas
                    or ((hcord >= 426+15 and hcord < 426+15+43) and (vcord >= 239-43+72 and vcord < 239-43+87))
                    --affichage du E, barre de gauche sup
                    or ((hcord >= 426 and hcord < 426+15) and (vcord >= 239-43+15 and vcord < 239-43+15+21))
                    --affichage du E, barre de gauche inf
                    or ((hcord >= 426 and hcord < 426+15) and (vcord >= 239-43+51 and vcord < 239-43+51+21))
                    
                    then R<="1111"; G<="0000"; B<="0000";
                    end if;
                end if;  
        end if;
    end process;

--=======================--
-- PAUSE --
--=======================--
    process(reset, clk25_s)
    begin
        if reset = '1' then pause_s <= '0';
        elsif rising_edge(clk25_s) then 
            if pause = '1' then pause_s <= '1';
            else pause_s <= '0';
            end if;
        end if;
    end process;

--=================================================--
--  Switches --
--=================================================--
led15 <= '1' when play = '1' else '0';
led14 <= '1' when pause = '1' else '0';
led5 <= '1' when cmd(5) = '1' else '0';
led4 <= '1' when cmd(4) = '1' else '0';
led3 <= '1' when cmd(3) = '1' else '0';
led2 <= '1' when cmd(2) = '1' else '0';
led1 <= '1' when cmd(1) = '1' else '0';
led0 <= '1' when cmd(0) = '1' else '0';

end behavioral;