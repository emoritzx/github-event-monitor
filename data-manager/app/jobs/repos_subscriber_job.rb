require 'elasticsearch'

# Job for starting the repos subscriber service
class ReposSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the repos exchange
    def perform()

        rabbitmq_config = {
            host: ENV["RABBITMQ_HOST"],
            password: ENV["RABBITMQ_DEFAULT_PASS"],
            user: ENV["RABBITMQ_DEFAULT_USER"]
        }

        exchange_name = "repos"
        elasticsearch_index = "repos"

        elasticsearch_client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_HOSTNAME'])
        repos_subscriber = ResponseSubscriber.new(rabbitmq_config, exchange_name)

        repos_subscriber.subscribe(lambda { |message|

            repo = message["body"]
            repo_id = repo["id"]
            repo_name = repo["full_name"]

            logger.info "Received repo #{repo_name} (#{repo_id})"

            elasticsearch_client.index(index: elasticsearch_index, id: repo_id, body: repo)
        })
    end
end
