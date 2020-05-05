Upgrading Graphlient
===========================

### Upgrading to >= 0.4.0

#### Requires Faraday >= 1.0

See [#75](https://github.com/ashkan18/graphlient/pull/75).

#### Changes in error handling of connection refused error

When the GraphQL request was failing, we were receiving a `Faraday::ServerError`. After 0.4.0, Graphlient
will return `Graphlient::Errors::FaradayServerError` instead.

### Upgrading to >= 0.3.7

#### Changes in error handling of connection refused error

Prior to 0.3.7, Graphlient would return `NoMethodError: undefined method []' for nil:NilClass` error if connection is
refused/failed when connecting to a remote host. After 0.3.7, Graphlient will return a new 
`Graphlient::Errors::ConnectionFailedError` instead.

See [#68](https://github.com/ashkan18/graphlient/pull/68) for more information.
