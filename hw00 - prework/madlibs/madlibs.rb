#/usr/bin/env ruby

=begin
madlibs.rb
Author: Gabe B-W
Prework: Mad Libs program
Parses ARGV[0] as a Mad Libs template file and asks user for words to fill in
the blanks. 

Format of the template file:
((...)) = placeholder, e.g.
>> Our favorite language is ((a gemstone)).
Then this program asks for "a gemstone". Please use a/an in the query.

To reuse an answer, use ((label:query)) the first time, then later ((label)) to
reuse the results of query. labels must match \w, i.e. [0-9A-Za-z_].
>> Our favorite language is ((gem:a gemstone)). We think ((gem)) is better than
((a gemstone))
In this case, the "gem" label is set to the result of the first query, then
reused at "((gem))"
=end

class MadLibs
  CHUNKER = /\({2} # two open parens
             (?:(\w+?):)? # label, if it exists (doesn't capture the colon)
             (.+?) # the actual query, e.g. "A noun"
             \){2} # two close parens
            /mx

  # Create a filehandle and parse the file.
  def initialize(filename)
    # Check to make sure the file's readable
    if not File.readable_real?(filename)
      raise "#{filename} not readable, exiting."
    end
    @file = File.new(filename, 'r')
    # label => answer
    @labels = {}
    result = parse(@file.read)
    puts result
  end

  # Runs a gsub block to substitute ((...)) with user input
  # Returns the template_str with substitutions performed.
  def parse(template_str)
    # Use /m flag for multiline, to enable "((a\ngemstone))"
    template_str.gsub(CHUNKER) do
      label = $1 # may be nil
      query = $2
      # If no label, check if query IS a label
      if not label and @labels.key?(query)
        @labels[query]
      else
        # When asking for input, use spaces for newlines
        question = "Please give me " + query.gsub("\n", ' ') + ": "
        print question
        answer = $stdin.gets.chomp
        while answer.empty?
          puts "You must provide an answer!"
          print question
          answer = $stdin.gets.chomp
        end

        # associate label with answer if label given
        @labels[label] = answer if label
        answer
      end
    end
  end
end

if ARGV.empty?
  puts "Please provide a filename from which to read the Mad Libs template."
  exit 1
else
  MadLibs.new(ARGV[0])
end
