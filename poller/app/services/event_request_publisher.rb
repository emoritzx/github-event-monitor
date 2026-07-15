# Publishes event requests to the message broker
class EventRequestPublisher

  attr_accessor :config

  # Constructor
  def initialize
    @config = {
      exchange: "requests",
      host: ENV["RABBITMQ_HOST"],
      password: ENV["RABBITMQ_DEFAULT_PASS"],
      user: ENV["RABBITMQ_DEFAULT_USER"]
    }
  end

  # Publish the event request
  def publish(page_number = 1, page_size = 15)

    message = "/events?page=#{page_number}&per_page=#{page_size}"

    connection = Bunny.new(
      :host => @config[:host],
      :pass => @config[:password],
      :user => @config[:user]
    )

    connection.start

    channel = connection.create_channel
    exchange = channel.fanout(@config[:exchange])

    options = {
      content_type: "text/plain"
    }

    exchange.publish(message, options)
    Rails.logger.info "published message to exchange #{@config[:exchange]}"

    connection.close
  end
end
