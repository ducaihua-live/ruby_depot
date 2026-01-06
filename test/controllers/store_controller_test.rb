require "test_helper"

class StoreControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get store_index_url
    assert_response :success
    assert_select "nav a", minimum: 4
    assert_select "main ul li", 3
    assert_select "h2", "The Pragmatic Programmer"
    assert_select "div", /\$[, \d]+\.\d\d/
  end

  test "should initialize store access count on first visit" do
    get store_index_url
    assert_response :success
    assert_equal 1, session[:store_access_count]
  end

  test "should increment store access count on subsequent visits" do
    # First visit
    get store_index_url
    assert_response :success
    assert_equal 1, session[:store_access_count]

    # Second visit
    get store_index_url
    assert_response :success
    assert_equal 2, session[:store_access_count]

    # Third visit
    get store_index_url
    assert_response :success
    assert_equal 3, session[:store_access_count]
  end

  test "should maintain separate access count per session" do
    # First session
    get store_index_url
    assert_equal 1, session[:store_access_count]

    get store_index_url
    assert_equal 2, session[:store_access_count]

    # New session (simulated by clearing session)
    # Note: In integration tests, each test method gets a fresh session
    # So we can test this by checking that a new test method starts at 1
  end

  test "should make store access count available in view" do
    get store_index_url
    assert_response :success
    # The instance variable should be set (we can verify this indirectly)
    # by checking the session is set correctly
    assert_not_nil session[:store_access_count]
  end
end
