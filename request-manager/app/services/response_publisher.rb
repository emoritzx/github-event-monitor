# Publishes responses to the message broker
class ResponsePublisher

  attr_accessor :config

  # Constructor
  def initialize(config, logger)
    @config = config
    @logger = logger
  end

  # Publish the response message to the given exchange
  def publish(exchange_name, message)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(exchange_name)

    options = {
      content_type: "application/json"
    }

    exchange.publish(message, options)
    @logger.info "Published response message to exchange #{exchange_name}"

    connection.close
  end
end
