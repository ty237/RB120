# rubocop:disable Metrics/LineLength, Metrics/MethodLength

class Player
  attr_accessor :move, :name, :move_history, :num_of_moves

  CHOICES = %w(rock paper scissors lizard spock)

  def initialize
    set_name
    self.move_history = []
    self.num_of_moves = 0
  end

  def update_history
    self.num_of_moves += 1
    self.move_history += ["Move #{num_of_moves}: #{move}"]
  end

  def choose
    update_history
  end
end

class Human < Player
  SIMPLE_CHOICES = %w(r p s l sp)
  def set_name
    name = ""
    system('clear')
    loop do
      puts "What's your name?"
      name = gets.chomp
      system('clear')
      break unless name.empty? || name.length > 5
      puts "Sorry, must enter a value shorter than 10 characters."
    end
    self.name = name
  end

  def ask_for_input
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard or spock."
      choice = gets.chomp.downcase
      break if CHOICES.include?(choice) || SIMPLE_CHOICES.include?(choice)
      system('clear')
      puts "That was invalid, please enter rock, paper, scissors, lizard, or spock."
    end
    choice
  end

  def choose
    choice = ask_for_input
    self.move = Move.new(input_to_choice(choice))
    super
  end

  def input_to_choice(choice)
    return "spock" if choice == "sp"
    CHOICES.each { |word| choice = word if word[0] == choice }
    choice
  end
end

class Computer < Player
end

class Ron < Computer
  OPTIONS = ["lizard", "lizard", "spock"]
  def set_name
    self.name = "Ron"
  end

  def choose
    self.move = Move.new(OPTIONS.sample)
    super
  end
end

class Harry < Computer
  OPTIONS = ["rock", "rock", "paper", "scissors", "scissors"]
  def set_name
    self.name = "Harry"
  end

  def choose
    self.move = Move.new(OPTIONS.sample)
    super
  end
end

class Hermione < Computer
  OPTIONS = ["rock", "paper", "paper", "scissors", "lizard", "spock"]
  def set_name
    self.name = "Hermione"
  end

  def choose
    self.move = Move.new(OPTIONS.sample)
    super
  end
end

class Move
  attr_accessor :type, :enemies

  ENEMIES = {
      "paper" => %w(lizard scissors),
      "scissors" => %w(rock spock),
      "rock" => %w(spock paper),
      "spock" => %w(lizard paper),
      "lizard" => %w(rock scissors)
  }
  def initialize(type)
    self.type = type
    self.enemies = ENEMIES[type]
  end

  def >(opponent_type)
    # winning is true, losing is false
    !enemies.include?(opponent_type.type)
  end

  def to_s
    type
  end
end

class RPSGame
  attr_accessor :human, :computer, :human_score, :computer_score

  def initialize
    @human = Human.new
    @computer = [Ron, Hermione, Harry].sample.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock! Lets play first to 5 points."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def display_winner(winner)
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    puts "The winner is #{winner}!"
  end

  def find_winner(human_choice, computer_choice)
    return "nobody because it is a tie" if human_choice.type == computer_choice.type
    return (human.name).to_s if human_choice > computer_choice
    (computer.name).to_s
  end

  def display_score
    puts "#{computer.name} has #{computer_score} points."
    puts "#{human.name} has #{human_score}."
    puts "You are #{5 - human_score} points away from winning!"
  end

  def update_score(winner)
    self.human_score += 1 if winner == human.name
    self.computer_score += 1 if winner == computer.name
  end

  def display_final_score
    if human_score == 5
      puts "Congratulations you are the grand winner!"
    else
      puts "You lost the whole match, better luck next time!"
    end
    puts "The final score was:"
    puts "#{human.name} => #{human_score}"
    puts "#{computer.name} => #{computer_score}."
  end

  def valid?(answer)
    return true if ["y", "yes", "n", "no"].include?(answer)
    false
  end

  def continue
    puts "Press any key to continue"
    gets
    system('clear')
  end

  def play_game
    human.choose
    computer.choose
    system('clear')
    find_winner(human.move, computer.move)
  end

  def display_history
    system('clear')
    puts "-----#{human.name}-----"
    puts human.move_history
    puts "-----#{computer.name}-----"
    puts computer.move_history
    continue
  end

  def view_history_options
    answer = nil
    loop do
      puts "Would you like to view your move history?"
      answer = gets.chomp.downcase
      break if valid?(answer)
      system('clear')
      puts "That was invalid, please enter y, n, yes, or no."
    end
    display_history if ['y', 'yes'].include?(answer)
    system('clear')
  end

  def play_match
    system('clear')
    loop do
      winner = play_game
      display_winner(winner)
      continue
      view_history_options
      update_score(winner)
      break if [human_score, computer_score].include?(5)
      display_score
      continue
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again?"
      answer = gets.chomp.downcase
      break if valid?(answer)
      system('clear')
      puts "Invalid input! Please enter y, yes, n, no."
    end
    return true if ["y", "yes"].include?(answer)
    false
  end

  def reset_move_histories
    human.move_history = []
    computer.move_history = []
    computer.num_of_moves = 0
    human.num_of_moves = 0
  end

  def play
    system('clear')
    display_welcome_message
    continue
    loop do
      self.human_score = 0
      self.computer_score = 0
      play_match
      display_final_score
      break unless play_again?
      reset_move_histories
    end
    display_goodbye_message
  end
end

# rubocop:enable Metrics/LineLength, Metrics/MethodLength
new_game = RPSGame.new
new_game.play
