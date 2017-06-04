require 'test_helper'

class NewMultiplayerGameTest < ActionDispatch::IntegrationTest
  test "page correctly" do
  	login_as users(:martin)
    visit "/lobbies/new"
    assert_equal 200, page.status_code
  end
end
