 -------------------------------------------------------------------------------
-- source : Dr. Jones in class 7seg example
-------------------------------------------------------------------------------library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_unsigned.all; -- needed for conv_integer

entity x7seg_top is
	port (
		CLK100MHZ : in std_logic; -- System clock 
		-- sw        : in std_logic_vector (15 downto 0); -- 16 switch inputs
		-- LED       : out std_logic_vector (15 downto 0); -- 16 leds above switches
		an        : out std_logic_vector (3 downto 0); -- Controls four 7-seg displays
		seg       : out std_logic_vector(6 downto 0); -- 6 leds per display
		dp        : out std_logic;-- 1 decimal point per display
        bounce_count : in integer -- Add this line for bounce count
	  );
end	 x7seg_top;

architecture x7seg_top of x7seg_top is

-- To hold binary representation of bounce_count
signal bounce_count_bin : std_logic_vector(15 downto 0); 
   
-- s is a two bit counter to choose 7-seg display
signal s: STD_LOGIC_VECTOR(1 downto 0);       

-- digit will hold a 4 bit binary value for a hex digit
signal digit: STD_LOGIC_VECTOR(3 downto 0);

-- clkdiv is an 18 bit counter to slow down clock
signal clkdiv: STD_LOGIC_VECTOR(20 downto 0);

-- 100 mhz clock connects to clk
signal clk : STD_LOGIC;

begin
     -- Convert integer bounce_count to binary
    bounce_count_bin <= std_logic_vector(to_unsigned(bounce_count, 16));

    -- The main clock signal (renamed for ease of use)
	clk <= CLK100MHZ; 

	-- Clock divider is a 21 bit counter
	process(clk)
	begin
		if clk'event and clk = '1' then
			clkdiv <= clkdiv +1;
		end if;
	end process;
    
    -- Drive the top two bits of counter to s
    s <= clkdiv(20 downto 19);	
		
	-- signal bounce_count_bin will be displayed on hex display
	-- drive switches to bounce_count_bin (to be consistent with previous example)
	dp <= '1'; -- turn off dp
    -- 4-to-1 MUX to select 4 bit binary code to display
    -- each input to mux comes from 4 bits of bounce_count_bin signal
    digit_mux : process(bounce_count_bin, s)
    begin
      case s is
      when "00" => digit <= bounce_count_bin(3 downto 0); 
      when "01" => digit <= bounce_count_bin(7 downto 4);
      when "10" => digit <= bounce_count_bin(11 downto 8);
      when others => digit <= bounce_count_bin(15 downto 12);           
      end case;
    end process;
	
	-- rapidly rotate a 0 within the 4-bit an signal
	-- this will turn on one seg at a time
	-- the counter is setting the signal s. It 
	seg_choice : process(s)
		variable aen : std_logic_vector(3 downto 0) := "1111";
	begin
		-- set aen variable to 1111
		aen := "1111";
		
		-- make s into an integer and use it to index 
		-- the bit of aen to set to zero
		aen(conv_integer(s)) := '0';  -- set bit to 0

		-- drive anode signals an from variable aen
		an <= aen;
	end process;
	
    -- Decoder ROM that converts 4 bits into
    -- seven segments to display a hex digit
    decoder_rom : process(digit)
    begin
       case digit is
           when X"0" => seg <=  "1000000";     --0
           when X"1" => seg <=  "1111001";     --1
           when X"2" => seg <=  "0100100";     --2
           when X"3" => seg <=  "0110000";     --3
           when X"4" => seg <=  "0011001";     --4
           when X"5" => seg <=  "0010010";     --5
           when X"6" => seg <=  "0000010";     --6
           when X"7" => seg <=  "1011000";     --7
           when X"8" => seg <=  "0000000";     --8
           when X"9" => seg <=  "0010000";     --9
           when X"A" => seg <=  "0001000";     --A
           when X"B" => seg <=  "0000011";     --b
           when X"C" => seg <=  "1000110";     --C
           when X"D" => seg <=  "0100001";     --d
           when X"E" => seg <=  "0000110";     --E
           when others => seg <=  "0001110";   --F
       end case;
    end process;
  	
end x7seg_top;