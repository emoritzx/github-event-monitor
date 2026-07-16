require "logger"
require "minitest/autorun"
require_relative "../../app/services/github_api"

class MockResponse

    attr_accessor :code

    def initialize(code, headers)
        @code = code
        @headers = headers
    end

    def [](index)
        @headers[index]
    end
end

class MockHttpClient

    # Basically returns the input
    def MockHttpClient.get_response(uri, headers)
        return MockResponse.new(200, headers)
    end
end

class MockHttpClientWithEtag

    ETAG = "ABCDEF"

    # Basically returns the input
    def MockHttpClientWithEtag.get_response(uri, headers)
        headers["ETag"] = MockHttpClientWithEtag::ETAG
        return MockResponse.new(200, headers)
    end
end

class GithubApiTest < Minitest::Test

    def test_request_header_user_agent_set
        options = {
            domain: "example.com",
            port: 80,
            scheme: "http",
            user_agent: "minitest"
        }
        logger = Logger.new("/dev/null")
        client = MockHttpClient

        api = GithubApi.new(options, logger, client)

        path = "/"
        response = api.request(path)

        assert response[:"User-Agent"]
        assert_equal response[:"User-Agent"], options[:user_agent]
    end

    def test_request_header_api_version_set
        options = {
            domain: "example.com",
            github_api_version: "4",
            port: 80,
            scheme: "http",
            user_agent: "minitest"
        }
        logger = Logger.new("/dev/null")
        client = MockHttpClient

        api = GithubApi.new(options, logger, client)

        path = "/"
        response = api.request(path)

        assert response[:"X-GitHub-Api-Version"]
        assert_equal response[:"X-GitHub-Api-Version"], options[:github_api_version]
    end

    def test_request_header_accept_set
        options = {
            domain: "example.com",
            github_api_version: "4",
            port: 80,
            scheme: "http",
            user_agent: "minitest"
        }
        logger = Logger.new("/dev/null")
        client = MockHttpClient

        api = GithubApi.new(options, logger, client)

        path = "/"
        response = api.request(path)

        assert response[:"Accept"]
        assert_equal response[:"Accept"], "application/vnd.github+json"
    end

    def test_request_header_if_none_match_set
        options = {
            domain: "example.com",
            github_api_version: "4",
            port: 80,
            scheme: "http",
            user_agent: "minitest"
        }
        logger = Logger.new("/dev/null")
        client = MockHttpClientWithEtag

        api = GithubApi.new(options, logger, client)

        path = "/"
        _first_response = api.request(path)
        second_response = api.request(path)

        assert second_response["If-None-Match"]
        assert_equal second_response["If-None-Match"], MockHttpClientWithEtag::ETAG
    end
end
