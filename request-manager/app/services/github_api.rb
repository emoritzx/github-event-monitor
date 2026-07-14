require 'net/http'

class GithubApi

  def initialize(options)
    @options = options
  end

  def get_base_url
    "#{@options[:scheme]}://#{@options[:domain]}:#{@options[:port]}"
  end

  def request(path)

    base_url = get_base_url
    path = "/#{path}" if not path.start_with? "/"
    full_uri = "#{base_url}#{path}"
    uri = URI.parse(full_uri)

    Rails.logger.info "Calling API: #{uri}"
    request = Net::HTTP::Get.new(uri.to_s)

    # Set appropriate headers
    #
    # TODO: Use "ETag" header appropriately.
    # If no new events have been triggered, you will see a "304 Not Modified" response,
    # and your current rate limit will be untouched.
    #
    # TODO: Use "X-Poll-Interval" header, which dynamically specifies how often
    # you are allowed to poll, based on server load.
    #
    # NOTE: Both of these headers are specific to the Events API
    #
    # See:
    #   - https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api?apiVersion=2026-03-10
    #   - https://docs.github.com/en/rest/activity/events?apiVersion=2026-03-10
    headers = {
      "Accept": "application/vnd.github+json",
      "X-GitHub-Api-Version": "2026-03-10",
      "User-Agent": @options[:user_agent]
    }

    response = Net::HTTP.get_response(uri, headers)

    Rails.logger.info "Response code: #{response.code}"
    Rails.logger.info "Rate limit remaining: #{response['x-ratelimit-remaining']}"

    response
  end
end
