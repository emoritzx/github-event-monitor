# Subscribes to requests
class RequestsSubscriber

  attr_accessor :config, :requests_per_minute

  # Constructor
  def initialize(config, logger)
    @config = config
    @logger = logger
    requests_per_minute = @config[:requests_per_minute].to_i
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
  # The message is not ACK'd until the onsubscribe method succeeds.
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

    @logger.info "Waiting for #{@config[:exchange]} messages"

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      @logger.debug "Received #{@config[:exchange]} message"
      do_sleep = onsubscribe.call(body)
      channel.ack(delivery_info.delivery_tag)
      if do_sleep
        @logger.debug "Waiting #{@sleep_amount} seconds due to rate limits"
        sleep @sleep_amount
      end
    end

    connection.close
  end
end
