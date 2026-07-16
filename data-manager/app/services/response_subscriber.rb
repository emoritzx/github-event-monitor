require 'json'

# Subscribes to GitHub API responses
class ResponseSubscriber

  attr_accessor :config

  # Constructor
  def initialize(exchange_name)
    @config = {
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
    @exchange_name = exchange_name
    @queue_name = "#{exchange_name}_data_manager"
  end

  # Subscribe to responses on the configured exchange,
  # calling :onsubscribe when a message is received
  #
  # Response data is assumed to be `application/json`
  def subscribe(onsubscribe)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(@exchange_name)
    queue = channel.quorum_queue(@queue_name).bind(exchange)

    Rails.logger.info "Waiting for #{@exchange_name} messages"

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      Rails.logger.debug "Received #{@exchange_name} message"
      data = JSON.parse(body)
      onsubscribe.call(data)
      channel.ack(delivery_info.delivery_tag)
    end

    connection.close
  end
end
