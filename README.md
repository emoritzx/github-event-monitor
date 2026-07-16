# GitHub Event Monitor

A monitoring and analysis service for GitHub events.

## Quick Start

Prepare the local environment by pulling the required container images
and building the local services:

```bash
docker compose --profile '*' pull --ignore-buildable
docker compose --profile '*' build
```

Start the long-running services:

```bash
docker compose up --detach --wait
```

These services are active and listening, but will not perform any computations without the initial ingest trigger.

## Ingestion

Start the Ingest command to begin requesting events from the GitHub Event API:

```bash
docker compose --profile ingest run --rm ingest
```

## Testing

### Unit Tests

Run the projects unit tests (requires a pre-configured Ruby environment).

#### Data Manager

```bash
cd data-manager
RAILS_ENV=test ./bin/rails db:migrate
./bin/rails test
```

#### Request Manager

```bash
cd request-manager
rake test
```

## Verification

If the system is working, events should start being ingested immediately.
Follow-on requests (such as event pagination and enrichment data)
will be queued immediately, but each request and response will take 60 seconds to occur.
A full ingest may take around 1 hour to complete,
or as much as 10 hours in the worst case (every event is a `PushEvent` with a unique user and repo).

You can verify that the system is working by checking the following items.

### Database

Log into the database and list all events:

```bash
docker compose exec postgres psql -U postgres
# in the psql CLI
\c data_manager_production
select * from events;
```

### Object store

Request raw object data using the Elastic API:

```bash
docker compose exec elasticsearch curl http://localhost:9200/events/_search
docker compose exec elasticsearch curl http://localhost:9200/users/_search
docker compose exec elasticsearch curl http://localhost:9200/repos/_search
```

### Logs

Once you have triggered the ingest, messages should start appearing immediately in the logs.
Successful log messages may look like the following outputs
(note: logs may have additional outputs such as timestamps in production mode).

#### Ingest

```log
INFO -- ingest: Creating RabbitMQ connection...
INFO -- ingest: Publishing initial event request...
INFO -- ingest: Published to requests exchange: /events
INFO -- ingest: Done.
```

#### Request Manager

```log
INFO -- request-manager: Waiting for requests...
INFO -- request-manager: Calling API: http://proxy/users/viniciusaraujoop
INFO -- request-manager: Response code: 200
WARN -- request-manager: Rate limit remaining: 59
INFO -- request-manager: Published response message to exchange users
INFO -- request-manager: Calling API: http://proxy/repos/viniciusaraujoop/grafica-flash
INFO -- request-manager: Response code: 200
WARN -- request-manager: Rate limit remaining: 58
INFO -- request-manager: Published response message to exchange repos
```

#### Data Manager

```log
INFO -- data-manager: Listening for events...
INFO -- data-manager: Listening for repos...
INFO -- data-manager: Listening for users...
INFO -- data-manager: Received a page of 100 events
INFO -- data-manager: Requesting next event page (2)
INFO -- data-manager: Published request: /events?page=2&per_page=100
INFO -- data-manager: Published request: /users/ovenkidney
INFO -- data-manager: Published request: /repos/ovenkidney/iviyzb
INFO -- data-manager: Received user viniciusaraujoop (179648402)
INFO -- data-manager: Received repo viniciusaraujoop/grafica-flash (1269474093)
```

## Cleanup

Tear down the Compose project and delete all data:

```bash
docker compose down --volumes --remove-orphans
```

Add the `--rmi local` or `--rmi all` flag to delete downloaded container images as well.
