require 'elasticsearch'

# Job for starting the users subscriber service
class UsersSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the users exchange
    def perform()

        rabbitmq_config = {
            host: ENV["RABBITMQ_HOST"],
            password: ENV["RABBITMQ_DEFAULT_PASS"],
            user: ENV["RABBITMQ_DEFAULT_USER"]
        }

        exchange_name = "repos"
        elasticsearch_index = "repos"

        elasticsearch_client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_HOSTNAME'])
        users_subscriber = ResponseSubscriber.new(rabbitmq_config, exchange_name)

        users_subscriber.subscribe(lambda { |message|

            user = message["body"]
            user_id = user["id"]
            user_name = user["login"]

            logger.info "Received user #{user_name} (#{user_id})"

            elasticsearch_client.index(index: elasticsearch_index, id: user_id, body: user)
        })
    end
end
