# Job for starting the event request publishing service
class EventPollerJob < ApplicationJob
    queue_as :default

    # Starts the event request publishing service
    #
    # The initial event request is published a single time.
    # There are no follow-on requests or periodic polling,
    # despite the name of this application.
    def perform()

        requests_publisher = EventRequestPublisher.new
        page_size = ENV["GITHUB_API_PAGE_SIZE"]

        logger.info "Submitting initial request for events"
        requests_publisher.publish(1, page_size)
    end
end
