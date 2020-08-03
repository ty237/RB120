require 'pry'
# rubocop:disable Metrics/LineLength

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

module Joinable
  def join_or(array)
    if array.size == 1
      return array.join
    end
    *rest, last = array
    "#{rest.join(', ')} or #{last}"
  end
end

class Squares
  attr_accessor :board

  def initialize
    @board = initialize_board
  end

  def initialize_board
    new_board = {}
    (1..9).each { |num| new_board[num] = Square.new }
    new_board
  end

  def [](idx)
    board[idx].marker
  end

  def []=(idx, value)
    board[idx].marker = value
  end

  def keys
    board.keys
  end

  def markers_at(line)
    markers = []
    line = line.flatten
    board.values_at(*line).each do |square|
      markers.push(square.marker)
    end
    markers
  end
end

class Board
  attr_reader :squares

  INITIAL_MARKER = ' '
  def initialize
    @squares = Squares.new
    # what data structure should we use?
    # - array/hash of Square objects?c
    # - array/hash of strings or integers?
  end

  def display(computer_marker, user_marker)
    system 'clear'
    puts "You're a #{computer_marker}. Computer is a #{user_marker}."
    puts ""
    puts "     |     |"
    puts "  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}"
    puts "     |     |"
    puts ""
  end

  def markers_at(line)
    squares.markers_at(line)
  end

  def full?
    empty_squares.empty?
  end

  def empty_squares
    squares.keys.select { |num| squares[num] == INITIAL_MARKER }
  end

  def take_square(square, marker)
    squares[square] = marker
  end

  def [](index)
    squares[index]
  end

  def []=(index, new_value)
    squares[index] = new_value
  end

  def values_at(*args)
    squares.board.values_at(args)
  end

  def detect_winner(user_marker, computer_marker)
    WINNING_LINES.each do |line|
      return "User" if squares.markers_at(line).count(user_marker) == 3
      return "Computer" if squares.markers_at(line).count(computer_marker) == 3
    end
    nil
  end
end

class Square
  attr_accessor :marker

  INITIAL_MARKER = ' '
  def initialize
    @marker = INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :name
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class Human < Player
  include Joinable
  def initialize(marker)
    super
    @name = ask_for_name
  end

  def move(board)
    answer = nil
    loop do
      puts "Choose a square: #{join_or(board.empty_squares)}."
      answer = gets.chomp.to_i
      break if board.empty_squares.include?(answer)
      puts "Invalid input!"
    end
    board.take_square(answer, marker)
  end

  private

  def ask_for_name
    system('clear')
    name = nil
    loop do
      puts "What is your name?"
      name = gets.chomp
      break unless name.empty?
      clear
      puts "You must type something!"
    end
    name
  end
end

class Computer < Player
  def find_computer_marker(user_marker)
    if user_marker == "O"
      "X"
    else
      "O"
    end
  end

  def move(board)
    square = offensive_move(board) || defensive_move(board) || board.empty_squares.sample
    board.squares[square] = marker
  end

  private

  def user_marker
    marker == "X" ? "O" : "X"
  end

  def offensive_move(board)
    WINNING_LINES.each do |line|
      if board.markers_at(line).count(marker) == 2
        square = (line.select { |num| board[num] == ' ' }).join.to_i
        return square unless square == 0
      end
    end
    nil
  end

  def defensive_move(board)
    WINNING_LINES.each do |line|
      if board.markers_at(line).count(user_marker) == 2
        square = (line.select { |num| board[num] == ' ' }).join.to_i
        return square unless square == 0
      end
    end
    nil
  end
end

class TTTGame
  def play_round
    loop do
      board.display(computer.marker, user.marker) if current_player == "user"
      fill_square
      break if someone_won? || board.full?
      switch_player
    end
  end

  def play_game
    @board = Board.new
    self.current_player = go_first? ? "user" : "computer"
    play_round
    board.display(computer.marker, user.marker)
    board.detect_winner(user.marker, computer.marker)
  end

  def play_match
    clear
    loop do
      winner = play_game
      display_winner(winner)
      continue
      update_score(winner)
      break if [user.score, computer.score].include?(games)
      display_score
      continue
    end
  end

  def play_series
    clear
    how_many_games
    display_welcome_message
    loop do
      reset_scores
      play_match
      display_final_message(find_winner)
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  attr_reader :user, :computer, :board
  attr_accessor :current_player, :games

  def initialize
    human_marker = ask_for_marker
    computer_marker = determine_marker(human_marker)
    @user = Human.new(human_marker)
    @computer = Computer.new(computer_marker)
  end

  def continue
    puts "Press any key to continue"
    gets
    clear
  end

  def ask_for_marker
    marker = nil
    clear
    loop do
      puts "Would you like you marker to be an X or an O?"
      marker = gets.chomp.downcase
      break if %w(x o).include?(marker)
      clear
      puts "Invalid input!"
    end
    marker.upcase
  end

  def someone_won?
    !!board.detect_winner(user.marker, computer.marker)
  end

  def determine_marker(human_marker)
    human_marker == "X" ? "O" : "X"
  end

  def display_winner(winner)
    if winner == "User"
      puts "You won!"
    elsif winner == "Computer"
      puts "You lost."
    else
      puts "It was a tie!"
    end
  end

  def switch_player
    self.current_player = (current_player == "user" ? "computer" : "user")
  end

  def fill_square
    if current_player == "user"
      user.move(board)
    else
      computer.move(board)
    end
  end

  def update_score(winner)
    if winner == "User"
      user.score += 1
    elsif winner == "Computer"
      computer.score += 1
    end
  end

  def display_score
    puts "You have #{user.score} points."
    puts "The computer has #{computer.score} points."
    puts "You are #{games - user.score} points away from winnning."
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again?"
      answer = gets.chomp.downcase
      break if valid?(answer)
      clear
      puts "Invalid input! Please enter y, yes, n, no."
    end
    ["y", "yes"].include?(answer)
  end

  def valid?(answer)
    ["y", "yes", "n", "no"].include?(answer)
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe! Lets play first to #{games} games of tictactoe!"
    continue
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe #{user.name}! Goodbye!"
  end

  def how_many_games
    answer = nil
    loop do
      puts "Lets play first to . . ."
      puts "-enter a number"
      answer = gets.chomp
      break if answer == answer.to_i.to_s && answer.to_i < 50 && answer.to_i > 0
      puts "Invalid input! Enter a number less than 50 and greater than 0!"
    end
    clear
    self.games = answer.to_i
  end

  def clear
    system('clear')
  end

  def go_first?
    answer = nil
    loop do
      puts "Would you like to go first?"
      answer = gets.chomp
      break if valid?(answer)
      clear
      puts "That was invalid!"
    end
    return true if ["yes", "y"].include?(answer)
    false
  end

  def find_winner
    return "user" if user.score == games
    "computer"
  end

  def reset_scores
    user.score = 0
    computer.score = 0
  end

  def display_final_message(winner)
    puts "You are the grand winner!" if winner == "user"
    puts "You lost, better luck next time!" if winner == "computer"
    puts "The final score was #{user.name} with #{user.score} and the computer with #{computer.score} points."
  end
end

# rubocop:enable Metrics/LineLength
game = TTTGame.new
game.play_series
