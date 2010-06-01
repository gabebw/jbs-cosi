# The fortune class.
# Usage:
# f = Fortune.new
# f.next_fortune # => returns a random fortune
class Fortune
  # The marshal file containing a dump of @seen_fortunes
  SEEN_FORTUNES_FILENAME = "seen_fortunes.marshal"
  def initialize
    # Tracks fortunes that have been seen before
    # Will be subtracted from @fortunes to get unseen fortunes
    @seen_fortunes = []

    # Read the marshal dump, if available
    if File.size?(SEEN_FORTUNES_FILENAME)
      # File exists, load it
      @seen_fortunes = Marshal.load(File.new(SEEN_FORTUNES_FILENAME, 'r'))
    end

    # an array of fortune strings
    @fortunes = ["You will learn Ruby soon", "You will get an A for this course", "The Redsox will win the superbowl", "You have just received a fortune", "Help! I'm trapped in a fortune factory!", "You will soon gain a lucky item."]
  end

  # Return a random fortune in @fortunes such that that fortune has
  # not been seen before. If all fortunes have been seen, allows any fortune to
  # be returned.
  def get_unseen_fortune
    # All fortunes have been seen, re-initialize.
    if @seen_fortunes.size == @fortunes.size
      @seen_fortunes = []
    end
    unseen_fortunes = @fortunes - @seen_fortunes
    # Sample chooses a random element from the array
    unseen_fortunes.sample
  end

  # Return a random fortune. Any given fortune will not repeat until all others
  # have been seen once.
  # Dumps @seen_fortunes to marshal cache each time.
  def next_fortune
    fortune = get_unseen_fortune
    # Add the fortunes to @seen_fortunes and Marshal it
    @seen_fortunes << fortune
    Marshal.dump(@seen_fortunes, File.new(SEEN_FORTUNES_FILENAME, 'w'))
    # Return the fortune
    fortune
  end

end

# If called directly from commandline, output 2 random fortunes
if __FILE__ == $0 
  f = Fortune.new
  puts f.next_fortune
  puts f.next_fortune
end
