require 'elasticsearch'

# Job for starting the events subscriber service
class EventsSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the events exchange
    # - persists raw event data
    # - persists structured event data
    # - detects pagination
    # - publishes event request for the next page
    def perform()

        rabbitmq_config = {
            host: ENV["RABBITMQ_HOST"],
            password: ENV["RABBITMQ_DEFAULT_PASS"],
            user: ENV["RABBITMQ_DEFAULT_USER"]
        }

        events_subscriber = ResponseSubscriber.new(rabbitmq_config, "events")
        request_publisher = RequestPublisher.new(rabbitmq_config, "requests")

        elasticsearch_client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_HOSTNAME'])
        event_raw_handler = EventRawHandler.new(elasticsearch_client)

        event_structured_handler = EventStructuredHandler.new
        event_enrichment_handler = EventEnrichmentHandler.new(request_publisher)
        paginator = EventsPaginator.new

        events_subscriber.subscribe(lambda { |message|

            events = message["body"]
            logger.info "Received a page of #{events.length} events"

            # detect pagination
            next_page, path = paginator.paginate(message)
            if next_page && path
                logger.info "Requesting next event page (#{next_page})"
                request_publisher.publish(path)
            end

            for event in events
                # TODO: Refactor this to use routing keys
                if event["type"] == "PushEvent"
                    event_raw_handler.handle(event)
                    event_structured_handler.handle(event)
                    event_enrichment_handler.handle(event)
                else
                    logger.debug "Skipping event #{event["id"]} of type #{event["type"]}"
                end
            end
        })
    end
end
