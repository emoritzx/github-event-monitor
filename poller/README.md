# Event Poller

This service is responsible for submitting the initial request for events to the GitHub API.

## Start service

```bash
docker compose run --rm poller
```

## Notes

This Ruby on Rails application was generated via the following command:

```bash
rails new poller --api --skip-active-record
```

SSL was disabled via `application.rb`:

```ruby
config.force_ssl = false
```
