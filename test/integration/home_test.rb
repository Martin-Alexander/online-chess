require 'test_helper'

class HomeTest < ActionDispatch::IntegrationTest
  test "page loads correctly" do
    visit "/"
    if page.status_code == 304
    	assert_equal 304, page.status_code
    else
	    assert_equal 200, page.status_code
    end
  end
end
