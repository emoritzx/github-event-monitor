# Subscribes to requests
class RequestsSubscriber

  attr_accessor :config, :requests_per_minute

  # Constructor
  def initialize(requests_per_minute)
    @config = {
      exchange: "requests",
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      queue: "request_manager",
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
    @requests_per_minute = requests_per_minute
    @sleep_amount = 60 / requests_per_minute
    @queue_name = "#{@config[:exchange]}_#{@config[:queue]}"
  end

  # Subscribe to requests
  #
  # A single request is processed at a time,
  # which allows the subscribe loop to abide by the rate limit
  # by sleeping (see :requests_per_minute).
  #
  # Calls the provided onsubscribe method when a message is received.
  # The message is not ACK'd until the onsubscribe method succeeds
  # and the sleep timer has completed.
  def subscribe(onsubscribe)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    channel.prefetch(1)

    exchange = channel.fanout(@config[:exchange])
    queue = channel.quorum_queue(@queue_name).bind(exchange)

    puts "Waiting for #{@config[:exchange]} messages"

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      puts "Received #{@config[:exchange]} message"
      do_sleep = onsubscribe.call(body)
      if do_sleep
        puts "Waiting #{@sleep_amount} seconds due to rate limits"
        sleep @sleep_amount
      end
      channel.ack(delivery_info.delivery_tag)
    end

    connection.close
  end
end
