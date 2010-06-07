#!/usr/bin/env ruby

=begin
Author: Gabe Berke-Williams
6/4/10
HW: 3
postfix_to_infix.rb

Description: Converts a postfix string provided on the command line into infix
notation. Adds the minimum amount of parentheses necessary to remove ambiguity.
Space is optional in the postfix string.
Available operators:
 +
 -
 *
 /
 ** (exponentiation)
 ^ (exponentiation)

Usage:
ruby postfix_to_infix.rb '56 34 213.7 + * 678 -'
=> 56 * (34 + 213.7) - 678
ruby postfix_to_infix.rb '2 3 5 4 + *'
=> Error: too many operands.
ruby postfix_to_infix.rb '2 3 + *'
=> Error: too many operators.
=end

# An expression class, containing an operator, a left operand, and a right
# operand. The two operands may be Expressions.
class Expression
  attr_writer :do_parens

  def initialize(operator, left = nil, right = nil)
    @operator = operator # e.g. +, -, *, /
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
    when '**', '^'
      # powers / roots (e.g. 2^(1/2))
      2
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

class UnbalancedExpressionError < Exception
  def initialize(msg = "unbalanced expression")
    super(msg)
  end
end

class Postfix2Infix
  def initialize
    # Matches an operator anywhere in the string
    #@loose_operator_regex = %r{[\+\-\*/]}
    @loose_operator_regex = %r{\+|\-|\*{1,2}|/|\^}
    # Matches an operator that takes up the whole string
    @strict_operator_regex = Regexp.new('^' + @loose_operator_regex.source + '$')
    # Matches: .3, 0.3 or 3.0
    @float_regex = /\d*\.\d+/
    # Matches 3 but not .3 or 3.0
    @integer_regex = /\d+(?!\.)/
    @number_regex = Regexp.union(@float_regex, @integer_regex)
  end

  # Pass in the postfix string, e.g. "2 3 5 + *". Whitespace is optional, so you
  # can go "2 3 5+*". Obviously, "235 +*" will not work, since only one number
  # is provided (235).
  # If the expression is unbalanced, raises an UnbalancedExceptionError.
  def parse(postfix_str)
    tokens = postfix_str.scan(Regexp.union(@number_regex, @loose_operator_regex))

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
        if stack.size < 2
          raise UnbalancedExpressionError, "too many operators"
        end
        left, right = stack.pop(2)
        stack.push(Expression.new(token, left, right))
      elsif token =~ /^#{@float_regex}$/
        # Float. Allows ".3" even though Ruby itself doesn't.
        token = '0' + token if $1.nil?  # ".3" => "0.3" so to_f doesn't raise a warning
        stack.push(token.to_f)
      elsif token =~ /^#{@integer_regex}$/
        # Integer
        stack.push(token.to_i)
      end
    end
    if stack.size != 1
      # Too many operands (e.g. "2 3 4 +"), raise appropriate error.
      raise UnbalancedExpressionError, "too many operands."
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
  str = ARGV.join(' ')
  # Create an instance of the class
  p2i = Postfix2Infix.new
  begin
    infix = p2i.parse(str)
    puts infix
  rescue UnbalancedExpressionError => bang
    puts "Error: #{bang}"
  end
end
