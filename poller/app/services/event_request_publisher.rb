# Publishes event requests to the message broker
class EventRequestPublisher

  attr_accessor :config

  # Constructor
  def initialize
    @config = {
      host: ENV["RABBITMQ_HOST"],
      message: "/events",
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      topic: "requests",
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
  end

  # Publish the event request
  #
  # A single event request is published.
  def publish

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    queue = channel.quorum_queue(@config[:topic])

    channel.default_exchange.publish(@config[:message], routing_key: queue.name)
    Rails.logger.info "published message to queue #{queue.name}"

    connection.close
  end
end
