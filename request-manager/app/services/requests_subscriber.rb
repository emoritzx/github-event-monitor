# Subscribes to requests
class RequestsSubscriber

  attr_accessor :config, :requests_per_minute

  # Constructor
  def initialize(requests_per_minute)
    @config = {
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      topic: "requests",
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
    @requests_per_minute = requests_per_minute
    @sleep_amount = 60 / requests_per_minute
  end

  # Subscribe to event requests
  #
  # A single event request is processed at a time,
  # which allows the subscribe loop to abide by the rate limit
  # by sleeping (see :requests_per_minute).
  def subscribe(onsubscribe)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    queue = channel.quorum_queue(@config[:topic])

    channel.prefetch(1)
    Rails.logger.info "Waiting for #{@config[:topic]} messages"

    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
      Rails.logger.info "Received #{@config[:topic]} message"
      onsubscribe.call(body)
      sleep @sleep_amount
      channel.ack(delivery_info.delivery_tag)
    end

    connection.close
  end
end
