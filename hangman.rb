# frozen_string_literal: false

require 'pry-byebug'

# Picks a random word out of a given word list
class SecretWord
  attr_reader :word

  def initialize
    @word = random_word
  end

  def random_line_index
    word_list_length = `wc -l 'word_list.txt'`.split[0].to_i
    (rand * word_list_length).floor
  end

  def random_word
    word = find_word_at_line(random_line_index)
    word = random_word if verify_word(word) == false
    word.downcase
  end

  def verify_word(word)
    word.length >= 5 && word.length <= 12 && word.instance_of?(String)
  end

  def find_word_at_line(line_index)
    # binding.pry
    File.open('word_list.txt') do |word|
      (line_index - 1).times { word.gets }
      word.gets.chomp
    end
  end
end

# the core game i guess
class Hangman
  def initialize(secret_word)
    @secret_word = secret_word
    board_length = secret_word.length
    @board = Array.new(board_length) { '_' }
    @correct_guesses = []
    @incorrect_guesses = []
  end

  def display_board
    temp_board = @board.join(' ')
    puts "Correct guesses: #{@correct_guesses}"
    puts "Incorrect guesses: #{@incorrect_guesses}"
    temp_board
  end

  def player_input
    # get player input
    puts 'Make an input consisting of a single alphabetic character'
    player_input = gets.chomp
    # validate player input
    player_input = retake_player_input unless player_input_valid?(player_input) == true
    update_board(compare_player_input(player_input), player_input)
    display_board
  end

  def retake_player_input
    puts 'MAKE AN INPUT CONSISTING OF ONLY A SINGULAR ALPHABETIC CHARACTER'
    player_input = gets.chomp
    if player_input_valid?(player_input)
      player_input
    else
      retake_player_input
    end
  end

  def player_input_valid?(player_input)
    test_results = []
    test_results << (player_input.length == 1)
    test_results << /^[a-z]+$/i.match?(player_input)
    test_results.all?(true)
  end

  def compare_player_input(player_input)
    /[#{player_input}]/i.match?(@secret_word)
  end
  # what is this supposed to do lol

  def update_board(comparison_results, player_input)
    if comparison_results == false
      @incorrect_guesses << player_input
    else
      @correct_guesses << player_input
      string_to_array(@secret_word).each_with_index do |char, index|
        @board[index] = char if char == player_input
      end
    end
  end

  def string_to_array(string)
    result_array = []
    string.each_char do |char|
      result_array << char
    end
    result_array
  end
end
