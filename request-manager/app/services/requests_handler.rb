class RequestsHandler

  def initialize(api, publisher)
    @api = api
    @publisher = publisher
  end

  def handle(message)
    response = @api.request(message)
    topic = get_topic(message)
    Rails.logger.info "Publishing response to #{topic}"
    @publisher.publish(topic, response.body)
  end

  def get_topic(message)
    /^\/?(?<api>[a-zA-Z0-9]+)/.match(message)["api"]
  end
end
