#!/usr/bin/env ruby

=begin
Gabe Berke-Williams
HW06: lcd.rb
This is the markedly less elegant version that I coded this weekend.

Description: Prints out "LCD" versions of numbers provided on command line.
Example usage:
> lcd.rb 012345

The correct display is:

 --        --   --        -- 
|  |    |    |    | |  | |   
|  |    |    |    | |  | |   
           --   --   --   -- 
|  |    | |       |    |    |
|  |    | |       |    |    |
 --        --   --        -- 

Options: lcd.rb [-s SIZE] [NUMBERS]
lcd.rb -s 1 6789 gives
 -   -   -   - 
|     | | | | |
 -       -   - 
| |   | | |   |
 -       -   - 
=end

# Align to 3 spaces because with size = 1 each number is 3 chars wide
BLANK = ' ' * 3
ACROSS = ' - '
LEFT =  '|  '
RIGHT = '  |'
LEFTRIGHT = '| |'

# Each digit has 5 lines if size = 1
# Thus for an 8:
#  -  # 1st line (POSITION[0][8])
# | | # 2        (POSITION[1][8])
#  -  # 3        etc.
# | | # 4
#  -  # 5
POSITIONS = {
  0 => {0=>ACROSS,
        1=>BLANK,
        2=>ACROSS,
        3=>ACROSS,
        4=>BLANK,
        5=>ACROSS,
        6=>ACROSS,
        7=>ACROSS,
        8=>ACROSS,
        9=>ACROSS},
 1 => {0=>LEFTRIGHT,
       1=>RIGHT,
       2=>RIGHT,
       3=>RIGHT,
       4=>LEFTRIGHT,
       5=>LEFT,
       6=>LEFT,
       7=>RIGHT,
       8=>LEFTRIGHT,
       9=>LEFTRIGHT},
 2 => {0=>BLANK,
       1=>BLANK,
       2=>ACROSS,
       3=>ACROSS,
       4=>ACROSS,
       5=>ACROSS,
       6=>ACROSS,
       7=>BLANK,
       8=>ACROSS,
       9=>ACROSS},
 3 => {0=>LEFTRIGHT,
       1=>RIGHT,
       2=>LEFT,
       3=>RIGHT,
       4=>RIGHT,
       5=>RIGHT,
       6=>LEFTRIGHT,
       7=>RIGHT,
       8=>LEFTRIGHT,
       9=>RIGHT},
 4 => {0=>ACROSS,
       1=>BLANK,
       2=>ACROSS,
       3=>ACROSS,
       4=>BLANK,
       5=>ACROSS,
       6=>ACROSS,
       7=>BLANK,
       8=>ACROSS,
       9=>ACROSS}
}

# Make a line in an LCD number be the correct size (correct number of bars, etc)
def justify(str, size)
  if str.include?('-')
    # ' - ' => ' --- '
    str = ('-' * size).center(size + 2, ' ')
  elsif str.include?('|')
    # put _size_ spaces in between bars
    # Use indexes to grab leftmost/rightmost chars. Each may be a bar, may be a
    # space.
    str = str[0,1] + ' ' * (size) + str[-1,1]
  else
    # Blank strings are always lines that would have dashes (line 0, 2, or 4)
    str = ' ' * (size + 2)
  end
  return str
end

def num2lcd(nums, size = 2)
  lcd_num_strings = []
  # For each number, get its 1st/2nd/3rd/4th/5th lines
  (0..4).to_a.each do |line|
    lines = POSITIONS[line].select{|x| nums.include?(x) }.values
    lines.map! do |l|
      l = justify(l, size)
      # put some space between numbers
      l + " "
    end
    if [1,3].include?(line)
      # If we're on a line with bars, print out _size_ lines of bars
      lcd_num_strings << ([lines.join] * size).join("\n")
    else
      lcd_num_strings << lines.join
    end
  end
  # Automatically joins with "\n"
  puts lcd_num_strings
end

# Default to size of 2
size = 2
if ARGV[0] == '-s'
  # user-provided size
  size = ARGV[1]
  # Remove "-s" and the size argument
  2.times{ ARGV.shift }
end
nums = ARGV

num2lcd(nums, size)
