### 0.2.1 (Next)

* Your contribution here.

### 0.2.0 (11/09/2017)

* [#33](https://github.com/ashkan18/graphlient/pull/33): Added dsl for supporting parametrized queries/mutations - [@ashkan18](https://github.com/ashkan18).
* [#34](https://github.com/ashkan18/graphlient/issues/34): Fix: don't convert variables to `String` - [@dblock](https://github.com/dblock).

### 0.1.0 (10/27/2017)

* [#31](https://github.com/ashkan18/graphlient/issues/31): Fix: catch execution errors that don't contain field names - [@dblock](https://github.com/dblock).

### 0.0.9 (10/26/2017)

* [#28](https://github.com/ashkan18/graphlient/pull/28): Raise errors in `execute`, not only `query` - [@dblock](https://github.com/dblock).
* [#29](https://github.com/ashkan18/graphlient/pull/29): Added `Graphlient::Adapters::HTTP::HTTPAdapter` that replaces Faraday with `Net::HTTP` - [@dblock](https://github.com/dblock).

### 0.0.8 (10/26/2017)

* [#27](https://github.com/ashkan18/graphlient/pull/27): Always raise an exception unless a query has succeeded - [@dblock](https://github.com/dblock).

### 0.0.7 (10/24/2017)

* [#26](https://github.com/ashkan18/graphlient/pull/26): Support String queries - [@dblock](https://github.com/dblock).

### 0.0.6 (10/20/2017)

* [#14](https://github.com/ashkan18/graphlient/pull/14): Switch to `graphql-client` for network calls and schema validation - [@ashkan18](https://github.com/ashkan18).
* [#17](https://github.com/ashkan18/graphlient/pull/17): Specialize server errors as `Graphlient::Errors::Server` - [@dblock](https://github.com/dblock).
* [#13](https://github.com/ashkan18/graphlient/pull/13): Support named queries and make sure, this is braking change where we no longer support queries that don't start with `query` - [@ashkan18](https://github.com/ashkan18).
* [#21](https://github.com/ashkan18/graphlient/pull/21): Added danger, PR linter - [@dblock](https://github.com/dblock).
* [#17](https://github.com/ashkan18/graphlient/pull/17): Enable customizing of Faraday middleware - [@dblock](https://github.com/dblock).
* [#19](https://github.com/ashkan18/graphlient/pull/19): Expose `client.schema` - [@dblock](https://github.com/dblock).
* [#20](https://github.com/ashkan18/graphlient/pull/20): Added support for parameterized queries and mutations - [@dblock](https://github.com/dblock).
* [#25](https://github.com/ashkan18/graphlient/pull/25): Added `client.parse` and `client.execute` to parse and execute queries separately - [@dblock](https://github.com/dblock).

### 0.0.5 (10/5/2017)

* [#11](https://github.com/ashkan18/graphlient/pull/11): Fixed query argument types - [@ashkan18](https://github.com/ashkan18).

### 0.0.4 (10/4/2017)

* [#8](https://github.com/ashkan18/graphlient/pull/8): Handle HTTP errors and raise `Graphlient::Errors::HTTP` on failure - [@dblock](https://github.com/dblock).
* [#5](https://github.com/ashkan18/graphlient/pull/5): Added RuboCop, Ruby-style linter, CHANGELOG, CONTRIBUTING and RELEASING - [@dblock](https://github.com/dblock).
* [#4](https://github.com/ashkan18/graphlient/pull/4): Refactored Graphlient::Client to take a URL and options, moved extensions - [@dblock](https://github.com/dblock).

### 0.0.3 (10/3/2017)

* Initial public release - [@ashkan18](https://github.com/ashkan18).
