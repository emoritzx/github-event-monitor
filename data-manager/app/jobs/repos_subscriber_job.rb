require 'elasticsearch'

# Job for starting the repos subscriber service
class ReposSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the repos exchange
    def perform()

        elasticsearch_client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_HOSTNAME'])
        repos_subscriber = ResponseSubscriber.new("repos")
        index = "repos"

        logger.info "Listening for repos"
        repos_subscriber.subscribe(lambda { |message|

            repo = message["body"]
            repo_id = repo["id"]
            repo_name = repo["full_name"]
            logger.info "Received repo #{repo_name} (#{repo_id})"

            elasticsearch_client.index(index: index, id: repo_id, body: repo)
        })
    end
end
