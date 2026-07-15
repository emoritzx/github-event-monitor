require 'net/http'
require 'lru_cache'
# require 'lru_cache/thread_safe'

# Service client for calling the GitHub API
#
# Responsible for constructing the full URL
# and setting the proper HTTP headers.
#
# Callers are expected to supply the path and any HTTP parameters.
#
# Callers are restricted to GET requests only.
class GithubApi

  # Constructor
  def initialize(options)
    @options = options
    # TODO: Figure out why ThreadSafe version not working
    # @etag_cache = LRUCache::ThreadSafe.new(1_000)
    @etag_cache = LRUCache.new(1_000)
  end

  # Construct base URL from environment
  def get_base_url
    "#{@options[:scheme]}://#{@options[:domain]}:#{@options[:port]}"
  end

  # Submit a GET request to the API for the specified path
  #
  # Prepends a leading slash if not present.
  # Configures the expected HTTP headers automatically.
  # Returns the response object without any processing or error handling.
  def request(path)

    base_url = get_base_url
    path = "/#{path}" if not path.start_with? "/"
    full_uri = "#{base_url}#{path}"
    uri = URI.parse(full_uri)

    Rails.logger.info "Calling API: #{uri}"
    request = Net::HTTP::Get.new(uri.to_s)

    # Set appropriate headers
    #
    # See:
    #   - https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api?apiVersion=2026-03-10
    #   - https://docs.github.com/en/rest/activity/events?apiVersion=2026-03-10
    #
    # TODO: Use "X-Poll-Interval" header, which dynamically specifies how often
    # you are allowed to poll, based on server load. This header is specific to the Events API.
    headers = {
      "Accept": "application/vnd.github+json",
      "X-GitHub-Api-Version": "2026-03-10",
      "User-Agent": @options[:user_agent]
    }

    # If a previous request had an ETag header, send the If-None-Match header.
    # If no new data exists for the request, the API returns a "304 Not Modified" response,
    # and your current rate limit will be untouched.
    old_etag = @etag_cache[path]
    if old_etag
        Rails.logger.debug "Cached ETag #{old_etag} found for path #{path}"
        headers["If-None-Match"] = old_etag
    end

    response = Net::HTTP.get_response(uri, headers)

    # Cache the new ETag, if any
    new_etag = response["ETag"]
    if new_etag
      @etag_cache[path] = new_etag
      Rails.logger.debug "ETag #{new_etag} cached for path #{path}"
    end

    Rails.logger.info "Response code: #{response.code}"
    Rails.logger.info "Rate limit remaining: #{response['x-ratelimit-remaining']}"

    response
  end
end
