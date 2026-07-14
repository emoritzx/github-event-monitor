# Request Manager

This service is responsible for subscribing to GitHub API requests
and responsibly sending them without violating rate limits.

This service subscribes to the `requests` queue
and publishes the response to the appropriate queue,
based on the request path.

For example, a request for `/events?page=2`
would get published to the `events` queue.

## Development notes

This Ruby on Rails application was generated via the following command:

```bash
rails new poller --api --skip-active-record
```

SSL was disabled via `application.rb`:

```ruby
config.force_ssl = false
```

The following job was added on [startup](./config/application.rb):
- [app/jobs/requests_subscriber_job](./app/jobs/requests_subscriber_job.rb)

The following supporting services were added:
- [app/services/github_api](./app/services/github_api.rb)
- [app/services/requests_handler](./app/services/requests_handler.rb)
- [app/services/requests_subscriber](./app/services/requests_subscriber.rb)
- [app/services/response_publisher](./app/services/response_publisher.rb)
