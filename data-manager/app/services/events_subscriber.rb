require 'json'

# Subscribes to events
class EventsSubscriber

  attr_accessor :config

  # Constructor
  def initialize
    @config = {
      exchange: "events",
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      queue: "data_manager",
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
    @queue_name = "#{@config[:exchange]}_#{@config[:queue]}"
  end

  # Subscribe to events, calling :onsubscribe when a message is received
  #
  # Event data is assumed to be `application/json`
  def subscribe(onsubscribe)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(@config[:exchange])
    queue = channel.quorum_queue(@queue_name).bind(exchange)

    Rails.logger.info "Waiting for #{@config[:exchange]} messages"

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      Rails.logger.info "Received #{@config[:exchange]} message"
      data = JSON.parse(body)
      onsubscribe.call(data)
      channel.ack(delivery_info.delivery_tag)
    end

    connection.close
  end
end
