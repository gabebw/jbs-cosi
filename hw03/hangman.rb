#!/usr/bin/env ruby

=begin
Author: Gabe Berke-Williams
HW03: hangman.rb
Description: A hangman game.

Usage: "ruby hangman.rb" and follow the directions
=end

require 'guesser'

class Hangman
  # Pass in an instance of the guessing engine to use and the number of lives
  # (incorrect guesses) the computer is allowed.  Default number of lives is 6.
  def initialize(guesser, num_lives = 6)
    @guesser = guesser
    @num_lives = num_lives
    # The number of letters in the phrase.
    @num_letters = 0
    # An array of the phrase so far, e.g. %w{a _ r}. It's an array to allow
    # easy updating of indices.
    @phrase_so_far = []
  end

  # Play the game!
  def play
    setup_new_game
    while @num_lives > 0 
      print_status
      # Ask the guessing engine for a guess
      letter = @guesser.guess()
      print "User says that \"#{letter}\" occurs in position(s) (n for N/A): "
      positions_str = STDIN.gets.chomp
      # Tell the guesser what the user said
      if positions_str =~ /^n|nope|no$/i
        @num_lives -= 1
        @guesser.report(nil)
      else
        # Change positions from a string to an array of numbers.
        # Subtract 1 from each position because the user sees indices starting
        # at 1, while we count from 0.
        positions = positions_str.scan(/\d+/).map{|p| p.to_i - 1 }
        p positions
        @guesser.report(positions)
      end
    end
    puts "Oh no! I died!"
  end

  # Ask for the number of letters and set @phrase_so_far
  def setup_new_game
    # String.to_i returns 0, so this line catches that too
    while @num_letters <= 0
      # Get the number of letters
      print "How many letters in the phrase? "
      @num_letters = STDIN.gets.chomp.to_i
    end
    @guesser.num_letters = @num_letters
    # initialize @phrase_so_far to e.g. ['_', '_', '_']
    @phrase_so_far = ('_' * @num_letters).split('')
  end

  # Show the game's current status, i.e. number of lives, phrase with correct
  # letters and blanks ("m_st", etc.)
  def print_status 
    puts "Computer has #{@num_lives} lives."
    puts get_phrase_so_far
  end

  # return phrase with blanks for unknown letters and numbers underneath
  # "m _ s t
  #  1 2 3 4"
  def get_phrase_so_far
    phrase_so_far = @guesser.phrase_string.join(' ')
    phrase_so_far << "\n"
    # add the indices beneath
    phrase_so_far << (1..@guesser.phrase_string.size).to_a.join(' ')
    phrase_so_far
  end
end

guesser = Guesser.new
hangman = Hangman.new(guesser)
hangman.play
