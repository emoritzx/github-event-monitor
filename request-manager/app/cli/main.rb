#!/usr/bin/env ruby

require 'bunny'
require_relative '../services/github_api'
require_relative '../services/requests_handler'
require_relative '../services/requests_subscriber'
require_relative '../services/response_publisher'

def main

    $stdout.sync = true
    requests_per_minute = ENV["GITHUB_API_REQUESTS_PER_MINUTE"].to_i
    subscriber = RequestsSubscriber.new(requests_per_minute)

    options = {
        domain: ENV["GITHUB_API_DOMAIN"],
        port: ENV["GITHUB_API_PORT"],
        scheme: ENV["GITHUB_API_SCHEME"],
        user_agent: ENV["GITHUB_API_USER_AGENT"]
    }

    api = GithubApi.new(options)
    publisher = ResponsePublisher.new
    handler = RequestsHandler.new(api, publisher)

    puts "Waiting for requests..."
    subscriber.subscribe(lambda { |message|
        handler.handle(message)
    })

end

main if __FILE__ == $PROGRAM_NAME
