require 'test_helper'

class MamaburgerTest < ActionDispatch::IntegrationTest
	test "can create game" do
		number_of_games = Game.count
		Game.create white: User.find_by(email: "martin"), black: User.find_by(email: "mamaburger")
		assert_equal 1, Game.count - number_of_games
	end

	test "can view new game" do 
		login_as users(:martin)
		test_game = Game.create(white: User.find_by(email: "martin"), black: User.find_by(email: "mamaburger"))
		visit "/games/#{test_game.id}"

		assert_equal 200, page.status_code
	end
end
