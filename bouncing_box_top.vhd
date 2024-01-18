-------------------------------------------------------------------------------
-- source : Dr. Jones in class box generator example
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bouncing_box_top is
  port (
    -- System Clock  
    CLK100MHZ : in std_logic;

    -- vga inputs and outputs
    Hsync, Vsync : out std_logic; -- Horizontal and Vertical Synch
    vgaRed       : out std_logic_vector(3 downto 0); -- Red bits
    vgaGreen     : out std_logic_vector(3 downto 0); -- Green bits
    vgaBlue      : out std_logic_vector(3 downto 0); -- Blue bits   

    -- switches , buttuns and LEDs     
    btnC : in std_logic; --- buttun c 
    sw   : in std_logic_vector (15 downto 0); -- 16 switch inputs
    LED  : out std_logic_vector (15 downto 0); -- 16 leds above switches
    an   : out std_logic_vector (3 downto 0); -- Controls four 7-seg displays
    seg  : out std_logic_vector(6 downto 0); -- 6 leds per display
    dp   : out std_logic; -- 1 decimal point per display
    
    btnL  : in std_logic; -- button left on the hardware
    btnR : in std_logic;  -- button right on the hardware
    btnD  : in std_logic;  -- button down on the hardware
    btnU : in std_logic   -- button up on the hardware

  );
end bouncing_box_top;

--  The architecure of the bouncing_box_top 
architecture bouncing_box_top of bouncing_box_top is
  signal clk, reset    : std_logic;
  signal pixel_x, pixel_y     : std_logic_vector(9 downto 0);
  signal video_on, pixel_tick : std_logic;
  signal slide_bar_position_signal : integer := 470; -- Initial postion for the first slider 
  signal second_slide_bar_position_signal : integer := 18; -- Initial postion for the second slider 
  signal bounce_count_signal : integer := 0;  -- Signal to hold bounce count
  signal second_bounce_count_signal : integer := 0;  -- Signal to hold bounce count

begin
  clk   <= CLK100MHZ; -- system clock
  reset <= btnC; -- reset signal for vga driver
  LED   <= sw; -- drive LED's from switches

  reset <= btnC; -- set reset signal with bntC

   

  -- instantiate VGA sync circuit
  vga_sync_unit : entity work.vga_sync
    port map(
      clk => clk, reset => reset, hsync => Hsync,
      vsync => Vsync, video_on => video_on,
      pixel_x => pixel_x, pixel_y => pixel_y,
      p_tick => pixel_tick
    );
    
  -- instantiate box gen circuit
  box_gen_unit : entity work.box_gen
    port map(
      clk => clk,  -- Use the clk signal from bouncing_box_top
      video_on => video_on,
      pixel_tick => pixel_tick,
      box_r => sw(11 downto 8), box_g => sw(7 downto 4), box_b => sw(3 downto 0),
      pixel_x => pixel_x, pixel_y => pixel_y,

      slide_bar_position => slide_bar_position_signal,  -- connect the position of the first slide 
      second_slide_bar_position => second_slide_bar_position_signal, -- connect the postion of the second slide 
      second_bounce_count=> second_bounce_count_signal, -- Connect bounce count signal for the second slider 
      bounce_count => bounce_count_signal, -- Connect bounce count signal
      red => vgaRed, green => vgaGreen, blue => vgaBlue
    );

     
  -- instantiate sliding bar circuit
  sliding_bar_inst : entity work.sliding_bar
  port map(
    clk => clk, -- Use the clk signal from the bouncing_box_top 
    btnL => btnL, -- connect the button left 
    btnR => btnR, -- connect the button right 
    slide_bar_position => slide_bar_position_signal   -- connect the position of the first slide 
  );

     
  -- instantiate second sliding bar circuit
  second_sliding_bar_inst : entity work.second_sliding_bar
  port map(
    clk => clk,  -- Use the clk signal from the bouncing_box_top
    btnU => btnU, -- connect the button up 
    btnD => btnD,-- connect the button down 
    second_slide_bar_position => second_slide_bar_position_signal   -- connect the position of the second slide 
  );

 
  -- instantiate the 7 segment display 
  x7seg_inst : entity work.x7seg_top
port map(
    CLK100MHZ => clk,
    bounce_count => bounce_count_signal, -- Connect bounce count signal
    an => an,
    seg => seg, -- Connect to the 7 segmenent display 
    dp => dp -- Connect 1 decimal point per display 
);

end bouncing_box_top;
