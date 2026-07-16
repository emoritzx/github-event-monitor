class EventRawHandler

    def initialize(client, logger = Rails.logger)
        @client = client
        @index = "events"
        @logger = logger
    end

    def handle(event)
        @logger.debug "Storing raw event data for event #{event["id"]}"
        # TODO: change to use bulk API
        # TODO: handle duplicates
        @client.index(index: @index, id: event["id"], body: event)
    end

end
