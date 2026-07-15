# Job for starting the event request publishing service
class EventPollerJob < ApplicationJob
    queue_as :default

    # Starts the event request publishing service
    #
    # The initial event request is published a single time.
    # There are no follow-on requests or periodic polling,
    # despite the name of this application.
    #
    # Subscribes to the events queue to detect pagination
    # and publishes additional event requests for the next page.
    def perform()

        requests_publisher = EventRequestPublisher.new
        events_subscriber = EventsSubscriber.new
        paginator = EventsPaginator.new
        page_size = ENV["GITHUB_API_PAGE_SIZE"]

        logger.info "Submitting initial request for events"
        requests_publisher.publish(1, page_size)

        logger.info "Listening for events pagination messages"
        events_subscriber.subscribe(lambda { |message|
            logger.info "Received events"
            next_page = paginator.paginate(message)
            if next_page
                logger.info "Requesting next page (#{next_page})"
                requests_publisher.publish(next_page, page_size)
            end
        })
    end
end
