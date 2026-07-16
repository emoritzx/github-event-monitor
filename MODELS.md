# Data Models

This document describes the data models shared by the services.

## Structured Data

### Events

Field           | Type    | Description
--------------- | ------- | -----------
`event_id`      | BIGINT  | GitHub event ID
`repository_id` | BIGINT  | GitHub repository ID
`push_id`       | BIGINT  | Unique push ID
`ref`           | VARCHAR | git reference
`head`          | VARCHAR | sha hash after push
`before`        | VARCHAR | sha hash before push

See [GitHub event types - PushEvent](https://docs.github.com/en/rest/using-the-rest-api/github-event-types?apiVersion=2026-03-10#pushevent) for a full description of the fields.

## Object Storage

Unstructured JSON-format data objects of GitHub API responses
are stored in Elasticsearch in the `events`, `actors`, and `repos` indices.

## Messages

Requests to the GitHub API are published to the `requests` exchange.
The payload is a `text/plain` string of the API path to be called.

For example:
```text
/events?page=3&per_page=30
```

The response data is published to the associated exchange
(e.g. the response the above example gets published to the `events` exchange).

Response messages are of type `application/json` and contain 3 top-level fields.

Field     | Type   | Description
--------- | ------ | -----------
`path`    | String | The original request path
`headers` | Object | A map of response headers. See note below.
`body`    | Object | The body of the response data in JSON format

> :information_source: Each key-value pair of the `headers` object
> corresponds to the HTTP header name and an array of values.
> If the same header appears multiple times in a response,
> each entry is saved in the values array.
> Headers that only appear once in a response
> are still stored in an array containing only one value.
