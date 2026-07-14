# Event Poller

This service is responsible for submitting the initial request for events to the GitHub API.

## Overview

As currently configured, this service publishes a single events request to the message broker.
This is the trigger for further services downstream to consume events.
As such, it should be started manually versus running as a long-term service.

## Start service

```bash
docker compose run --rm poller
```

## Stop service

If you have started the service as above, you can stop the service by issuing an interrupt via `CTRL+C`.

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
