# GitHub Event Monitor

A monitoring and analysis service for GitHub events.

## Quick Start

Build the local services:

```bash
docker compose build
```

Start services:

```bash
docker compose up --detach
```

## Ingestion

Start the Event Poller service to begin requesting events from the GitHub Event API:

```bash
docker compose run --rm poller
```

## Testing

## Verification

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
