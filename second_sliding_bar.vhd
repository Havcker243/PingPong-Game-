library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaration of a new entity named second_sliding_bar
entity second_sliding_bar is
  port (
    clk : in std_logic; -- Input clock signal
    btnD, btnU : in std_logic; -- Input signals from buttons for moving the slider down (D) and up (U)
    second_slide_bar_position : out integer -- Output signal for the current position of the second slider
  );
end second_sliding_bar;

-- Architecture declaration of second_sliding_bar, where the internal behavior is defined
architecture behavior of second_sliding_bar is
  -- Constant declaration for the width of the second slider bar
  constant second_slide_bar_width : integer := 55;
  -- Signal declaration for the X position of the second slider bar, initialized to the middle of the screen
  signal second_slide_x_pos : integer := 320;
  -- Signals to hold the last state of the buttons, initialized to '0' (not pressed)
  signal last_btnD, last_btnU : std_logic := '0';
  -- Constant for the number of pixels the slider moves with each button press
  constant move_step : integer := 40;

begin
  -- Process block that will be triggered on every rising edge of the clock signal
  process(clk)
  begin
    -- Check if the clock signal is at a rising edge
    if rising_edge(clk) then
      -- Check if the Up button was released and then pressed
      if last_btnU = '0' and btnU = '1' then
        -- Check if the slider is not already at the top position
        if second_slide_x_pos > 0 then
          -- Move the slider up by decreasing its X position
          second_slide_x_pos <= second_slide_x_pos - move_step;
        end if;
      end if;
      -- Update the last known state of the Up button
      last_btnU <= btnU;

      -- Check if the Down button was released and then pressed
      if last_btnD = '0' and btnD = '1' then
        -- Check if the slider is not already at the bottom position
        if second_slide_x_pos < (640 - second_slide_bar_width) then
          -- Move the slider down by increasing its X position
          second_slide_x_pos <= second_slide_x_pos + move_step;
        end if;
      end if;
      -- Update the last known state of the Down button
      last_btnD <= btnD;
      -- Update the output position of the slider bar
      second_slide_bar_position <= second_slide_x_pos;
    end if;
  end process;
  
end behavior;
