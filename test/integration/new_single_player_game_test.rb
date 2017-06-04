require 'test_helper'

class NewSinglePlayerGameTest < ActionDispatch::IntegrationTest
  test "page loads correctly" do
    visit "/games/new"
    assert_equal 200, page.status_code
  end
end
