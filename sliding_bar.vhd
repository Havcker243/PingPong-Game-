library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity declaration for sliding_bar, representing one of the player's paddles in the game.
entity sliding_bar is
  port (
    clk : in std_logic; -- Clock input for synchronization of the paddle's movement.
    btnL, btnR : in std_logic; -- Buttons for left and right movement of the paddle.
    slide_bar_position : out integer -- Output integer indicating the paddle's position.
  );
end sliding_bar;

-- The architecture of the sliding_bar, describing the behavior of the paddle.
architecture behavior of sliding_bar is
  constant slide_bar_width : integer := 55; -- Width of the paddle.
  signal slide_x_pos : integer := 320; -- Initial horizontal position of the paddle, likely the screen's midpoint.
  signal last_btnL, last_btnR : std_logic := '0'; -- Variables to store the previous state of the buttons.
  constant move_step : integer := 40; -- The number of pixels the paddle moves per button press.

begin
  -- Process block that is sensitive to the clock signal.
  process(clk)
  begin
    -- Check for a rising edge of the clock to ensure synchronized updates.
    if rising_edge(clk) then
      -- Detect a single press event for the left button (btnL).
      if last_btnL = '0' and btnL = '1' then
        -- Prevent the paddle from moving beyond the left screen boundary.
        if slide_x_pos > 0 then
          -- Move the paddle left by decreasing the x position.
          slide_x_pos <= slide_x_pos - move_step;
        end if;
      end if;
      -- Update the last state for the left button.
      last_btnL <= btnL; 

      -- Detect a single press event for the right button (btnR).
      if last_btnR = '0' and btnR = '1' then
        -- Prevent the paddle from moving beyond the right screen boundary.
        if slide_x_pos < (640 - slide_bar_width) then
          -- Move the paddle right by increasing the x position.
          slide_x_pos <= slide_x_pos + move_step;
        end if;
      end if;
      -- Update the last state for the right button.
      last_btnR <= btnR;
      -- Output the current paddle position.
      slide_bar_position <= slide_x_pos;
    end if;
  end process;
  
end behavior;

