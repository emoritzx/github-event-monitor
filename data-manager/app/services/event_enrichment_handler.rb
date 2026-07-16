# Makes follow-on requests for additional data related to events
class EventEnrichmentHandler

    # Constructor
    def initialize(request_publisher)
        @publisher = request_publisher
    end

    # Request additional data for the event
    def handle(event)
        enrich(event, "actor", "url")
    end

    # Extract the URL from a specific field of the event
    # and publish a follow-on request to the GitHub API
    def enrich(event, top_field_name, url_field_name)
        Rails.logger.debug "Enriching event #{event["id"]}"
        top_field = event[top_field_name]
        if top_field
            url_field = top_field[url_field_name]
            if url_field
                begin
                    uri = URI.parse(url_field)
                    path = uri.path
                    @publisher.publish(path)
                rescue URI::InvalidURIError
                    Rails.logger.error "Could not parse URL: #{url_field}"
                end
            end
        end
    end
end
