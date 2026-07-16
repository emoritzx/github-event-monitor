# Request Manager

This service is responsible for subscribing to GitHub API requests
and responsibly sending them without violating rate limits.

This service subscribes to the `requests` queue
and publishes the response to the appropriate queue,
based on the request path.

For example, a request for `/events?page=2`
would get published to the `events` queue.
