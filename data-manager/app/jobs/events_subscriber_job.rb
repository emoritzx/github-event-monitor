require 'elasticsearch'

# Job for starting the events subscriber service
class EventsSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the events queue
    # - persists raw event data
    # - persists structured event data
    # - detects pagination
    # - publishes event request for the next page
    def perform()

        elasticsearch_client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_HOSTNAME'])
        event_raw_handler = EventRawHandler.new(elasticsearch_client)
        event_structured_handler = EventStructuredHandler.new
        events_subscriber = EventsSubscriber.new
        paginator = EventsPaginator.new
        requests_publisher = RequestPublisher.new

        logger.info "Listening for events"
        events_subscriber.subscribe(lambda { |message|

            events = message["body"]
            logger.info "Received a page of #{events.length} events"

            # detect pagination
            next_page, path = paginator.paginate(message)
            if next_page && path
                logger.info "Requesting next event page (#{next_page})"
                requests_publisher.publish(path)
            end

            for event in events
                if event["type"] == "PushEvent"
                    event_raw_handler.handle(event)
                    event_structured_handler.handle(event)
                else
                    logger.debug "Skipping event #{event["id"]} of type #{event["type"]}"
                end
            end
        })
    end
end
