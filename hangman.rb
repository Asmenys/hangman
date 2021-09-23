# frozen_string_literal: false

require 'json'
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
  attr_reader :secret_word

  def initialize(secret_word)
    @secret_word = secret_word
    board_length = secret_word.length
    @board = Array.new(board_length) { '_' }
    @correct_guesses = []
    @incorrect_guesses = []
  end

  def display_board
    system 'clear'
    temp_board = @board.join(' ')
    puts "Correct guesses: #{@correct_guesses}"
    puts "Incorrect guesses: #{@incorrect_guesses}"
    puts temp_board
  end

  def check_for_win
    @board.none?('_')
  end

  def check_for_loss
    @incorrect_guesses.length == 7
  end

  def player_turn
    # get player input
    puts 'Make an input consisting of a single alphabetic character'
    player_input = gets.chomp
    # validate player input
    player_input = retake_player_input unless player_input_valid?(player_input) == true
    update_board(compare_player_input(player_input), player_input)
    display_board
  end

  def save_game
    save_file = File.open('save_file.json', 'w')
    save_file.write(JSON.dump(self))
  end

  def to_json(_options)
    {
      board: @board,
      incorrect_guesses: @incorrect_guesses,
      correct_guesses: @correct_guesses,
      secret_word: @secret_word
    }.to_json
  end

  def self_from_json
    if File.exist?('save_file.json')
      data = JSON.parse(File.read('save_file.json'))
      @board = data['board']
      @incorrect_guesses = data['incorrect_guesses']
      @correct_guesses = data['correct_guesses']
      @secret_word = data['secret_word']
      display_board
    else p 'No save file to load from'
    end
  end

  private

  def retake_player_input
    puts 'Input has already been guessed or is incorrect in its ....'
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
    test_results << @correct_guesses.none?(player_input)
    test_results << @incorrect_guesses.none?(player_input)
    test_results.all?(true)
  end

  def compare_player_input(player_input)
    /[#{player_input}]/i.match?(@secret_word)
  end

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

hangman_game = Hangman.new(SecretWord.new.word)
puts 'Do you want to load a previous game? [Y/n]'
player_input = gets.chomp
hangman_game.self_from_json if /^y/i.match?(player_input)
turn = 0
loop do
  unless turn.zero?
    puts 'Save? [Y/n]'
    player_save_choice = gets.chomp
    hangman_game.save_game if /^y/i.match?(player_save_choice)
  end
  hangman_game.player_turn
  turn += 1
  if hangman_game.check_for_loss == true
    puts 'You have lost the game'
    puts "The secret word was: #{hangman_game.secret_word}"
    break
  elsif hangman_game.check_for_win == true
    puts 'Congratulations, you have won'
    break
  end
end
