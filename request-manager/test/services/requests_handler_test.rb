require "logger"
require "net/http"
require "minitest/autorun"
require_relative "../../app/services/requests_handler"

class MockApi

    def initialize(response)
        @response = response
    end

    def request(_data)
        @response
    end
end

class RequestsHandlerTest < Minitest::Test

    def test_not_modified_signal
        logger = Logger.new("/dev/null")
        response = Net::HTTPResponse::CODE_TO_OBJ['304'].new(nil, nil, nil)
        api = MockApi.new(response)
        handler = RequestsHandler.new(api, nil, logger)
        expected = false
        actual = handler.handle(nil)
        assert_equal actual, expected
    end

    def test_exchange_parsing_events
        handler = RequestsHandler.new(nil, nil, nil)
        message = "/events?page=2&per_page=20"
        expected = "events"
        actual = handler.get_exchange(message)
        assert_equal actual, expected
    end

    def test_exchange_parsing_repos
        handler = RequestsHandler.new(nil, nil, nil)
        message = "/repos/abc/def"
        expected = "repos"
        actual = handler.get_exchange(message)
        assert_equal actual, expected
    end

    def test_exchange_parsing_users
        handler = RequestsHandler.new(nil, nil, nil)
        message = "/users/abc"
        expected = "users"
        actual = handler.get_exchange(message)
        assert_equal actual, expected
    end

    def test_exchange_parsing_no_leading_slash
        handler = RequestsHandler.new(nil, nil, nil)
        message = "events?page=2&per_page=20"
        expected = "events"
        actual = handler.get_exchange(message)
        assert_equal actual, expected
    end
end
