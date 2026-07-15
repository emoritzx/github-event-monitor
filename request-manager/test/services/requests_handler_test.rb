require "test_helper"

# TODO: Figure out if minitest supports data providers for multiple test cases
class RequestsHandlerTest < ActiveSupport::TestCase

  test "extract exchange /" do
    path = "/events"
    expected = "events"
    handler = RequestsHandler.new(nil, nil)
    actual = handler.get_exchange(path)
    assert_equal expected, actual
  end

  test "extract exchange no /" do
    path = "events"
    expected = "events"
    handler = RequestsHandler.new(nil, nil)
    actual = handler.get_exchange(path)
    assert_equal expected, actual
  end

  test "extract exchange multi /" do
    path = "/events/"
    expected = "events"
    handler = RequestsHandler.new(nil, nil)
    actual = handler.get_exchange(path)
    assert_equal expected, actual
  end

  test "extract exchange w/ params" do
    path = "/events?page=1"
    expected = "events"
    handler = RequestsHandler.new(nil, nil)
    actual = handler.get_exchange(path)
    assert_equal expected, actual
  end

end
