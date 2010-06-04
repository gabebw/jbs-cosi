#!/usr/bin/env ruby

=begin
Author: Gabe Berke-Williams
6/4/10
HW: 3
postfix_to_infix.rb

Description: Converts a postfix string provided on the command line into infix
notation. Adds the minimum amount of parentheses necessary.

Usage:
ruby postfix_to_infix.rb '56 34 213.7 + * 678 -'
=> 56 * (34 + 213.7) - 678
=end

# An expression class, containing an operator, a left operand, and a right
# operand. The two operands may be Expressions.
class Expression
  attr_writer :do_parens

  def initialize(operator, left = nil, right = nil)
    @operator = operator
    @left = left
    @right = right
    # Should this Expression be wrapped in parens when shown as a string?
    @do_parens = false
  end

  # Test if the other_expresssion's operator has a lower precedence than this
  # one
  def has_lower_precedence?(other_expression)
    return precedence() > other_expression.precedence()
  end

  # Get the precedence of this Expression's operator
  def precedence
    case @operator
    when '+', '-'
      # addition and subtraction
      0
    when '*', '/'
      # multiplication and division
      1
    end
  end

  # Recursively traverse this expression and convert to string
  def to_s
    # Wrap the expression on the right in parentheses if the operation of the
    # expression on the right has a lower precedence than this Expression's.
    # e.g. 2 * (3 + 5) because without parentheses it becomes 6 + 5
    @right.do_parens = has_lower_precedence?(@right) if @right.class==Expression
    # Do the same for the left
    @left.do_parens = has_lower_precedence?(@left) if @left.class == Expression
    string = "#{@left} #{@operator} #{@right}"
    # Wrap in parentheses if necessary
    string = "(#{string})" if @do_parens
    return string
  end
end

class Postfix2Infix
  def initialize
    # Matches an operator that takes up the whole string
    @strict_operator_regex = %r{^[\+\-\*/]$}
    # Matches an operator anywhere in the string
    @loose_operator_regex = %r{[\+\-\*/]}
  end

  # Pass in the postfix string, e.g. "2 3 5 + *". Whitespace is optional, so you
  # can go "2 3 5+*". Obviously, "235 +*" will not work, since only one number
  # is provided (235).
  def parse(postfix_str)
    tokens = postfix_str.scan(%r{\d*\.?\d+|#{@loose_operator_regex}})
      # Loop through tokens and add operands to the stack. If we hit an operator, 
      # pop 2 items off the stack and create an Expression with that operator
      # and the 2 items as its operands. Keep looping until we run out of tokens
      # or hit invalid input. Eventually, stack will contain just one item, a
      # single expression representing the postfix string we passed in.
      stack = []
    while not tokens.empty?
      # get first item in tokens
      token = tokens.shift
      if token =~ @strict_operator_regex
        # Operator
        # pop off 2 elements (they may be expressions themselves)
        left, right = stack.pop(2)
        stack.push(Expression.new(token, left, right))
      elsif token =~ /^(\d+)?\.\d+$/
        # Float. Allows ".3" even though Ruby itself doesn't.
        token = '0' + token if $1.nil?  # ".3" => "0.3" for to_f
        stack.push(token.to_f)
      elsif token =~ /^\d+$/
        # Integer
        stack.push(token.to_i)
      else
        # Invalid input
        puts "Invalid input: #{token}, stopping parsing."
        return ""
      end
    end
    # The stack is just one element, the Expression. Convert to string and
    # return.
    stack.pop.to_s
  end
end

if ARGV.empty?
  puts "Must provide input, like '2 3 +'."
  exit 1
else
  str = ARGV[0]
  # Create an instance of the class
  p2i = Postfix2Infix.new
  puts p2i.parse(str)
end
