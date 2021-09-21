# frozen_string_literal: true

require 'pry-byebug'
class SECRET_WORD
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
    word
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
word = SECRET_WORD.new
