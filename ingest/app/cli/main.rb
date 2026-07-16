#!/usr/bin/env ruby

require 'bunny'

def main
    publish_initial_request
end

# Publishes the initial event request to the message broker
def publish_initial_request

    exchange_name = "requests"
    message = "/events"

    puts "Creating RabbitMQ connection..."

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

    puts "Publishing initial event request..."

    exchange.publish(message, options)

    puts "Published message to exchange: #{exchange_name}"

    connection.close

    puts "Done."
end

main if __FILE__ == $PROGRAM_NAME
