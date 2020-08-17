# rubocop:disable Metrics/LineLength
MEAN = { 'H' => 'Hearts', 'D' => 'Diamonds',
         'C' => 'Clubs', 'S' => 'Spades' }

TOP_VALUE = 21

module Promptable
	def prompt(message)
		puts "=> #{message}"
	end
end

module Joinable
	def join_and(type = "all")
		cards = hand.cards.map do |sub_array|
			"#{sub_array[1]} of #{MEAN[sub_array[0]]}"
		end
		return cards[0] if self.class == Dealer && type != "all"
		return cards.join if hand.cards.size == 1
		*rest, last = cards
		"#{rest.join(', ')} and a #{last}"
	end
end

class Player
	attr_accessor :score, :hand

	def total_value
		hand.total_value
	end

	def add_aces(total_value, aces)
		if 11 + total_value > TOP_VALUE
			aces.each { |_| total_value += 1 }
		elsif !aces.empty?
			total_value = (aces.size - 1).times { total_value += 1 } + 11
		end
		total_value
	end

	def continue
		prompt "Press the return key to continue"
		gets
	end

	def hit(deck)
		new_card = deck.pick_card
		if self.class == Participant
			puts "The dealer hits you with a #{new_card.join_and}"
			continue
		end
		hand.push(new_card)
	end

	def total
		hand.total_value
	end

	def busted?
		return true if hand.total_value > TOP_VALUE
		false
	end

	include Joinable
end

class Dealer < Player
	COMPUTER_TOP_VALUE = 17

	include Promptable

	def move(deck)
		system('clear')
		puts "------The Dealer Moves------"
		move_sequence(deck)
		puts "The dealer chose to stay!"
		prompt "Press the enter key to find out who won!"
		gets
	end

	def move_sequence(deck)
		loop do
			value = hand.total_value
			hit(deck) if value < COMPUTER_TOP_VALUE
			break if value >= COMPUTER_TOP_VALUE
			puts "The dealer chose to hit!"
		end
	end
end

class Participant < Player
	attr_reader :name, :hand

	include Promptable

	def initialize
		ask_for_name
	end

	def move(deck)
		move = ask_for_move
		if ["h", "hit"].include?(move)
			hit(deck)
		else
			"stay"
		end
	end

	private

	def ask_for_move
		move = nil
		loop do
			prompt "Would you like to (h)it or (s)tay?"
			move = gets.chomp.downcase
			break if ["h", "s", "hit", "stay"].include?(move)
			prompt "Invalid input! Please type: 'h', 'hit', 's' or 'stay'."
		end
		move
	end

	def ask_for_name
		name = nil
		loop do
			prompt "What is your name?"
			name = gets.chomp
			break unless name.empty?
			puts "You must type something!"
		end
		@name = name
		system('clear')
	end
end

class Deck
	SUITS = %w(H D S C)
	VALUES = %w(2 3 4 5 6 7 8 9 Jack King Queen Ace)
	MEAN = { 'H' => 'Hearts', 'D' => 'Diamonds',
	         'C' => 'Clubs', 'S' => 'Spades' }

	attr_reader :deck

	def initialize
		cards = SUITS.product(VALUES)
		@deck = cards.map do |array|
			Card.new(array)
		end
	end

	def initialize_hand
		Hand.new(pick_card, pick_card)
	end

	def pick_card
		deck.shuffle.shift
	end
end

class Card
	attr_reader :descriptions

	def initialize(square)
		@descriptions = square
	end

	def [](idx)
		descriptions[idx]
	end

	def join_and
		cards = [descriptions].map do |sub_array|
			"#{sub_array[1]} of #{MEAN[sub_array[0]]}"
		end
		cards[0]
	end
end

class Hand
	attr_accessor :cards

	def initialize(card1, card2)
		@cards = [card1, card2]
	end

	def total_value
		numbers = []
		cards.each { |set| numbers.push(set[1]) }
		words, numbers = numbers.partition { |card| %w(Jack King Queen Ace).include?(card) }
		aces, others = words.partition { |card| card == "Ace" }
		numbers.push(others.map { |_| '10' }).flatten!
		numbers.map!(&:to_i) unless numbers.empty?
		total_value = numbers.empty? ? 0 : numbers.reduce(&:+)
		add_aces(total_value, aces)
	end

	def push(new_card)
		cards.push(new_card)
	end

	private

	def add_aces(total_value, aces)
		if 11 + total_value > TOP_VALUE
			aces.each { |_| total_value += 1 }
		elsif !aces.empty?
			total_value = (aces.size - 1).times { total_value += 1 } + 11
		end
		total_value
	end
end

class Game
	attr_reader :user, :dealer, :deck, :games

	def initialize
		@user = Participant.new
		@dealer = Dealer.new
		@games = how_many_games
	end

	include Promptable

	def game_round
		initialize_hands
		loop do
			clear
			display_hands
			break if user.move(deck) == "stay" || user.busted?
		end
		dealer.move(deck) unless user.busted?
		winner = return_winner
		display_winner(winner)
		continue
	end

	def play_match
		clear
		loop do
			game_round
			update_score(return_winner)
			break if someone_won?
			clear
			display_stats
		end
	end

	def play_series
		clear
		display_welcome_message
		loop do
			reset_game
			play_match
			final_message
			break unless play_again?
		end
		display_goodbye_message
	end

	private

	def display_goodbye_message
		puts "Thanks for playing Tic Tac Toe #{user.name}! Goodbye."
	end

	def play_again?
		answer = nil
		loop do
			prompt "Would you like to play again?"
			answer = gets.chomp.downcase
			break if %w(y n yes no).include?(answer)
			puts "Invalid input! Please put: y, n, yes, no"
		end
		return_boolean(answer)
	end

	def return_boolean(answer)
		if %(y, yes).include?(answer)
			true
		else
			false
		end
	end

	def final_message
		clear
		puts "The final score was the dealer with #{dealer.score} points and #{user.name} with #{user.score} points!"
		if user == 5
			puts "Congratulation! You won!"
		else
			puts "Better luck next time!"
		end
	end

	def update_score(winner)
		user.score += 1 if winner == "User"
		dealer.score += 1 if winner == "Dealer"
	end

	def display_stats
		puts "The dealer has #{dealer.score} points, and you have #{user.score} points."
		puts "You are #{games - user.score} points away from winning!"
		continue
	end

	def return_winner
		if user.total > TOP_VALUE
			'Dealer'
		elsif dealer.total > TOP_VALUE
			'User'
		elsif user.total > dealer.total
			'User'
		elsif dealer.total > user.total
			'Dealer'
		end
	end

	def continue
		prompt "Press the enter key to continue"
		gets
	end

	def reset_game
		user.score = 0
		dealer.score = 0
		@deck = Deck.new
	end

	def how_many_games
		answer = nil
		loop do
			puts "Lets play first to . . ."
			prompt "enter a number"
			answer = gets.chomp
			break if answer == answer.to_i.to_s && answer.to_i < 50 && answer.to_i > 0
			puts "Invalid input! Enter a whole number less than 50 and greater than 0!"
		end
		clear
		@games = answer.to_i
	end

	def someone_won?
		[user.score, dealer.score].include?(games)
	end

	def clear
		system('clear')
	end

	def dynamic_message(winner)
		return "You busted!" if user.total_value > TOP_VALUE
		return "The dealer busted!" if dealer.total_value > TOP_VALUE
		return "You won!" if winner == "User"
		return "You Lost!" if winner == "Dealer"
		"It was a tie!"
	end

	def display_winner(winner)
		clear
		puts dynamic_message(winner)
		puts "The dealer's cards were a #{dealer.join_and}."
		puts "Your cards were a #{user.join_and}."
		puts "The dealer's total was #{dealer.total} while your total was #{user.total}."
	end

	include Joinable

	def display_welcome_message
		puts "Let's play first to #{games} games of twenty-one!"
		continue
	end

	def initialize_hands
		user.hand = deck.initialize_hand
		dealer.hand = deck.initialize_hand
	end

	def display_hands
		clear
		puts "Your hand consists of a #{user.join_and}."
		puts "Your total hand value is #{user.hand.total_value}."
		puts "The dealer has a #{dealer.join_and('one')} and an unknown card."
	end
end
# rubocop:enable Metrics/LineLength

system('clear')
puts "Welcome to Twenty-One!"
Game.new.play_series