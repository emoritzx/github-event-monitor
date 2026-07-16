require 'elasticsearch'

# Job for starting the users subscriber service
class UsersSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the users exchange
    def perform()

        elasticsearch_client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_HOSTNAME'])
        users_subscriber = ResponseSubscriber.new("users")
        index = "users"

        logger.info "Listening for users"
        users_subscriber.subscribe(lambda { |message|

            user = message["body"]
            user_id = user["id"]
            user_name = user["login"]

            logger.info "Received user #{user_name} (#{user_id})"

            elasticsearch_client.index(index: index, id: user_id, body: user)
        })
    end
end
