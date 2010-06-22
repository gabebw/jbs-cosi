#!/usr/bin/env ruby
# coding: utf-8 # required for using accented chars

require 'test/unit'

# Design a class to represent a dictionary
class Dictionary
  
  # We know that the dictionary starts out empty
  def initialize
    @dictionary = {}
  end

  # Don't know yet how I will represent info
  def empty?
    @dictionary.empty?
  end
 
  # Translations work both ways
  def add_translation(from, to)
    @dictionary[to] = from
    @dictionary[from] = to
  end

  # Remove translation (can be from either word)
  def remove_translation(word)
    translation = @dictionary[word]
    @dictionary.delete(word)
    @dictionary.delete(translation)
  end
  
  def translate(word)
    @dictionary[word]
  end
end

# Test the class as we develop it
class DictionaryTest < Test::Unit::TestCase
  
  def setup
    @dict = Dictionary.new
  end

# Check that a new dictionary is empty
  def test_empty_dict
    assert @dict .empty?
  end

  # Check that once you add at least one translation it is not empty  
  def test_adding_xlate
    @dict.add_translation("book", "boek")
    assert !@dict.empty?
  end

  # Check that I can fetch the translation I adde@dict.
  def test_add_fetch_xlate
    @dict.add_translation("book", "boek")
    book = @dict.translate("boek")
    assert_equal "book", book, "expected translation to be book"
  end
  
  # Let's check two translations
  def test_add_two_xlates
    @dict.add_translation("book", "boek")
    @dict.add_translation("house", "huis")
    assert !@dict.empty?
    assert_equal "book", @dict.translate("boek")
    assert_equal "house", @dict.translate("huis")
  end
  
  def test_accented
    @dict.add_translation("book", "böek")
    assert !@dict.empty?
    assert_equal "book", @dict.translate("böek")
  end

  # An added translation should work both ways
  def test_bidirectional_xlate
    assert @dict.empty?
    @dict.add_translation("book", "boek")
    assert !@dict.empty?
    assert_equal "book", @dict.translate("boek")
    assert_equal "boek", @dict.translate("book")
  end

  # Can we remove a definition by the first argument passed?
  def test_remove_xlate_by_first_word
    @dict.add_translation("book", "boek")
    @dict.remove_translation("book")
    assert_nil @dict.translate("book")
    assert_nil @dict.translate("boek")
  end
  # Can we remove a definition by the second argument passed?
  def test_remove_xlate_by_second_word
    @dict.add_translation("book", "boek")
    @dict.remove_translation("boek")
    assert_nil @dict.translate("book")
    assert_nil @dict.translate("boek")
  end
end
