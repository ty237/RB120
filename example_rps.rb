class Move
	attr_reader :value

	VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

	def initialize(value)
		@value = value
	end

	def >(other_move)
		@beats.include?(other_move.to_s)
	end

	def to_s
		@value
	end
end

# ------------------------------

class Rock < Move
	def initialize
		@value = 'rock'
		@beats = ['scissors', 'lizard']
	end
end
# ---------------------------

class Spock < Move
	def initialize
		@value = 'spock'
		@beats = ['rock', 'scissors']
	end
end
# ---------------------------

class Lizard < Move
	def initialize
		@value = 'lizard'
		@beats = ['spock', 'paper']
	end
end
# ---------------------------

class Paper < Move
	def initialize
		@value = 'paper'
		@beats = ['rock', 'spock']
	end
end
# ---------------------------

class Scissors < Move
	def initialize
		@value = 'scissors'
		@beats = ['lizard', 'paper']
	end
end

# ----------------------------

class Scoreboard
	attr_reader :human_score, :computer_score

	def initialize
		@human_score = 0
		@computer_score = 0
	end

	def update(player)
		@human_score += 1 if player.class == Human
		@computer_score += 1 if player.class != Human
	end

	def display(human, computer)
		puts "#{human}'s Score: #{human_score}"
		puts "#{computer}'s Score: #{computer_score}"
		puts
	end

	def winner?
		@human_score == 3 || @computer_score == 3
	end

	def reset
		@human_score = 0
		@computer_score = 0
	end
end

# -------------------------------

class Player
	attr_accessor :move, :name, :move_history, :turn

	def initialize
		@move = nil
		set_name
		@move_history = []
		@turn = 1
	end

	OBJECTS = { 'rock' => Rock.new, 'paper' => Paper.new,
	            'scissors' => Scissors.new, 'spock' => Spock.new,
	            'lizard' => Lizard.new }

	def add_to_history
		move_history << "Turn #{turn}: #{move}"
		@turn += 1
	end

	def display_history
		puts "#{name} = #{move_history}"
	end

	def reset_history
		@move_history = []
		@turn = 1
	end
end

# ------------------------------

class Human < Player
	def set_name
		system 'clear'
		puts "What's your name, human?"
		answer = gets.chomp
		self.name = answer
		system 'clear'
	end

	def choose
		choice = nil
		loop do
			puts "Please choose Rock, Paper, Scissors, Spock or Lizard:"
			choice = gets.chomp.downcase
			break if Move::VALUES.include?(choice)
			puts "Sorry, Invalid choice. Please try again."
		end
		self.move = OBJECTS[choice]
		add_to_history
		system 'clear'
	end
end

# -------------------------------
class Computer < Player
	attr_accessor :name
end

# ------------------------------
# Never chooses the same object twice in a row
class R2D2 < Computer
	def set_name
		@name = 'R2D2'
	end

	def choose
		self.move = OBJECTS.values.select do |object|
			object.class != move.class
		end.sample

		add_to_history
	end
end

# ------------------------------
# Always chooses between Spock and Lizard
class OptimusPrime < Computer
	def set_name
		@name = 'Optimus Prime'
	end

	def choose
		self.move = [Spock.new, Lizard.new].sample
		add_to_history
	end
end
# ------------------------------
# Always chooses a rock

class WallE < Computer
	def set_name
		@name = 'WALL-E'
	end

	def choose
		self.move = Rock.new
		add_to_history
	end
end
# ------------------------------

class RPSGame
	attr_accessor :human, :computer, :scoreboard

	def initialize
		@human = Human.new
		@computer = [OptimusPrime.new, R2D2.new, WallE.new].sample
		@scoreboard = Scoreboard.new
	end

	def display_greeting_message
		puts "Welcome to Rock, Paper, Scissors, Spock, Lizard."
		sleep 2
		system 'clear'
	end

	def display_moves
		puts "You chose: #{human.move}"
		puts "#{computer.name} chose: #{computer.move}"
		sleep 2
		system 'clear'
	end

	def display_winner
		winner = nil
		if human.move > computer.move
			winner = human
		elsif computer.move > human.move
			winner = computer
		else
			return puts "It's a tie!"
		end
		scoreboard.update(winner)
		puts "#{winner.name} won!"
	end

	def display_goodbye_message
		system 'clear'
		puts "Thank you for playing, #{human.name}. Goodbye!"
	end

	def play_again?
		answer = nil
		loop do
			puts "Would you like to play again #{human.name}? y for yes, n for no."
			answer = gets.chomp
			break if ['y', 'n'].include?(answer.downcase)
			puts 'Must be y or n'
		end

		return true if answer.downcase == 'y'
	end

	def display_scoreboard
		scoreboard.display(human.name, computer.name)
	end

	def display_histories
		human.display_history
		puts
		computer.display_history
		puts
	end

	def reset
		scoreboard.reset
		human.reset_history
		computer.reset_history
		system 'clear'
	end

	def game_round
		human.choose
		computer.choose
		display_moves
		display_winner
		display_scoreboard
		display_histories
		sleep 4
		system 'clear'
	end

	def play
		display_greeting_message
		loop do
			loop do
				game_round
				break if scoreboard.winner?
			end
			break unless play_again?
			reset
		end
		display_goodbye_message
	end
end

# ------------------------------

RPSGame.new.play