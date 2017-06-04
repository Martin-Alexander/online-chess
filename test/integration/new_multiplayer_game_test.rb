require 'test_helper'

class NewMultiplayerGameTest < ActionDispatch::IntegrationTest
  test "page correctly" do
  	login_as users(:martin)
    visit "/lobbies/new"
    if page.status_code == 304
    	assert_equal 304, page.status_code
    else
	    assert_equal 200, page.status_code
    end
  end
end
