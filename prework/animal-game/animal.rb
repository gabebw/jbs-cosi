#!/usr/bin/ruby

=begin
Author: Gabe Berke-Williams
Prework: Animal Game
The program is a animal quiz program.
Usage: "ruby animal.rb" and follow instructions.
=end

=begin
== Animal ==

The program is an animal quiz program.

It works like this. The program starts by telling the user to think of an
animal. It then begins asking a series of yes/no questions about that animal:
does it swim, does it have hair, etc. Eventually, it will narrow down the
possibilities to a single animal and guess that (Is it a mouse?).

If the program has guessed correctly, the game is over and may be restarted
with a new animal.
If the program has guessed incorrectly, it asks the user for the kind of animal
they were thinking of and then asks for the user to provide a question that can
distinguish between its incorrect guess and the correct answer. It then adds
the new question and animal to its "database" and will guess that animal in the
future (if appropriate).
=end

class Animal
  attr_reader :name
  attr_accessor :questions

  # @questions is an array of questions like "Does it have hair" (NO question
  # mark) that apply to this animal
  def initialize(name, question_array)
    @name = name.to_s # use to_s because I want to be able to pass in symbols
    @questions = question_array
  end

  # Add a comparison function so we can detect duplicates after loading from
  # Marshal cache
  def ==(other_animal)
    return @name == other_animal.name
  end

  def to_s
    @name + " / " + @questions.join(', ')
  end
end

class AnimalGame
  def initialize
    @animals_file_name = 'save_file_animals.marshal'

    @animals = [
      Animal.new(:mouse, ["Does it have hair", "Does it have a tail"]),
      Animal.new(:tiger, ["Does it have hair", "Does it have a tail", "Does it have stripes"]),
      Animal.new(:rat, ["Does it have hair", "Does it have a tail", "Is it bigger than a mouse"]),
      Animal.new(:hippo, ["Does it have hair", "Does it have a tail", "Is it bigger than a mouse",
                          "Is it amphibious"])
    ]
    if File.exist?(@animals_file_name)
      if File.size?(@animals_file_name)
        # Only add from cache if there's a file and it's not empty 
        # uniq and | don't work for removing duplicates, so do it manually
        cached_animals = Marshal.load(File.new(@animals_file_name, 'r'))
        cached_animals.each do |animal|
          # include? does use ==, so we use that to detect duplicates
          @animals << animal unless @animals.include?(animal)
        end
      end
    else
      # File doesn't exist, create it
      File.new(@animals_file_name, 'w').close
    end
  end

  # Play the game: Ask user to think of an animal, guess until the animal is
  # guessed or we run out of animals, then if we run out of animals, ask for a
  # clarifying question. Plays until user chooses to quit.
  def play
    keep_playing = true
    while keep_playing
      puts "Please think of an animal."
      while not ask_question("Have you thought of an animal")
      end
      # In case we don't guess the animal, keep track of what questions the animal
      # does have
      @mystery_animals_questions = []
      # possible_animals is pared down as we ask more questions
      possible_animals = @animals.dup
      # possible_questions is reset each time we ask a question.
      possible_questions = @animals.inject([]){|ary, animal| ary += animal.questions }.uniq
      # questions we've already asked about
      asked_questions = []
      # Have we guessed the animal yet?
      guessed = false
      while not guessed
        if possible_questions.empty?
          # No more questions, so we're out of questions. Add an animal and break.
          ask_for_and_add_new_animal()
          break
        end
        current_question = possible_questions.shift
        asked_questions << current_question
        # Reget possible_questions so we don't ask irrelevant questions
        possible_questions = possible_animals.inject([]){|ary, animal| ary += animal.questions }.uniq - asked_questions
        question_matches = ask_question(current_question)
        if question_matches
          # Animal DOES have this question, REJECT animals who DON'T have it
          possible_animals.reject! do |animal|
            ! animal.questions.include?(current_question)
          end
          # Add question to the mystery animal's questions
          @mystery_animals_questions << current_question
        else
          # Animal DOESN'T have this question, REJECT animals who DO have it
          possible_animals.reject! do |animal|
            animal.questions.include?(current_question)
          end
        end
        if possible_animals.empty?
          # No animals left, ask for and add new animal
          ask_for_and_add_new_animal()
          break
        elsif possible_animals.size == 1
          # Only one animal left, guess it
          guess_animal_name = possible_animals.first.name
          guessed = ask_question("Is it a " + guess_animal_name)
          if not guessed
            ask_for_and_add_new_animal(guess_animal_name)
            break
          end
        end
      end
      puts "Woo! I win!" if guessed
      keep_playing = ask_question("Play again")
    end
  end

  # A convenience function to ask for a new animal
  # incorrect_guess defaults to nil to pass it to ask_for_new_question
  def ask_for_and_add_new_animal(incorrect_guess = nil)
    print "I'm out of animals. What animal were you thinking of? "
    name = gets.chomp.sub(/^(a|an|the) /, '')
    ask_for_and_add_new_question(incorrect_guess, name)
    add_animal(name, @mystery_animals_questions)
  end

  # Ask user for a new question and add it to either @mystery_animals_questions
  # or incorrect_guess's questions, as appropriate
  def ask_for_and_add_new_question(incorrect_guess, correct_animal)
    if incorrect_guess.nil?
      # Didn't have a chance to guess an animal, so just put in the
      # correct_animal
      puts 'Please give me a question so I can guess "%s" next time.' % correct_animal
    else
      # We did guess an animal, but it was wrong.
      puts 'Please type a question so I can distinguish %s %s from %s %s.' %
      [article(incorrect_guess), incorrect_guess, article(correct_animal), correct_animal]
    end
    print 'Please give me a question. '
    new_question = gets.chomp.sub(/\?$/,'')
    answer = ask_question("Is this question true for #{article(correct_animal)} #{correct_animal}.")
    if answer
      # This question applies to correct_animal
      @mystery_animals_questions << new_question
    else
      # This question applies to incorrect_guess
      incorrect_animal = @animals.detect{|x| x.name == incorrect_guess }
      incorrect_animal.questions << new_question
    end
  end

  # Add a new Animal with given name and questions to @animals and save it
  # to the Marshal file
  def add_animal(name, questions_array)
    known_animal = @animals.detect{|a| a.name == name }
    if known_animal
      # We already know about this animal, but for whatever reason we didn't
      # guess it. Don't add the animal, just modify its questions.
      known_animal.questions |= questions_array
    else
      # Completely new animal.
      @animals << Animal.new(name, questions_array)
    end
    save_animals_array
  end

  # Dump @animals to @animals_file_name using Marshal
  def save_animals_array
    Marshal.dump(@animals, File.new(@animals_file_name, 'w'))
  end

  # Return true if user types "y" or "yes". Case insensitive.
  def user_agree?
    return gets.chomp =~ /^(y|yes)$/i
  end

  # Helper function that asks the question and returns true if user answered in affirmative, else false 
  def ask_question(question)
    print question.sub(/\?$/, '') + "? (y or n) "
    return user_agree?
  end

  # Helper function that gives the correct article for a given string ("a" or "an")
  def article(str)
    str =~ /^[aeiou]/i ? 'an' : 'a'
  end
end

AnimalGame.new.play
