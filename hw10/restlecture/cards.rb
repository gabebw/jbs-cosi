#!/usr/bin/env ruby

=begin
Name: Gabe Berke-Williams
Date: 6/15/10
HW: 10
cards.rb

Description: Allows user to create/read/update/delete cards; interfaces with assoc/ Rails app.

Usage:
cards.rb add <name> [ <home number> <office number> ]
- Add a new new card, optionally with 2 phone numbers

cards.rb delete <name>
- Delete the first card with the given name.

cards.rb view [ * | <name> ]
- View all cards or a card with the specified name. Pretty-prints results in an attractive text table.

cards.rb change <name> <newname> [ <home number> <office number> ]
- Change fields in card with given name to newname; optionally change phone numbers too.

cards.rb search <regexp>
- Search for cards whose name matches the regexp. Pretty-prints results in a text table.

cards.rb seed <int>
- Generate a specified number of fake cards and numbers with randomly-generated names and phone numbers.
=end

require 'rubygems'
require 'httparty'

# For pretty ASCII tables.
require 'terminal-table/import'

class CardUtil
  include HTTParty
  base_uri 'localhost:3000'

  # Create a new card with given name, home_phone, and office_phone
  def add(name, home_phone = nil, office_phone = nil)
    card_opts = {:name => name}
    card_opts[:home_phone] = home_phone unless home_phone.nil?
    card_opts[:office_phone] = office_phone unless office_phone.nil?
    # Use :body instead of :query for posting
    # http://groups.google.com/group/httparty-gem/browse_thread/thread/f5ff17697177d9d8?pli=1
    options = {:body => {:card => card_opts } }
    self.class.post("/cards.xml", options)
  end
 
  # Delete first card whose name is _name_.
  def delete(name)
    id = name_to_id(name)
    puts "Deleting card with ID #{id}."
    self.class.delete("/cards/#{id}.xml")
  end
 
  # Update card with name _name_ and change its attributes to 
  # newname, new_home_phone, new_office_phone (phone numbers are optional)
  def update(name, newname, new_home_phone = nil, new_office_phone = nil)
    id = name_to_id(name)
    card_opts = { :name => newname }
    card_opts[:home_phone] = new_home_phone unless new_home_phone.nil?
    card_opts[:office_phone] = new_office_phone unless new_office_phone.nil?

    options = { :body => {:card => card_opts} }
    self.class.put("/cards/#{id}.xml", options)
  end

  # Search for a card by regexp. Returns all cards whose name matches the
  # regexp.
  def search(regexp)
    all_cards = get_all_cards
    matched_cards = all_cards.select { |card| card['name'] =~ regexp }
    pretty_print matched_cards
  end

  # num_to_seed = How many random cards should be created?
  def seed(num_to_seed)
    puts "Adding #{num_to_seed} random cards to the database."
    # Add num_to_seed random cards to the database
    num_to_seed.to_i.times do
      add(generate_name, generate_phone_number, generate_phone_number)
    end
  end

  # View card(s) with specified name ("*" = view all cards)
  def view(name)
    if name == '*'
      response = self.class.get("/cards.xml")
      cards = response.parsed_response['cards']
    else
      id = name_to_id(name)
      response = self.class.get("/cards/#{id}.xml")
      # singular "card"
      cards = response.parsed_response['card']
    end
    pretty_print cards
  end

  private # everything below this is private

  # Return an array of all cards
  def get_all_cards
    cards = self.class.get("/cards.xml").parsed_response['cards']
    return cards
  end

  # EXTREMELY inefficient - parses all cards until we get one with the correct
  # name. Assumes names are unique.
  def name_to_id(name)
    all_cards = get_all_cards
    target_card = all_cards.detect {|c| c['name'] == name }
    if target_card.nil?
      return nil
    else
      return target_card['id']
    end
  end
  
  # Pretty print card result set in a table.
  # Takes an array of card hashes.
  def pretty_print(cards)
    return if cards.nil?

    cards = [cards] unless cards.instance_of?(Array)
    pretty_table = table do |t|
      t.headings = cards.first.keys
      cards.each do |card|
        t << card.values
      end
    end
    puts pretty_table
  end

  # Generate a name for seeding
  def generate_name
    ('a'..'z').to_a.shuffle[0..7].join
  end

  # Generate a phone number for seeding
  def generate_phone_number
    return (0..9).to_a.sample(10).join.to_i
  end

end

cu = CardUtil.new

if ARGV.empty?
  puts "Must provide a command."
  exit 1
end

command = ARGV[0]

case command
when 'add'
  name, home_phone, office_phone = ARGV[1..3]
  cu.add(name, home_phone, office_phone)
when 'delete'
  name = ARGV[1]
  cu.delete(name)
when 'view'
  name = ARGV[1]
  cu.view(name)
when 'change'
  name, newname, home_phone, office_phone = ARGV[1..4]
  cu.update(name, newname, home_phone, office_phone)
when 'search'
  regexp = Regexp.new(ARGV[1])
  cu.search(regexp)
when 'seed'
  # How many random cards should be created?
  number_to_create = ARGV[1]
  cu.seed(number_to_create)
else
  puts "#{command} is not a valid command."
end
