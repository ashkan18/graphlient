Upgrading Graphlient
===========================

### Upgrading to >= 0.3.7

#### Changes in error handling of connection refused error

Prior to 0.3.7, Graphlient would return `NoMethodError: undefined method []' for nil:NilClass` error if connection is
refused/failed when connecting to a remote host. After 0.3.7, Graphlient will return a new 
`Graphlient::Errors::ConnectionFailedError` instead.

See [#68](https://github.com/ashkan18/graphlient/pull/68) for more information.
