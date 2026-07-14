# Job for starting the event request publishing service
class EventPollerJob < ApplicationJob
    queue_as :default

    # Starts the event request publishing service
    #
    # The event request is published a single time.
    # There are no follow-on requests or periodic polling,
    # despite the name of this application.
    def perform()
        logger.info "Submitting request for events"
        EventRequestPublisher.new.publish
    end
end
