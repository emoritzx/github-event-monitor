require "test_helper"
require 'json'

# TODO: Figure out if minitest supports data providers for multiple test cases
class EventsPaginatorTest < ActiveSupport::TestCase

  test "extract next page number" do
    links = "<http://abc.com/blah?page=2>; rel=\"next\""
    expected = "2"
    paginator = EventsPaginator.new
    message = JSON.parse({headers: {link: [links]}}.to_json)
    actual = paginator.paginate(message)
    assert_equal expected, actual
  end

  test "extract next page number w/ additional params" do
    links = "<http://abc.com/blah?page_size=10&page=2&status=green>; rel=\"next\""
    expected = "2"
    paginator = EventsPaginator.new
    message = JSON.parse({headers: {link: [links]}}.to_json)
    actual = paginator.paginate(message)
    assert_equal expected, actual
  end

  test "extract next page number w/ multiple links" do
    links =  "<http://abc.com/blah?page=1>; rel=\"first\"," \
        "<http://abc.com/blah?page=2>; rel=\"prev\"," \
        "<http://abc.com/blah?page=4>; rel=\"next\"," \
        "<http://abc.com/blah?page=5>; rel=\"last\""
    expected = "4"
    paginator = EventsPaginator.new
    message = JSON.parse({headers: {link: [links]}}.to_json)
    actual = paginator.paginate(message)
    assert_equal expected, actual
  end

  test "last page" do
    links = "<http://abc.com/blah?page=1>; rel=\"first\"," \
        "<http://abc.com/blah?page=2>; rel=\"prev\"," \
        "<http://abc.com/blah?page=4>; rel=\"last\""
    paginator = EventsPaginator.new
    message = JSON.parse({headers: {link: [links]}}.to_json)
    actual = paginator.paginate(message)
    assert_nil actual
  end

end
