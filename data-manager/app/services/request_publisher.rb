# Publishes GitHub API requests to the message broker
class RequestPublisher

  attr_accessor :config

  # Constructor
  def initialize
    @config = {
      exchange: "requests",
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
  end

  # Publish the request
  def publish(message)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(@config[:exchange])

    options = {
      content_type: "text/plain"
    }

    exchange.publish(message, options)
    Rails.logger.info "Published request: #{message}"

    connection.close
  end
end
