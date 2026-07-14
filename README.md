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

Start the Event Poller service to begin requesting events from the GitHub Event API:

```bash
docker compose --profile ingest run --rm poller
```

Stop the Event Poller service at any time by issuing an interrupt `CTRL-C`.

## Testing

## Verification

### Logs

#### poller

```log
INFO: published message to queue requests
```

:warning: Make sure to include:
  - What logs to expect
  - What database tables or records to check
  - How long the system should run before results appear

## Cleanup

Tear down the Compose project and delete all data:

```bash
docker compose down --volumes
```

Add the `--rmi local` or `--rmi all` flag to delete downloaded container images as well.
