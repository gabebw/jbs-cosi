# This program will listen on port 8888
# Whenever a client connects to it, it returns a new fortune

require 'socket'               # Get sockets from stdlib
# require fortune program
require 'exercise2.rb'

fortune = Fortune.new

server = TCPServer.open(8888)  # Socket to listen on port 2000
loop {                         # Servers run forever
  client = server.accept       # Wait for a client to connect
  client.puts(fortune.next_fortune) # Send a fortune to the client
  client.puts "Closing the connection. Bye!"
  client.close                 # Disconnect from the client
}
