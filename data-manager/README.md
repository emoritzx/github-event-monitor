# Data Manager

## Development notes

This Ruby on Rails service was generated via the following command:

```bash
rails new data-manager --api --database=postgresql
```

SSL was disabled via `production.rb`:

```ruby
config.force_ssl = false
```

The following job was added on [startup](./config/application.rb):
- TBD

The following supporting services were added:
- TBD
