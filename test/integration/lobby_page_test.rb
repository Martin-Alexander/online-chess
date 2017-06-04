require 'test_helper'

class LobbyPageTest < ActionDispatch::IntegrationTest
  test "page loads correctly" do
    visit "/lobbies"
    assert_equal 200, page.status_code
  end

  test "correctly displays no lobbies" do
    visit "/lobbies"
  	if Lobby.count.zero?
  		assert page.has_content? "No games in the lobby..."
  	end
  end

  test "correctly displays lobbies" do
		Lobby.create host: User.find_by(email: "martin"), nonhost: User.find_by(email: "player_two"), name: "Test Lobby"
  	visit "/lobbies"
		assert page.has_content? "Test Lobby"
  end
end
