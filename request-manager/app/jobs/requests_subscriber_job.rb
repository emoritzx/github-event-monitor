# Job for starting the request subscriber service
class RequestsSubscriberJob < ApplicationJob
    queue_as :default

    # Configures and starts the request subscriber service
    def perform()

        requests_per_minute = ENV["GITHUB_API_REQUESTS_PER_MINUTE"].to_i

        subscriber = RequestsSubscriber.new(requests_per_minute)

        options = {
            domain: ENV["GITHUB_API_DOMAIN"],
            port: ENV["GITHUB_API_PORT"],
            scheme: ENV["GITHUB_API_SCHEME"],
            user_agent: ENV["GITHUB_API_USER_AGENT"]
        }

        api = GithubApi.new(options)
        publisher = ResponsePublisher.new
        handler = RequestsHandler.new(api, publisher)

        subscriber.subscribe(lambda { |message|
            Rails.logger.debug "onsubscribe: handling message"
            handler.handle(message)
        })
    end
end
