=begin
Author: Gabe Berke-Williams
HW02: myclient.rb
6/2/10

Description:
Displays a prompt: >>
When user types something in, this program connects to 0.0.0.0:8888 and sends the text.
Whatever comes back is displayed on the console.

Usage:
ruby myserver.rb (included)
while myserver.rb is running, run in another shell:
  ruby myclient.rb

Then in the shell running myclient:
Available commands are described in myserver.rb
>> <commands>
>> ...
>> x # exit
=end

require 'socket'

# Open socket to server listening to 0.0.0.0:8888
tcp_socket = TCPSocket.open('0.0.0.0', 8888)

loop do # Loop forever
  print ">> "
  # chomp so we can do command_string == .... rather than =~
  command_string = gets.chomp
  # Exit if user types in "x"
  if command_string == 'x'
    puts "client: exiting"
    break
  end
  # send command to server
  tcp_socket.puts(command_string)
  # Get response from server
  servers_resp = tcp_socket.readline
  puts servers_resp.to_s
end
