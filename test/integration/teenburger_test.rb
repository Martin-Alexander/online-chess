require 'test_helper'

class TeenburgerTest < ActionDispatch::IntegrationTest
	test "can create game" do
		number_of_games = Game.count
		Game.create white: User.find_by(email: "martin"), black: User.find_by(email: "teenburger")
		assert_equal 1, Game.count - number_of_games
	end

	test "can view new game" do 
		login_as users(:martin)
		test_game = Game.create(white: User.find_by(email: "martin"), black: User.find_by(email: "teenburger"))
		Board.create(game: test_game)
		visit "/games/#{test_game.id}"

		assert_equal 200, page.status_code
	end
end
