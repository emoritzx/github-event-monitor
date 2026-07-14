class EventPollerJob < ApplicationJob
    queue_as :default

    def perform()
        logger.info "Submitting request for events"
        EventRequestPublisher.new.publish
    end
end
