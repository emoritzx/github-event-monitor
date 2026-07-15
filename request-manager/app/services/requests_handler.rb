require 'json'

# Business logic for handling a request message
class RequestsHandler

  # Constructor
  def initialize(api, publisher)
    @api = api
    @publisher = publisher
  end

  # Given a request message, calls the GitHub API
  # and publishes the response to the appropriate topic.
  #
  # Returns `true` if the message was handled in a way
  # that should cause the caller to wait before calling again.
  #
  # TODO: Better return values
  # TODO: Handle error responses
  # TODO: Do we need to worry about redirects?
  def handle(message)

    response = @api.request(message)

    case response
    when Net::HTTPNotModified
      Rails.logger.info "Data not modified since last request"
      false
    when Net::HTTPSuccess
      exchange = get_exchange(message)
      data = {
        path: message,
        headers: response.to_hash,
        body: JSON.parse(response.body)
      }
      Rails.logger.info "Publishing response to #{exchange}"
      @publisher.publish(exchange, data.to_json)
      true
    else
      Rails.logger.error "Unhandled HTTP response #{response.code}"
      Rails.logger.debug response
      true
    end
  end

  # Extracts the exchange name from the original message
  def get_exchange(message)
    /^\/?(?<api>[a-zA-Z0-9]+)/.match(message)["api"]
  end
end
