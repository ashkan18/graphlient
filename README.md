# Graphlient

[![Gem Version](https://badge.fury.io/rb/graphlient.svg)](https://badge.fury.io/rb/graphlient)
[![Build Status](https://github.com/ashkan18/graphlient/actions/workflows/ci.yml/badge.svg)](https://github.com/ashkan18/graphlient/actions/workflows/ci.yml)

A friendlier Ruby client for consuming GraphQL-based APIs. Built on top of your usual [graphql-client](https://github.com/github-community-projects/graphql-client), but with better defaults, more consistent error handling, and using the [faraday](https://github.com/lostisland/faraday) HTTP client.

# Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Schema Storing and Loading on Disk](#schema-storing-and-loading-on-disk)
  - [Preloading Schema Once](#preloading-schema-once)
  - [Error Handling](#error-handling)
  - [Executing Parameterized Queries and Mutations](#executing-parameterized-queries-and-mutations)
  - [Parse and Execute Queries Separately](#parse-and-execute-queries-separately)
  - [Build Query Strings without Validation](#build-query-strings-without-validation)
  - [Dynamic vs. Static Queries](#dynamic-vs-static-queries)
  - [Generate Queries with Graphlient::Query](#generate-queries-with-graphlientquery)
  - [Fragment Spreads and Definitions in the DSL](#fragment-spreads-and-definitions-in-the-dsl)
  - [Inline Fragments in the DSL](#inline-fragments-in-the-dsl)
  - [Directives in the DSL](#directives-in-the-dsl)
  - [Custom Scalar Types](#custom-scalar-types)
  - [Create API Client Classes with Graphlient::Extension::Query](#create-api-client-classes-with-graphlientextensionquery)
  - [Swapping the HTTP Stack](#swapping-the-http-stack)
  - [Testing with Graphlient and RSpec](#testing-with-graphlient-and-rspec)
- [License](#license)

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
| ------------- | ------- | ------- |
| read_timeout  | nil     | seconds |
| write_timeout | nil     | seconds |

Headers can be changed between requests without rebuilding the client.

```ruby
client.options[:headers] = { 'Authorization' => 'Bearer 456' }
```

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

### Preloading Schema Once

Even if caching the schema on disk, instantiating `Graphlient::Client` often can be both time and memory intensive due to loading the schema for each instance. This is especially true if the schema is a large file. To get around these performance issues, instantiate your schema once and pass it in as a configuration option.

One time in an initializer

```ruby
schema = Graphlient::Schema.new(
  'https://graphql.foo.com/graphql', 'lib/graphql_schema_foo.json'
)
```

Pass in each time you initialize a client

```
client = Graphlient::Client.new(
  'https://graphql.foo.com/graphql',
  schema: schema,
  headers: {
    'Authorization' => 'Bearer 123',
  }
)
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
* [Graphlient::Errors::TimeoutError](lib/graphlient/errors/timeout_error.rb): all client-side timeouts raised by the Faraday adapter. This does not inherit from `ServerError` because no server response or status code is available; rescue `TimeoutError` separately
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

### Build Query Strings without Validation

`Client#to_query_string` serializes a DSL block into a GraphQL query string and
returns it as a plain `String`. It uses the same DSL serializer (`Graphlient::Query`)
that powers `client.query` and `client.parse`, but it stops there — no schema is
loaded, no graphql-client validation runs, no HTTP call is made.

```ruby
client = Graphlient::Client.new('https://example.com/graphql',
  headers: { 'Authorization' => 'Bearer 123' }
)

query_str = client.to_query_string do
  query(id: :int) do
    invoice(id: :id) do
      id
      feeInCents
    end
  end
end

# => "query($id: Int){\n  invoice(id: $id){\n    id\n    feeInCents\n    }\n  }"
```

For fragment-free queries the string can be fed back to `client.execute`:

```ruby
client.execute(query_str, id: 42)
```

Queries containing fragment spreads (`spread :Name` → `...Name`) cannot go back
through the gem — graphql-client requires fragments to be pre-registered module
constants, not named strings. Pass those directly to your own HTTP client instead.

This is also the escape hatch if you want to replace the graphql-client dependency
entirely. `to_query_string` gives you a standard GraphQL document — from there you
own the transport: Faraday, Net::HTTP, anything else. You get full control over
headers, retries, connection pooling, and middleware without any graphql-client
overhead.

```ruby
conn = Faraday.new('https://example.com/graphql',
  headers: { 'Authorization' => 'Bearer 123', 'Content-Type' => 'application/json' }
)
response = conn.post('/', { query: query_str, variables: { id: 42 } }.to_json)
```

### Dynamic vs. Static Queries

Graphlient uses [graphql-client](https://github.com/github-community-projects/graphql-client), which [recommends](https://github.com/github-community-projects/graphql-client/blob/master/guides/dynamic-query-error.md) building queries as static module members along with dynamic variables during execution. This can be accomplished with graphlient the same way.

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

Note that in the example above the client is created with `allow_dynamic_queries: false` (only allow static queries), while graphlient defaults to `allow_dynamic_queries: true` (allow dynamic queries). This option is marked deprecated, but we're proposing to remove it and default it to `true` in [graphql-client#128](https://github.com/github-community-projects/graphql-client/issues/128).

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

### Fragment Spreads and Definitions in the DSL

Use `spread` to insert a named fragment spread (`...FragmentName`) in a DSL block:

```ruby
client.query do
  query do
    invoice(id: 10) do
      id
      spread :InvoiceFields   # → ...InvoiceFields
    end
  end
end
```

Define the fragment body inline with `fragment` — graphlient assembles the complete
query string automatically, no external tooling needed:

```ruby
client.query do
  fragment(:InvoiceFields, on: :Invoice) do
    id
    feeInCents
  end

  query do
    invoice(id: 10) do
      spread :InvoiceFields
    end
  end
end
```

Produces and sends:

```graphql
query {
  invoice(id: 10) {
    ...InvoiceFields
  }
}

fragment InvoiceFields on Invoice {
  id
  feeInCents
}
```

Because the fragment is defined inline in the same query block, graphql-client treats it
as part of the same document — all fragment fields are directly accessible on the response
wrapper with no extra wrapping step:

```ruby
response = client.query do
  fragment(:InvoiceFields, on: :Invoice) do
    id
    feeInCents
  end

  query do
    invoice(id: 10) do
      spread :InvoiceFields
    end
  end
end

response.data.invoice.id            # 10
response.data.invoice.fee_in_cents  # 20000
```

Multiple fragments are supported. Fragments are scoped to the query call — no global
registry, no cross-contamination between requests.

You can also apply a directive to a spread (see [Directives in the DSL](#directives-in-the-dsl)):

```ruby
spread :InvoiceFields, _skip(if: :skip_invoice)
# → ...InvoiceFields @skip(if: $skip_invoice)
```

### Use of Fragments (graphql-client style)

[Fragments](https://github.com/github-community-projects/graphql-client#defining-queries) should be referred by constant:

```ruby
module Fragments
  Invoice = client.parse <<~'GRAPHQL'
    fragment on Invoice {
      id
      feeInCents
    }
  GRAPHQL
end
```

`Graphlient` offers the syntax below to refer to the original constant:
  * Triple underscore `___` to refer to the fragment
  * Double underscore `__` for namespace separator

In this example, `Fragments::Invoice` would be referred as follows:

```ruby
invoice_query = client.parse do
  query do
    invoice(id: 10) do
      id
      ___Fragments__Invoice
    end
  end
end
```

The wrapped response only allows access to fields that have been explicitly asked for.
In this example, while `id` has been referenced directly in the main query, `feeInCents`
has been spread via an **external fragment constant** and trying to access it in the
original wrapped response will throw
[`GraphQL::Client::ImplicitlyFetchedFieldError`](https://github.com/github-community-projects/graphql-client/blob/master/guides/implicitly-fetched-field-error.md).
This is graphql-client's component-isolation mechanism: each fragment constant "owns" the
fields it declares, preventing accidental data access across component boundaries.

```ruby
response = client.execute(invoice_query)
result = response.data.invoice
result.to_h
# {"id" => 10, "feeInCents"=> 20000}
result.id
# 10
result.fee_in_cents
# raises GraphQL::Client::ImplicitlyFetchedFieldError
```

`feeInCents` cannot be fetched directly from the main query, but from the fragment as shown below:

```ruby
invoice = Fragments::Invoice.new(result)
invoice.id
# 10
invoice.fee_in_cents
# 20000
```

> **Note:** This component-isolation behaviour only applies to external fragment constants
> (the `___` / `__` pattern). Fragments defined inline via the `fragment` DSL in the same
> query block are not subject to this restriction — their fields are accessible directly
> on the operation response (see [Fragment Spreads and Definitions in the DSL](#fragment-spreads-and-definitions-in-the-dsl)).

### Inline Fragments in the DSL

Use `spread(on: :TypeName)` for inline fragments (`... on Type { }`), useful for union
types and interface implementations. It's the same `spread` verb as named fragment
spreads, and the same `on:` keyword as `fragment(name, on:)`:

```ruby
client.query do
  query do
    invoice(id: 10) do
      spread(on: :PaidInvoice) do
        amountPaid
      end
      spread(on: :UnpaidInvoice) do
        amountDue
      end
    end
  end
end
```

Produces:

```graphql
query {
  invoice(id: 10) {
    ... on PaidInvoice {
      amountPaid
    }
    ... on UnpaidInvoice {
      amountDue
    }
  }
}
```

Directives can be applied to inline fragments too (see [Directives in the DSL](#directives-in-the-dsl)):

```ruby
spread(_skip(if: :skip_drafts), on: :DraftInvoice) { draftId }
# → ... on DraftInvoice @skip(if: $skip_drafts) { draftId }
```

### Directives in the DSL

Apply GraphQL directives to fields, spreads, and inline fragments using the `_name`
convention — any method starting with `_` followed by a lowercase letter is treated
as a directive (`_skip` → `@skip`, `_include` → `@include`, `_myDirective` → `@myDirective`).

**On a field:**

```ruby
client.query(some_id: :int, skip_fee: :boolean!) do
  query(some_id: :int, skip_fee: :boolean!) do
    invoice(id: :some_id) do
      id
      feeInCents _skip(if: :skip_fee)   # → feeInCents @skip(if: $skip_fee)
    end
  end
end
```

**On a fragment spread:**

```ruby
spread :InvoiceFields, _skip(if: :skip_invoice)
# → ...InvoiceFields @skip(if: $skip_invoice)
```

**On an inline fragment:**

```ruby
spread(_skip(if: :skip_drafts), on: :DraftInvoice) { draftId }
# → ... on DraftInvoice @skip(if: $skip_drafts) { draftId }
```

**Multiple directives on one field:**

```ruby
feeInCents _skip(if: :skip_fee), _include(if: :show_cents)
# → feeInCents @skip(if: $skip_fee) @include(if: $show_cents)
```

**No-argument directive:**

```ruby
legacyField _deprecated
# → legacyField @deprecated
```

The directive value is a plain Ruby method call that returns a `Directive` object
before the field method runs, ensuring the directive appears in the correct position
in the output string regardless of Ruby's evaluation order.

### Custom Scalar Types

By default, graphlient maps `:int → Int`, `:float → Float`, `:string → String`, and
`:boolean → Boolean` for variable type declarations. Register additional scalar types
in the client initialiser block:

```ruby
client = Graphlient::Client.new('https://example.com/graphql') do |c|
  c.scalar :date,    'Date'
  c.scalar :uuid,    'UUID'
  c.scalar :decimal, 'Decimal'
end
```

Use the registered symbol in variable declarations:

```ruby
client.query(created_after: Date.today.iso8601, order_id: :uuid) do
  query(created_after: :date, order_id: :uuid!) do
    orders(created_after: :created_after, id: :order_id) do
      id
      total
    end
  end
end
# → query($created_after: Date, $order_id: UUID!) { ... }
```

Non-null variants work with `!`: `:date!` → `Date!`.

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
