# Graphlient

[![Gem Version](https://badge.fury.io/rb/graphlient.svg)](https://badge.fury.io/rb/graphlient)
[![Build Status](https://github.com/ashkan18/graphlient/actions/workflows/ci.yml/badge.svg)](https://github.com/ashkan18/graphlient/actions/workflows/ci.yml)

A friendlier Ruby client for consuming GraphQL-based APIs. Built on top of your usual [graphql-client](https://github.com/github/graphql-client), but with better defaults, more consistent error handling, and using the [faraday](https://github.com/lostisland/faraday) HTTP client.

## Installation

Add the following line to your Gemfile.

```ruby
gem 'graphlient'
```

## Usage

Create a new instance of `Graphlient::Client` with a URL and optional headers/http_options.

```ruby
client = Graphlient::Client.new('https://test-graphql.biz/graphql',
  headers: {
    'Authorization' => 'Bearer 123'
  },
  http_options: {
    read_timeout: 20,
    write_timeout: 30
  }
)
```

| http_options  | default | type    |
|---------------|---------|---------|
| read_timeout  | nil     | seconds |
| write_timeout | nil     | seconds |

The schema is available automatically via `.schema`.

```ruby
client.schema # GraphQL::Schema
```

Make queries with `query`, which takes a String or a block for the query definition.

With a String.

```ruby
response = client.query <<~GRAPHQL
  query {
    invoice(id: 10) {
      id
      total
      line_items {
        price
        item_type
      }
    }
  }
GRAPHQL
```

With a block.

```ruby
response = client.query do
  query do
    invoice(id: 10) do
      id
      total
      line_items do
        price
        item_type
      end
    end
  end
end
```

This will call the endpoint setup in the configuration with `POST`, the `Authorization` header and `query` as follows.

```graphql
query {
  invoice(id: 10) {
    id
    total
    line_items {
      price
      item_type
    }
  }
}
```

A successful response object always contains data which can be iterated upon. The following example returns the first line item's price.

```ruby
response.data.invoice.line_items.first.price
```

You can also execute mutations the same way.

```ruby
response = client.query do
  mutation do
    createInvoice(input: { fee_in_cents: 12_345 }) do
      id
      fee_in_cents
    end
  end
end
```

The successful response contains data in `response.data`. The following example returns the newly created invoice's ID.

```ruby
response.data.create_invoice.first.id
```

### Schema storing and loading on disk

To reduce requests to graphql API you can cache schema:

```ruby
client = Client.new(url, schema_path: 'config/your_graphql_schema.json')
client.schema.dump! # you only need to call this when graphql schema changes
```

### Error Handling

Unlike graphql-client, Graphlient will always raise an exception unless the query has succeeded.

* [Graphlient::Errors::ClientError](lib/graphlient/errors/client_error.rb): all client-side query validation failures based on current schema
* [Graphlient::Errors::GraphQLError](lib/graphlient/errors/graphql_error.rb): all GraphQL API errors, with a humanly readable collection of problems
* [Graphlient::Errors::ExecutionError](lib/graphlient/errors/execution_error.rb): all GraphQL execution errors, with a humanly readable collection of problems
* [Graphlient::Errors::ServerError](lib/graphlient/errors/server_error.rb): all transport errors raised by HTTP Adapters. You can access `inner_exception`, `status_code` and `response` on these errors to get more details on what went wrong
* [Graphlient::Errors::FaradayServerError](lib/graphlient/errors/faraday_server_error.rb): this inherits from `ServerError` ☝️, we recommend using `ServerError` to rescue these
* [Graphlient::Errors::HttpServerError](lib/graphlient/errors/http_server_error.rb): this inherits from `ServerError` ☝️, we recommend using `ServerError` to rescue these
* [Graphlient::Errors::ConnectionFailedError](lib/graphlient/errors/connection_failed_error.rb): this inherits from `ServerError` ☝️, we recommend using `ServerError` to rescue these
* [Graphlient::Errors::TimeoutError](lib/graphlient/errors/timeout_error.rb): this inherits from `ServerError` ☝️, we recommend using `ServerError` to rescue these
* [Graphlient::Errors::HttpOptionsError](lib/graphlient/errors/http_options_error.rb): all NoMethodError raised by HTTP Adapters when given options in `http_options` are invalid


All errors inherit from `Graphlient::Errors::Error` if you need to handle them in bulk.

### Executing Parameterized Queries and Mutations

Graphlient can execute parameterized queries and mutations by providing variables as query parameters.

The following query accepts an array of IDs.

With a String.

```ruby
query = <<-GRAPHQL
  query($ids: [Int]) {
    invoices(ids: $ids) {
      id
      fee_in_cents
    }
  }
GRAPHQL
variables = { ids: [42] }

client.query(query, variables)
```

With a block.

```ruby
client.query(ids: [42]) do
  query(ids: [:int]) do
    invoices(ids: :ids) do
      id
      fee_in_cents
    end
  end
end
```
Graphlient supports following Scalar types for parameterized queries by default:
- `:id` maps to `ID`
- `:boolean` maps to `Boolean`
- `:float` maps to `Float`
- `:int` maps to `Int`
- `:string` maps to `String`

You can use any of the above types with `!` to make it required or use them in `[]` for array parameters.

For any other custom types, graphlient will simply use `to_s` of the symbol provided for the type, so `query(ids: [:InvoiceType!])` will result in `query($ids: [InvoiceType!])`.

The following mutation accepts a custom type that requires `fee_in_cents`.

```ruby
client.query(input: { fee_in_cents: 12_345 }) do
  mutation(input: :createInvoiceInput!) do
    createInvoice(input: :input) do
      id
      fee_in_cents
    end
  end
end
```

### Parse and Execute Queries Separately

You can `parse` and `execute` queries separately with optional variables. This is highly recommended as parsing a query and validating a query on every request adds performance overhead. Parsing queries early allows validation errors to be discovered before request time and avoids many potential security issues.


```ruby
# parse a query, returns a GraphQL::Client::OperationDefinition
query = client.parse do
  query(ids: [:int]) do
    invoices(ids: :ids) do
      id
      fee_in_cents
    end
  end
end

# execute a query, returns a GraphQL::Client::Response
client.execute query, ids: [42]
```

Or pass in a string instead of a block:

```ruby
# parse a query, returns a GraphQL::Client::OperationDefinition
query = client.parse <<~GRAPHQL
  query($some_id: Int) {
    invoice(id: $some_id) {
      id
      feeInCents
    }
  }
GRAPHQL

# execute a query, returns a GraphQL::Client::Response
client.execute query, ids: [42]
```

### Dynamic vs. Static Queries

Graphlient uses [graphql-client](https://github.com/github/graphql-client), which [recommends](https://github.com/github/graphql-client/blob/master/guides/dynamic-query-error.md) building queries as static module members along with dynamic variables during execution. This can be accomplished with graphlient the same way.

Create a new instance of `Graphlient::Client` with a URL and optional headers.

```ruby
module SWAPI
  Client = Graphlient::Client.new('https://test-graphql.biz/graphql',
    headers: {
      'Authorization' => 'Bearer 123'
    },
    allow_dynamic_queries: false
  )
end
```

The schema is available automatically via `.schema`.

```ruby
SWAPI::Client.schema # GraphQL::Schema
```

Define a query.

```ruby
module SWAPI
  InvoiceQuery = Client.parse do
    query(id: :int) do
      invoice(id: :id) do
        id
        fee_in_cents
      end
    end
  end
end
```

Execute the query.

```ruby
response = SWAPI::Client.execute(SWAPI::InvoiceQuery, id: 42)
```

Note that in the example above the client is created with `allow_dynamic_queries: false` (only allow static queries), while graphlient defaults to `allow_dynamic_queries: true` (allow dynamic queries). This option is marked deprecated, but we're proposing to remove it and default it to `true` in [graphql-client#128](https://github.com/github/graphql-client/issues/128).

### Generate Queries with Graphlient::Query

You can directly use `Graphlient::Query` to generate raw GraphQL queries.

```ruby
query = Graphlient::Query.new do
  query do
    invoice(id: 10) do
      line_items
    end
  end
end

query.to_s
# "\nquery {\n  invoice(id: 10){\n    line_items\n    }\n  }\n"
```

### Create API Client Classes with Graphlient::Extension::Query

You can include `Graphlient::Extensions::Query` in your class. This will add a new `method_missing` method to your context which will be used to generate GraphQL queries.

```ruby
include Graphlient::Extensions::Query

query = query do
  invoice(id: 10) do
    line_items
  end
end

query.to_s
# "\nquery{\n  invoice(id: 10){\n    line_items\n    }\n  }\n"
```

### Swapping the HTTP Stack

You can swap the default Faraday adapter for `Net::HTTP`.

```ruby
client = Graphlient::Client.new('https://test-graphql.biz/graphql',
  http: Graphlient::Adapters::HTTP::HTTPAdapter
)
```

### Testing with Graphlient and RSpec

Use Graphlient inside your RSpec tests in a Rails application or with `Rack::Test` against your actual application.

```ruby
require 'spec_helper'

describe App do
  include Rack::Test::Methods

  def app
    # ...
  end

  let(:client) do
    Graphlient::Client.new('http://test-graphql.biz/graphql') do |client|
      client.http do |h|
        h.connection do |c|
          c.adapter Faraday::Adapter::Rack, app
        end
      end
    end
  end

  context 'an invoice' do
    let(:result) do
      client.query do
        query do
          invoice(id: 10) do
            id
          end
        end
      end
    end

    it 'can be retrieved' do
      expect(result.data.invoice.id).to eq 10
    end
  end
end
```

Alternately you can `stub_request` with Webmock.

```ruby
describe App do
  let(:url) { 'http://example.com/graphql' }
  let(:client) { Graphlient::Client.new(url) }

  before do
    stub_request(:post, url).to_return(
      status: 200,
      body: DummySchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY).to_json
    )
  end

  it 'retrieves schema' do
    expect(client.schema).to be_a Graphlient::Schema
  end
end
```

In order to stub the response to actual queries, [dump the schema into a JSON file](#schema-storing-and-loading-on-disk) and specify it via schema_path as follows.

```ruby
describe App do
  let(:url) { 'http://graph.biz/graphql' }
  let(:client) { Graphlient::Client.new(url, schema_path: 'spec/support/fixtures/invoice_api.json') }
  let(:query) do
    <<~GRAPHQL
      query{
        invoice(id: 42) {
          id
          feeInCents
        }
      }
    GRAPHQL
  end
  let(:json_response) do
    {
      'data' => {
        'invoice' => {
          'id' => '42',
          'feeInCents' => 2000
        }
      }
    }.to_json
  end

  before do
    stub_request(:post, url).to_return(
      status: 200,
      body: json_response
    )
  end

  it 'returns invoice fees' do
    response = client.query(query)
    expect(response.data).to be_truthy
    expect(response.data.invoice.id).to eq('42')
    expect(response.data.invoice.fee_in_cents).to eq(2000)
  end
end
```

## License

MIT License, see [LICENSE](LICENSE)
