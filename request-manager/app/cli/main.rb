#!/usr/bin/env ruby

require 'logger'
require 'bunny'

require_relative '../services/github_api'
require_relative '../services/requests_handler'
require_relative '../services/requests_subscriber'
require_relative '../services/response_publisher'

def main

    $stdout.sync = true
    log_level = ENV.fetch("LOG_LEVEL", "info")
    logger = Logger.new($stdout, level: log_level)
    logger.progname = "request-manager"

    rabbitmq_base_config = {
        host: ENV["RABBITMQ_HOST"],
        password: ENV["RABBITMQ_DEFAULT_PASS"],
        user: ENV["RABBITMQ_DEFAULT_USER"]
    }

    requests_subscriber_config = {
        exchange: "requests",
        queue: "request_manager",
        requests_per_minute: ENV.fetch("GITHUB_API_REQUESTS_PER_MINUTE", 1).to_i
    }.merge(rabbitmq_base_config)

    subscriber = RequestsSubscriber.new(requests_subscriber_config, logger)

    github_options = {
        domain: ENV["GITHUB_API_DOMAIN"],
        port: ENV["GITHUB_API_PORT"],
        scheme: ENV["GITHUB_API_SCHEME"],
        user_agent: ENV["GITHUB_API_USER_AGENT"]
    }

    api = GithubApi.new(github_options, logger)
    publisher = ResponsePublisher.new(rabbitmq_base_config, logger)
    handler = RequestsHandler.new(api, publisher, logger)

    logger.info "Waiting for requests..."
    subscriber.subscribe(lambda { |message|
        handler.handle(message)
    })

    logger.close
end

main if __FILE__ == $PROGRAM_NAME
