#!/usr/bin/env ruby

=begin
github-fortunes.rb
Author: Gabe B-W
HW 10: cloud storage assignment.

Description:
The worst abuse of Github since git-tweets. Uses Github commit messages as fortune cookie messages.

Usage:
  github-fortunes.rb [-r | -p cookie_text | -g cookie_id]"
    -r: get a random cookie.
    -p cookie_text: Store a cookie with cookie_text. Prints the cookie ID after storing.
    -g cookie_id: Print the cookie with ID cookie_id
=end

# octopi is a GitHub API ruby binding. Note that it breaks on Ruby 1.9.2.
# http://github.com/fcoury/octopi/
require 'octopi'
require 'fileutils'

class GitFortuneCookieStore
  include Octopi
 
  # Initiates connection to git. The repo_name will be created if it doesn't
  # exist yet.
  def initialize(user = nil, api_token = nil, repo_name = "cookie_monster") 
    if user.nil?
      puts "No user provided, getting from git config"
      user = `git config --get github.user`.chomp
    end

    if api_token.nil?
      puts "No API token provided, getting from git config"
      api_token = `git config --get github.token`.chomp
    end


    @user = user.chomp # chomp in case user passes in bad data
    @api_token = api_token.chomp # chomp in case user passes in bad data
    @repo_name = repo_name

    # Authenticated client
    #@client = Octopussy::Client.new({:login => @user, :token => @api_token})

    # Location of local git repository. Necessary for pushing to Github.
    # Put it in .cloud_path so it doesn't conflict with anything
    @git_dir_path = File.expand_path("~/.cloud_path/" + @repo_name)

    create_repo
    create_git_dir
  end

  # Create the repo @repo_name if it doesn't exist yet.
  def create_repo
    begin
      repo = Repository.find(:user => @user, :name => @repo_name)
    rescue Octopi::NotFound
      # repo doesn't exist
      repo = nil
    end
    if repo.nil?
      authenticated_with :login => @user, :token => @api_token do
        # Get an array of all of @user's repos' names
        # @repo_name doesn't exist yet. Now create it.
        Repository.create({:name => @repo_name})
      end
    end
  end

  # _text_ is the text of a fortune cookie
  # Prints SHA1 hash to identify the cookie
  # Returns SHA1 hash.
  def store(fortune_cookie_text)
    hash = msg(fortune_cookie_text)
    puts "Stored cookie: #{fortune_cookie_text}"
    puts "Cookie ID: #{hash}"
    return hash
  end
 
  # Returns text of fortune cookie with hash cookie_hash.
  # If the cookie_hash doesn't map to a commit, returns nil.
  def get(cookie_hash)
    begin
      commit = Commit.find(:user => @user, :repo => @repo_name, :sha => cookie_hash)
      return commit.message
    rescue Octopi::NotFound
      puts "Requested cookie does not exist."
      return nil
    end
  end

  # Return text of a random cookie. If no fortunes have been created, returns
  # nil.
  def get_random
    repo = Repository.find(:user => @user, :repo => @repo_name)
    begin
      all_commit_messages = repo.commits.map(&:message)
      # Return randomly-selected commit message
      return all_commit_messages[rand(all_commit_messages.length)]
    rescue Octopi::NotFound
      # No commits have been made
      puts "No commits have been made for this repo."
      return nil
    end
  end

  private
  # Pushes _message_ to github and returns the SHA1 hash that identifies the message
  def msg(message)
    FileUtils.cd(@git_dir_path)
	# via http://ozmm.org/posts/git_msg.html
    `git commit --allow-empty -m "#{message}" &>/dev/null`
    # Use sed to extract SHA1 hash from most recent log message
    hash = `git log master~1..master | sed -n '/commit/s/commit //p'`.chomp
    # Push to Github
    `git push origin master &>/dev/null`
    return hash
  end

  # Create git directory so we can push to Github
  def create_git_dir
    FileUtils.mkdir_p(@git_dir_path)
    FileUtils.cd(@git_dir_path)
    `git init &>/dev/null` # no effect if already initialized
    `git remote add origin git@github.com:#{@user}/#{@repo_name}.git &>/dev/null`
  end
end

def print_usage
  puts "Usage: #{$0} [-r] [-p cookie_text] [-g cookie_hash]"
  puts "-h: this help"
  puts "-r: get a random cookie."
  puts "-p cookie_text: Store a cookie with cookie_text. Prints the cookie ID after storing."
  puts "-g cookie_hash: Print the cookie with ID cookie_id"
end

monster = GitFortuneCookieStore.new

if ARGV.empty?
  puts "Please provide an argument."
  print_usage()
  exit 1
end

if ARGV.first == '-h'
  print_usage
  exit 0
end

command_flag = ARGV[0]
case command_flag
when '-r'
  # Get a random fortune
  fortune = monster.get_random
  puts "Your random fortune is: #{fortune}" unless fortune.nil?
when '-p'
  cookie_text = ARGV[1..-1]
  if cookie_text.nil?
    puts "Please provide cookie text."
    exit 1
  else
    monster.store(cookie_text.join(' '))
  end
when '-g'
  cookie_hash = ARGV[1]
  if cookie_hash.nil?
    puts "Please provide cookie hash."
    exit 1
  else
    cookie = monster.get(cookie_hash)
    puts "Your fortune is: #{cookie}" unless cookie.nil?
  end
else
  puts "Please provide a valid option."
end
