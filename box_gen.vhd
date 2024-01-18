-------------------------------------------------------------------------------
-- source : Dr. Jones in class box generator example
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity box_gen is
    port (
      clk : in std_logic;
      video_on : in std_logic;
      pixel_tick : in std_logic;
      pixel_x, pixel_y : in std_logic_vector(9 downto 0);
      box_r : in std_logic_vector(3 downto 0);
      box_g : in std_logic_vector(3 downto 0);
      box_b : in std_logic_vector(3 downto 0);
     
      slide_bar_position : in integer; -- The postion of the first slider 
      second_slide_bar_position : in integer; -- The postion of the second slider 
    
      red : out std_logic_vector(3 downto 0);
      green : out std_logic_vector(3 downto 0);
      blue : out std_logic_vector(3 downto 0);
      bounce_count: out integer; -- This line to output the bounce count 
      second_bounce_count: out integer -- This line to output the bounce count for the second slider  

    );
end box_gen;

architecture box_gen of box_gen is

  signal red_reg, red_next: std_logic_vector(3 downto 0) := (others => '0');
  signal green_reg, green_next: std_logic_vector(3 downto 0) := (others => '0');
  signal blue_reg, blue_next: std_logic_vector(3 downto 0) := (others => '0');   
  
  -- position of the box
  signal box_xl, box_yt, box_xr, box_yb : integer := 0; 
  signal update_pos : std_logic := '0'; 

  -- Bounce counter updated during collision of box and slider 
  signal internal_bounce_count : integer := 0;
   signal internal_second_bounce_count : integer := 0;

  -- height and width of the two siders in the game 
  constant slide_bar_width: integer := 70; 
  constant slide_bar_height: integer := 13;
  constant  second_slide_bar_width: integer := 70; 
  constant  second_slide_bar_height: integer := 13;

begin

  -- generate the signal update_pos that will move the box
  process ( video_on )
    variable counter : integer := 0;
  begin
      if rising_edge(video_on) then
          counter := counter + 1;
          if counter > 120 then
              counter := 0;
              update_pos <= '1';
          else
              update_pos <= '0';
          end if;
       end if;
  end process;

-- compute the position and direction of box 
process (update_pos, box_xr, box_xl, box_yt, box_yb)
    -- signals for animating the box
    variable dir_x, dir_y : integer := 1;
    variable x, y : integer := 0;
begin
    -- update the x, y direction synchronously on rising edge of the update_pos signal
    if rising_edge(update_pos) then
        -- Mux to choose the next x position
        if (box_xr > 639) and (dir_x = 1) then
            -- bounce off right
            dir_x := -1;
            x := 559;
        elsif (box_xl < 1) and (dir_x = -1) then
            -- bounce off left
            dir_x := 1;
            x := 0;
        else
            -- keep going same direction
            dir_x := dir_x;
            x := x + dir_x;
        end if;

        -- Mux to choose next y position
        if (box_yb > 479) and (dir_y = 1) then
            -- bounce off bottom
            dir_y := -1;
            y := 399;
        elsif (box_yt < 1) and (dir_y = -1) then
            -- bounce off top
            dir_y := 1;
            y := 0;
        else
            -- keep going same direction
            dir_y := dir_y;
            y := y + dir_y;
        end if;

        -- Additional Collision detection with the bottom slider
       -- if the coordinates of the box come into this ranges the box would be set to move the other way , giving it bouncing or collision effect 
        if (box_yb >= (480 - slide_bar_height)) and (box_yb <= 480) then
            if (box_xr >= slide_bar_position) and (box_xl <= slide_bar_position + slide_bar_width) then
                if dir_y = 1 then
                    -- bounce_counter to count the number of times the box hit the first slider 
                    internal_bounce_count <= internal_bounce_count + 1;
                    bounce_count <= internal_bounce_count;
                end if;
                dir_y := -1; -- Invert Vertical direction
            end if;
        end if;

        -- Collision detection with the top (second)  slider
        -- The same as the buttom slider just with a change of range since this slider is ontop 
        if (box_yt <= second_slide_bar_height) and (box_yt >= 0) then
            if (box_xr >= second_slide_bar_position) and (box_xl <= second_slide_bar_position + second_slide_bar_width) then
                if dir_y = -1 then
                    -- Internal bounce counter 
                    internal_second_bounce_count <= internal_second_bounce_count + 1;
                    -- second_bounce_count <= internal_second_bounce_count;
                end if;
                dir_y := 1; -- Invert Vertical direction (bounce downwards)
            end if;
        end if;
    end if;

    -- box position now relies on x, y and is not "fixed"
    box_xl <= x;
    box_yt <= y;
    box_xr <= x + 20;
    box_yb <= y + 20;

end process;



-- process to generate output colors for the box           
process (pixel_x, pixel_y, box_xl, box_xr, box_yt, box_yb, slide_bar_position)
begin
    if (unsigned(pixel_x) > box_xl) and (unsigned(pixel_x) < box_xr) and
       (unsigned(pixel_y) > box_yt) and (unsigned(pixel_y) < box_yb) then
        -- foreground box color yellow
        red_next   <= box_r;
        green_next <= box_g;
        blue_next  <= box_b;

    -- Process to generate the visual representation of the lower slider
    elsif (unsigned(pixel_y) > 480 - slide_bar_height) and
          (unsigned(pixel_y) <= 480) and
          (unsigned(pixel_x) > slide_bar_position) and
          (unsigned(pixel_x) < slide_bar_position + slide_bar_width) then
        -- color of the sliding bar
        red_next <= "1111";
        green_next <= "0000";
        blue_next <= "0000";

    -- Process to generate the visual representation of the upper slider
    elsif (unsigned(pixel_y) < second_slide_bar_height) and
          (unsigned(pixel_y) >= 0) and
          (unsigned(pixel_x) > second_slide_bar_position) and
          (unsigned(pixel_x) < second_slide_bar_position + second_slide_bar_width) then
        -- color of the sliding bar
        red_next <= "1111";
        green_next <= "0000";
        blue_next <= "0000";

    else
        -- background color opposite of box color
        red_next   <= not box_r;
        green_next <= not box_g;
        blue_next  <= not box_b;
    end if;
end process;


  -- generate r,g,b registers
  process (video_on, pixel_tick, red_next, green_next, blue_next)
  begin
    if rising_edge(pixel_tick) then
      if (video_on = '1') then
        red_reg   <= red_next;
        green_reg <= green_next;
        blue_reg  <= blue_next;
      else
        red_reg   <= "0000";
        green_reg <= "0000";
        blue_reg  <= "0000";
      end if;
    end if;
  end process;

  -- generate the output colors
  red <= red_reg;
  green <= green_reg;
  blue <= blue_reg;
  

end box_gen;