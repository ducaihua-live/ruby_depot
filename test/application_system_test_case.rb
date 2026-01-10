require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use rack_test driver which doesn't require a browser
  # If you need JavaScript support, install cuprite gem and use: driven_by :cuprite
  driven_by :rack_test
end
