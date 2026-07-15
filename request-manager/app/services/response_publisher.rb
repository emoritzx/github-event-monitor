# Publishes responses to the message broker
class ResponsePublisher

  attr_accessor :config

  # Constructor
  def initialize
    @config = {
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
  end

  # Publish the response message to the given topic
  def publish(topic, message)

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    queue = channel.quorum_queue(topic)

    options = {
      content_type: "application/json",
      routing_key: queue.name
    }
    channel.default_exchange.publish(message, options)
    Rails.logger.info "published response message to queue #{queue.name}"

    connection.close
  end
end
