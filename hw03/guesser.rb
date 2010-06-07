#!/usr/bin/env ruby

=begin
Author: Gabe Berke-Williams
HW03: guesser.rb
Description: A guessing engine for the Hangman game in hangman.rb
=end

class Guesser
  attr_reader :phrase_string

  # If dictionary_file is not passed in, reads /usr/share/dict/words. If
  # /usr/share/dict/words is not present, reads from provided dict.txt (which is
  # just a copy of /usr/share/dict/words from my computer).
  # This program assumes that dictionary_file is a file with one word per line.
  def initialize(dictionary_file = "/usr/share/dict/words")
    # The number of letters in the phrase.
    @num_letters = 0
    # An array of regexes. @possible_matches[n] matches all possibilities for
    # the letter at index n.
    @possible_matches = []
    # Keep track of the letter we guessed
    @guess = nil
    # Letters we've already guessed
    @guessed = []
    # A string showing correctly guessed letters, e.g. "m_st"
    @phrase_string = ''
    
    # A master regex that matches against what we know of the string so far.
    # For "m_st", it would be: /m[a-z]st/
    @phrase_regex = //

    puts dictionary_file
    dictionary_file = get_dictionary_file(dictionary_file)
    # @master_dictionary contains all words...
    @master_dictionary = parse_dictionary_file(dictionary_file)
    # ...while @dictionary contains only words that are valid given what we
    # know about the phrase
    @dictionary = parse_dictionary_file(dictionary_file)
  end
 
  # Must be its own method rather than attr_* because it sets @num_letters,
  # initializes @possible_matches, and generates @phrase_regex
  def num_letters=(num_letters)
    @num_letters = num_letters.to_i
    # Initialize @possible_matches to an array of size num_letters. Each element
    # matches one letter.
    # We have every letter instead of doing "[a-z]" so we can sub it later.
    a_to_z = Regexp.new("[#{('a'..'z').to_a.join}]")
    @possible_matches = Array.new(@num_letters).fill(a_to_z)
    @phrase_string = Array.new(@num_letters).fill('_')
    regenerate_phrase_regex
    @dictionary = @master_dictionary.select{|word| word.size == @num_letters }
  end

  # Returns a letter for the computer to guess.
  def guess
    # trim_dictionary is called each time report() is called, so it's already as
    # slim as possible. Use other measures to decide which letter to guess.
    @guess = get_most_common_letter
    @guessed << @guess
    @guess
  end

  # Return the most common letter in @dictionary that hasn't been guessed yet.
  def get_most_common_letter
    most_common_letter = ''
    # The number of times the most_common_letter appears
    num_times_appears = 0
    dictionary_string = @dictionary.join
    # Trim all_letters to letter that we haven't guessed yet and 
    # that are in dictionary_string
    all_letters = ('a'..'z').to_a.select do |letter| 
      ! @guessed.include?(letter) and dictionary_string.include?(letter)
    end
    all_letters.each do |letter|
      count = dictionary_string.count(letter) 
      if count > num_times_appears 
        num_times_appears = count
        most_common_letter = letter
      end
    end
    puts "most common: #{most_common_letter}"
    most_common_letter
  end

  # This method is called by Hangman instances to tell the guesser what 
  # the user said about its last guess, i.e.
  # @guesser.guess([1,3,5])
  # means that the user said that the letter that the guessing engine guessed
  # is at positions 1, 3, and 5.
  # report(nil) means that the phrase doesn't contain the letter.
  def report(positions)
    if positions.nil? # not in the phrase
      mark_incorrect_letter(@guess)
    else
      # We guessed correctly!
      mark_correct_letter(@guess, positions)
      # Only update the phrase string when we guess correctly
      update_phrase_string(@guess, positions)
    end
  end

  # For each index in positions, set @phrase_string[index] to the given
  # letter. Positions is an array.
  def update_phrase_string(letter, positions)
    positions.each { |pos| @phrase_string[pos] = letter }
  end

  # Mark the given letter as no longer matching at any position.
  def mark_incorrect_letter(letter)
    @possible_matches.map! do |regex|
      # use regex.source so we don't sub the -imx that to_s prepends uses
      Regexp.new(regex.source.sub(letter, ''))
    end
    regenerate_phrase_regex
    trim_dictionary
  end

  # Mark letter as the correct letter at the given positions.
  def mark_correct_letter(letter, positions)
    positions.each { |pos| @possible_matches[pos] = /#{letter}/ }
    regenerate_phrase_regex
    trim_dictionary
  end

  # Regenerate the master phrase regex by concatenating @possible_matches
  def regenerate_phrase_regex
    regex_string = ''
    @possible_matches.each { |regex| regex_string << regex.to_s }
    @phrase_regex = Regexp.new("^#{regex_string}$")
  end

  # Trim the dictionary to only match words that match @phrase_regex
  def trim_dictionary
    @dictionary = @dictionary.select{|word| (@phrase_regex =~ word) != nil }
  end

  # Parse the provided file into a format we can use. Each line in
  # dictionary_file is one word.
  def parse_dictionary_file(dictionary_file)
    File.readlines(dictionary_file).map!{|line| line.chomp }
  end

  # Get a dictionary file, trying the user-provided file, then
  # /usr/share/dict/words, then ./dict.txt. If none work, then exits.
  def get_dictionary_file(dictionary_file)
    files = [dictionary_file, "/usr/share/dict/words", "dict.txt"]
    dict_file = nil
    files.each do |file|
      if File.size?(file)
        dict_file = file
        break
      else
        # dictionary_file doesn't exist or has 0 size
        puts "#{file} either doesn't exist or has 0 size, trying others..."
      end
    end
    if dict_file.nil?
      puts "No file available, quitting."
      exit 1
    else
      return dict_file
    end
  end
end
