# Request Manager

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
- [app/jobs/event_poller_job](./app/jobs/event_poller_job.rb)

The following supporting service was added:
- [app/services/event_request_publisher](./app/services/event_request_publisher.rb)
