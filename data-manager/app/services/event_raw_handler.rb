class EventRawHandler

    def initialize(client)
        @client = client
        @index = "events"
    end

    def handle(event)
        Rails.logger.debug "Storing raw event data for event #{event["id"]}"
        # TODO: change to use bulk API
        # TODO: handle duplicates
        @client.index(index: @index, id: event["id"], body: event)
    end

end
