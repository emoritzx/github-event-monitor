# Logic for paginating the Events API responses
class EventsPaginator

    # Returns follow-on page to request,
    # or `nil` if there are no more pages.
    #
    # TODO: There's gotta be a better way to parse this
    def paginate(message)

        headers = message["headers"]
        link_header = headers["link"]

        if link_header

            links = link_header[0].split(',')

            for link in links
                if link.include? 'rel="next"'
                    page_number = extract_page(link)
                    page_size = extract_page_size(link)
                    message = "/events?page=#{page_number}"
                    if page_size
                        message = "#{message}&per_page=#{page_size}"
                    end
                    return page_number, message
                end
            end
        end

        return nil, nil
    end

    # Extract the next page number from a GitHub pagination link
    def extract_page(link)
        matches = /\bpage=(?<page>[0-9]+)\b/.match(link)
        if matches
            matches["page"]
        else
            nil
        end
    end

    # Extract the page size from a GitHub pagination link
    def extract_page_size(link)
        matches = /\bper_page=(?<page_size>[0-9]+)\b/.match(link)
        if matches
            matches["page_size"]
        else
            nil
        end
    end
end
