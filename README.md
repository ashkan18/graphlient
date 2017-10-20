# Graphlient

[![Gem Version](https://badge.fury.io/rb/graphlient.svg)](https://badge.fury.io/rb/graphlient)
[![Build Status](https://travis-ci.org/ashkan18/graphlient.svg?branch=master)](https://travis-ci.org/ashkan18/graphlient)

A Ruby Client for consuming GraphQL-based APIs without all the messy strings.

## Installation

Add the following line to your Gemfile.

```ruby
gem 'graphlient'
```

## Usage

Create a new instance of `Graphlient::Client` with a URL and optional headers.

```ruby
client = Graphlient::Client.new('https://test-graphql.biz/graphql',
  headers: {
    'Authorization' => 'Bearer 123'
  }
)
```

The schema is available automatically via `.schema`.

```ruby
client.schema # GraphQL::Schema
```

Make queries with `query`, which gets a block for the query definition.

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

Graphlient validates the query based on current schema. In case of validation errors or any other connection related issues you'll get `Graphlient::Errors::Client` describing the error and in case of transport errors, `Graphlient::Errors::Server`. Both inherit from `Graphlient::Errors::Error` if you need to handle them in bulk.

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

### Executing Parameterized Queries and Mutations

Graphlient can execute parameterized queries and mutations by providing variables as query parameters.

The following query accepts an array of IDs.

```ruby
client.query(ids: [42]) do
  query(:$ids => :'[Int]') do
    invoices(ids: :$ids) do
      id
      fee_in_cents
    end
  end
end
```

The following mutation accepts a custom type that requires `fee_in_cents`.

```ruby
client.query(input: { fee_in_cents: 12_345 }) do
  mutation(:$input => :createInvoiceInput!) do
    createInvoice(input: :$input) do
      id
      fee_in_cents
    end
  end
end
```

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

### Testing with Graphlient and RSpec

Use Graphlient inside your RSpec tests in a Rails application or with `Rack::Test`, no more messy HTTP POSTs.

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
          c.use Faraday::Adapter::Rack, app
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

## License

MIT License, see [LICENSE](LICENSE)
