# Job for starting the events subscriber service
class EventsSubscriberJob < ApplicationJob
    queue_as :default

    # Subscribes to the events queue
    # - persists raw event data
    # - persists structured event data
    # - detects pagination
    # - publishes event request for the next page
    def perform()

        requests_publisher = RequestPublisher.new
        events_subscriber = EventsSubscriber.new
        paginator = EventsPaginator.new

        logger.info "Listening for events"
        events_subscriber.subscribe(lambda { |message|
            logger.info "Received events"

            # TODO: persist raw event data

            # TODO: persist structured event data

            # detect pagination
            next_page, path = paginator.paginate(message)
            if next_page && path
                logger.info "Requesting next event page (#{next_page})"
                requests_publisher.publish(path)
            end
        })
    end
end
