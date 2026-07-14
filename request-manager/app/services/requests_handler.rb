# Business logic for handling a request message
class RequestsHandler

  # Constructor
  def initialize(api, publisher)
    @api = api
    @publisher = publisher
  end

  # Given a request message, calls the GitHub API
  # and publishes the response to the appropriate topic.
  def handle(message)
    response = @api.request(message)
    topic = get_topic(message)
    Rails.logger.info "Publishing response to #{topic}"
    @publisher.publish(topic, response.body)
  end

  # Extracts the topic name from the original message
  def get_topic(message)
    /^\/?(?<api>[a-zA-Z0-9]+)/.match(message)["api"]
  end
end
