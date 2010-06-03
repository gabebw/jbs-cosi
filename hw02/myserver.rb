#!/usr/bin/env ruby
=begin
Author: Gabe Berke-Williams
HW02: myserver.rb
6/2/10

Description:
Listens for connections on localhost:8888 and responds appropriately.

Available commands:
* t or time: return current time
* f or message/fortune: return a random fortune from @fortunes
* x: output "Exiting!" and return "Goodbye!" since this causes myclient.rb to
quit
* d: if it receives "d" followed by a filename ("dtest.txt"), returns the contents of e.g. test.txt or a message saying the file does not exist. 
* date: the current date
* message/joke: return a joke in English
* message/joke?lang=<language code>: return a joke in the specified language ("en", "es", etc.) 
    or English if no code supplied or no joke exists in that language  
* anything else: sends the received input to STDOUT

Usage:
ruby myserver.rb
while myserver.rb is running, run in another shell:
  ruby myclient.rb (included in this directory)
Then in the shell running myclient, type in commands as described above.
=end

require 'gserver'

class MyServer < GServer
  def initialize(*args)
    super(*args)    
    # class variable to track how many clients have connected to this server
    # and assign each new one an incremented id
    @@client_id = 0
    # Array of fortunes
    @fortunes = ["You will learn a lot", "You will get an 'A'", "You still have much to learn, Grasshopper"]
    # Map language codes ("en", "es", "fr", etc.) to jokes, one joke per
    # language.
    @language2joke = {
      "en" => "Why did the chicken cross the road? To get to the other side!",
      "fr" => "Pourquoi le poulet a-t-il traverse la rue? Pour obtenir de l'autre cote!"
    }
  end

  # Serve content to a connected client. io_object is an instance of TCPSocket from myclient.rb
  def serve(io_object)
    # increase the client id for this new client and assign it 
    @@client_id += 1
    my_client_id = @@client_id
    io_object.sync = true

    puts("Client #{@@client_id} attached.")
    loop do
      # Must have chomp or else readline behaves very oddly (sends "\n" 
      # which messes up the user's next <Enter> keypress, which then causes a
      # chain reaction of very odd behavior)
      line = io_object.readline.chomp
      
      # Use a case statement to get the string to pass to io_object.puts
      io_string = case line
                  when 'x'
                    # 'x' causes the TCPSocket in myclient.rb to quit, so 
                    # notify us that it's quitting
                    puts "Exiting!"
                    "Goodbye!" # Bid a fond farewell to the TCPSocket
                  when /^(t|time)$/ # match "t" or "time"
                    "The time of day is #{get_time}"
                  when %r{^(f|message/fortune)$} # match "f" or "message/fortune"
                    get_fortune
                  when /^d(.+)/ # the regex captures the filename in $1
                    # when sending "d" followed by filename ("dtest.txt"), respond with
                    # content of e.g. test.txt
                    # If the file doesn't exist, returns a message saying so.
                    filename = $1
                    if File.exist?(filename)
                      File.readlines(filename).gsub("\n", " ")
                    else
                      "Error: file #{filename} does not exist."
                    end
                  when 'date'
                    get_date
                  when %r{^message/joke(?:\?lang=(.+))?$} # match "message/joke" or "message/joke?lang=..."
                    # The regex captures the lang value in $1
                    # Default to english if no lang supplied
                    language = $1.nil? ? "en" : $1
                    get_joke(language)
                  else
                    # Output to STDOUT first
                    puts "received line #{line}"
                    "What does #{line} mean anyway?"
                  end
      io_object.puts(io_string)
    end
  end

  # Returns date like "06/02/10 05:45:49 PM"
  def get_date
    Time.new.strftime("%D %r")
  end

  # Returns time like "05:45:49 PM"
  def get_time
    Time.new.strftime("%r")
  end

  # Return a joke in the specified language. If no joke exists in that language,
  # return one in english.
  def get_joke(language = "en")
    if @language2joke.key?(language)
      return @language2joke[language]
    else
      # default to english
      return @language2joke["en"]
    end
  end

  # Send a random fortune to the client
  def get_fortune
    @fortunes.sample # sample method is 1.9 only
  end
end

puts "Starting to listen for a connection on port 8888"
server = MyServer.new(8888)
server.start
server.join
