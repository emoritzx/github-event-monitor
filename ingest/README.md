# ingest

This service provides the initial trigger to begin ingesting events from the GitHub API.
The process is started by publishing a request to the `/events` endpoint.

## Development notes

This service started off as a Rails application,
but was overkill for a process that simply publishes a single message.
It was pared down into the CLI application you see now.
