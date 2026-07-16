require 'net/http'
require 'lru_cache'

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
  def initialize(options, logger, client = Net::HTTP)
    @client = client
    @options = options
    @logger = logger
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

    @logger.info "Calling API: #{uri}"

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
      "X-GitHub-Api-Version": @options[:github_api_version],
      "User-Agent": @options[:user_agent]
    }

    # If a previous request had an ETag header, send the If-None-Match header.
    # If no new data exists for the request, the API returns a "304 Not Modified" response,
    # and your current rate limit will be untouched.
    old_etag = @etag_cache[path]
    if old_etag
        @logger.debug "Cached ETag #{old_etag} found for path #{path}"
        headers["If-None-Match"] = old_etag
    end

    response = @client.get_response(uri, headers)

    # Cache the new ETag, if any
    new_etag = response["ETag"]
    if new_etag
      @etag_cache[path] = new_etag
      @logger.debug "ETag #{new_etag} cached for path #{path}"
    end

    @logger.info "Response code: #{response.code}"

    # Normally, I would log this as DEBUG, but it is important to the task
    # to verify that the system is abiding by the rate limit
    @logger.warn "Rate limit remaining: #{response['x-ratelimit-remaining']}"

    response
  end
end
