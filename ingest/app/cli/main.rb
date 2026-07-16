#!/usr/bin/env ruby

require 'logger'
require 'bunny'

def main

    $stdout.sync = true
    log_level = ENV.fetch("LOG_LEVEL", "info")
    logger = Logger.new($stdout, level: log_level)
    logger.progname = "ingest"

    exchange_name = "requests"
    page_size = ENV.fetch("GITHUB_API_PAGE_SIZE", "100")
    message = "/events?page=1&per_page=#{page_size}"

    logger.info "Creating RabbitMQ connection..."

    connection = Bunny.new(
        :host => ENV["RABBITMQ_HOST"],
        :pass => ENV["RABBITMQ_DEFAULT_PASS"],
        :user => ENV["RABBITMQ_DEFAULT_USER"]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(exchange_name)

    options = {
        content_type: "text/plain"
    }

    logger.info "Publishing initial event request..."

    exchange.publish(message, options)

    logger.info "Published to #{exchange_name} exchange: #{message}"

    connection.close

    logger.info "Done."
    logger.close
end

main if __FILE__ == $PROGRAM_NAME
