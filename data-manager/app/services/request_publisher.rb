# Publishes GitHub API requests to the message broker
class RequestPublisher

  attr_accessor :config

  # Constructor
  def initialize(config, exchange, logger = Rails.logger)
    @config = config
    @exchange_name = exchange
    @logger = logger
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
    exchange = channel.fanout(@exchange_name)

    options = {
      content_type: "text/plain"
    }

    exchange.publish(message, options)
    @logger.info "Published to #{@exchange_name}: #{message}"

    connection.close
  end
end
