#!/usr/bin/env ruby

=begin
Gabe Berke-Williams
HW06: lcd.rb
This is the elegant version that I coded years ago.

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

TRANSLATE = {
  1 => [BLANK, RIGHT, BLANK, RIGHT, BLANK],
  2 => [ACROSS, RIGHT, ACROSS, LEFT, ACROSS],
  3 => [ACROSS, RIGHT, ACROSS, RIGHT, ACROSS],
  4 => [BLANK, LEFTRIGHT, ACROSS, RIGHT, BLANK],
  5 => [ACROSS, LEFT, ACROSS, RIGHT, ACROSS],
  6 => [ACROSS, LEFT, ACROSS, LEFTRIGHT, ACROSS],
  7 => [ACROSS, RIGHT, BLANK, RIGHT, BLANK],
  8 => [ACROSS, LEFTRIGHT, ACROSS, LEFTRIGHT, ACROSS],
  9 => [ACROSS, LEFTRIGHT, ACROSS, RIGHT, ACROSS],
  0 => [ACROSS, LEFTRIGHT, BLANK, LEFTRIGHT, ACROSS]
}

def num2lcd(nums, size = 2)
  lcd_num_strings = []
  nums.each do |num|
    lines = TRANSLATE[num.to_i]
    lines.map! do |l|
      if l.include?('-')
        # ' - ' => ' --- '
        l = ('-' * size).center(size + 2, ' ')
      elsif l.include?('|')
        # put _size_ spaces in between bars (use indexes to grab chars on 
        # left/right - each may be a bar, may be a space)
        l = l[0,1] + ' ' * (size) + l[-1,1]
        next([l] * size)
      else
        l = ' ' * (size + 2)
      end
      l
    end
    lcd_num_strings << lines.flatten
  end
  puts lcd_num_strings.shift.zip(*lcd_num_strings).map(&:join).join("\n")
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
