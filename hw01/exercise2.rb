# The fortune class.
# Usage:
# f = Fortune.new
# f.next_fortune # => returns a random fortune
class Fortune

  def initialize
    # Track index of previous fortune to prevent returning the same one twice 
    # in a row
    @previous_fortune_index = nil
  end

  # A constant defining an array of fortune strings
  FORTUNES = ["You will learn Ruby soon", "You will get an A for this course", "The Redsox will win the superbowl", "You have just received a fortune", "Help! I'm trapped in a fortune factory!", "You will soon gain a lucky item."]

  # Return a random index in FORTUNES
  def get_fortune_index
    (rand * FORTUNES.length).to_i
  end

  # Return a random fortune from FORTUNES different from the fortune returned
  # by next_fortune
  def next_fortune
    index = get_fortune_index
    # loop until we have a new index
    while index == @previous_fortune_index
      index = get_fortune_index
    end
    # Store the index
    @previous_fortune_index = index
    FORTUNES[index]
  end

end

# If called directly from commandline, output 2 random fortunes
if __FILE__ == $0 
  f = Fortune.new
  puts f.next_fortune
  puts f.next_fortune
end
