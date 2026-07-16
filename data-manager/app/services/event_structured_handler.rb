class EventStructuredHandler

    def handle(event)
        Rails.logger.debug "Storing structured event data for event #{event["id"]}"
        # TODO: handle duplicates
        payload = event["payload"]
        event_model = Event.new do |e|
            e.event_id = event["id"]
            e.repository_id = payload["repository_id"]
            e.push_id = payload["push_id"]
            e.ref = payload["ref"]
            e.head = payload["head"]
            e.before = payload["before"]
        end
        event_model.save
    end

end
