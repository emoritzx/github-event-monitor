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
                    return page_number
                end
            end
        end

        nil
    end

    # Extract the next page number from a GitHub pagination link
    def extract_page(link)
        /\bpage=(?<page>[0-9]+)\b/.match(link)["page"]
    end
end
