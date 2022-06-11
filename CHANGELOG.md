### 0.6.0 (2022/06/11)

* [#87](https://github.com/ashkan18/graphlient/pull/87): Raised `ExecutionError` with partial error response - [@QQism](https://github.com/QQism).
* [#90](https://github.com/ashkan18/graphlient/pull/90): Added support for Ruby 3.1 - [@QQism](https://github.com/QQism).
* [#90](https://github.com/ashkan18/graphlient/pull/90): Dropped support for Ruby 2.5 - [@QQism](https://github.com/QQism).
* [#91](https://github.com/ashkan18/graphlient/pull/91): Update GHA for `danger` with right permissions - [@QQism](https://github.com/QQism).
* [#89](https://github.com/ashkan18/graphlient/pull/89): Replace Travis CI with Github Actions - [@QQism](https://github.com/QQism).

### 0.5.0 (2020/12/28)

* [#81](https://github.com/ashkan18/graphlient/pull/81): Make graphlient run on ruby 3.0 - [@Burgestrand](https://github.com/Burgestrand).
* [#79](https://github.com/ashkan18/graphlient/pull/79): Added client testing docs - [@GabrielDzul](https://github.com/GabrielDzul).

### 0.4.0 (2020/05/22)

* [#72](https://github.com/ashkan18/graphlient/pull/72): Add http_options - [@neroleung](https://github.com/neroleung).
* [#71](https://github.com/ashkan18/graphlient/issues/70): Add `Graphlient::Errors::TimeoutError` - [@BenDrozdoff](https://github.com/BenDrozdoff).
* [#75](https://github.com/ashkan18/graphlient/pull/75): Support Faraday 1.x - [@jfhinchcliffe](https://github.com/jfhinchcliffe).
* [#78](https://github.com/ashkan18/graphlient/pull/78): Add description of timeout values - [@sap1enza](https://github.com/sap1enza).

### 0.3.7 (2019/11/14)

* [#68](https://github.com/ashkan18/graphlient/pull/68): Add `Graphlient::Errors::ConnectionFailedError` - [@neroleung](https://github.com/neroleung).

### 0.3.6 (2019/07/23)

* [#63](https://github.com/ashkan18/graphlient/pull/63): Remove unused method for attribute with typo - [@ashkan18](https://github.com/ashkan18).
* [#62](https://github.com/ashkan18/graphlient/pull/62): Fix typo preventing access to response object on error - [@jmondo](https://github.com/jmondo).

### 0.3.4 (2019/01/31)

* [#56](https://github.com/ashkan18/graphlient/pull/56): Remove safe navigation usage to retain support for Ruby 2.2 - [@avinoth](https://github.com/avinoth).
* [#57](https://github.com/ashkan18/graphlient/pull/57): Add support for parsing queries from a String - [@ateamlunchbox](https://github.com/ateamlunchbox).

### 0.3.3 (2018/09/23)

* [#50](https://github.com/ashkan18/graphlient/pull/50): More detailed error responses - [@ashkan18](https://github.com/ashkan18).

### 0.3.2 (2018/07/03)

* [#46](https://github.com/ashkan18/graphlient/pull/46): Fix issue with gathering error details when trying `to_s` on `GraphQLError` - [@ashkan18](https://github.com/ashkan18).
* [#45](https://github.com/ashkan18/graphlient/pull/45): Drop Support for Ruby 2.2 and Lock RuboCop - [@jonallured](https://github.com/jonallured).

### 0.3.1 (2018/04/17)

* [#43](https://github.com/ashkan18/graphlient/pull/43): Allow to load and dump schema to json - [@povilasjurcys](https://github.com/povilasjurcys).

### 0.3.0 (2018/02/22)

* [#38](https://github.com/ashkan18/graphlient/pull/38): Add support for Ruby 2.5 - [@yuki24](https://github.com/yuki24).
* [#39](https://github.com/ashkan18/graphlient/pull/39): Add support for Ruby 2.2 - [@yuki24](https://github.com/yuki24).
* [#40](https://github.com/ashkan18/graphlient/pull/40): Add experimental support for JRuby - [@yuki24](https://github.com/yuki24).

### 0.2.0 (2017/11/09)

* [#33](https://github.com/ashkan18/graphlient/pull/33): Added dsl for supporting parametrized queries/mutations - [@ashkan18](https://github.com/ashkan18).
* [#34](https://github.com/ashkan18/graphlient/issues/34): Fix: don't convert variables to `String` - [@dblock](https://github.com/dblock).

### 0.1.0 (2017/10/27)

* [#31](https://github.com/ashkan18/graphlient/issues/31): Fix: catch execution errors that don't contain field names - [@dblock](https://github.com/dblock).

### 0.0.9 (2017/10/26)

* [#28](https://github.com/ashkan18/graphlient/pull/28): Raise errors in `execute`, not only `query` - [@dblock](https://github.com/dblock).
* [#29](https://github.com/ashkan18/graphlient/pull/29): Added `Graphlient::Adapters::HTTP::HTTPAdapter` that replaces Faraday with `Net::HTTP` - [@dblock](https://github.com/dblock).

### 0.0.8 (2017/10/26)

* [#27](https://github.com/ashkan18/graphlient/pull/27): Always raise an exception unless a query has succeeded - [@dblock](https://github.com/dblock).

### 0.0.7 (2017/10/24)

* [#26](https://github.com/ashkan18/graphlient/pull/26): Support String queries - [@dblock](https://github.com/dblock).

### 0.0.6 (2017/10/20)

* [#14](https://github.com/ashkan18/graphlient/pull/14): Switch to `graphql-client` for network calls and schema validation - [@ashkan18](https://github.com/ashkan18).
* [#17](https://github.com/ashkan18/graphlient/pull/17): Specialize server errors as `Graphlient::Errors::Server` - [@dblock](https://github.com/dblock).
* [#13](https://github.com/ashkan18/graphlient/pull/13): Support named queries and make sure, this is braking change where we no longer support queries that don't start with `query` - [@ashkan18](https://github.com/ashkan18).
* [#21](https://github.com/ashkan18/graphlient/pull/21): Added danger, PR linter - [@dblock](https://github.com/dblock).
* [#17](https://github.com/ashkan18/graphlient/pull/17): Enable customizing of Faraday middleware - [@dblock](https://github.com/dblock).
* [#19](https://github.com/ashkan18/graphlient/pull/19): Expose `client.schema` - [@dblock](https://github.com/dblock).
* [#20](https://github.com/ashkan18/graphlient/pull/20): Added support for parameterized queries and mutations - [@dblock](https://github.com/dblock).
* [#25](https://github.com/ashkan18/graphlient/pull/25): Added `client.parse` and `client.execute` to parse and execute queries separately - [@dblock](https://github.com/dblock).

### 0.0.5 (2017/10/05)

* [#11](https://github.com/ashkan18/graphlient/pull/11): Fixed query argument types - [@ashkan18](https://github.com/ashkan18).

### 0.0.4 (2017/10/04)

* [#8](https://github.com/ashkan18/graphlient/pull/8): Handle HTTP errors and raise `Graphlient::Errors::HTTP` on failure - [@dblock](https://github.com/dblock).
* [#5](https://github.com/ashkan18/graphlient/pull/5): Added RuboCop, Ruby-style linter, CHANGELOG, CONTRIBUTING and RELEASING - [@dblock](https://github.com/dblock).
* [#4](https://github.com/ashkan18/graphlient/pull/4): Refactored Graphlient::Client to take a URL and options, moved extensions - [@dblock](https://github.com/dblock).

### 0.0.3 (2017/10/03)

* Initial public release - [@ashkan18](https://github.com/ashkan18).
