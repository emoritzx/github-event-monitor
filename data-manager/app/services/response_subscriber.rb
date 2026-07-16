require 'json'

# Subscribes to GitHub API responses
class ResponseSubscriber

  attr_accessor :config

  # Constructor
  def initialize(config, exchange_name, logger = Rails.logger)
    @config = config
    @exchange_name = exchange_name
    @logger = logger
    @queue_name = "#{exchange_name}_data_manager"
  end

  # Subscribe to responses on the configured exchange,
  # calling :onsubscribe when a message is received
  #
  # Response data is assumed to be `application/json`
  def subscribe(onsubscribe)

    @logger.debug "Connecting to #{@exchange_name} exchange"

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(@exchange_name)
    queue = channel.quorum_queue(@queue_name).bind(exchange)

    @logger.info "Listening for #{@exchange_name}..."

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      @logger.debug "Received #{@exchange_name} message"
      data = JSON.parse(body)
      onsubscribe.call(data)
      channel.ack(delivery_info.delivery_tag)
    end

    connection.close
  end
end
