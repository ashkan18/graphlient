# Graphlient

[![Gem Version](https://badge.fury.io/rb/graphlient.svg)](https://badge.fury.io/rb/graphlient)
[![Build Status](https://travis-ci.org/ashkan18/graphlient.svg?branch=master)](https://travis-ci.org/ashkan18/graphlient)

A Ruby Client for consuming GraphQL-based APIs.

## Installation

Add the following line to your Gemfile.

```ruby
gem 'graphlient'
```

## Usage

There are 3 different ways to use this library.

### Graphlient::Client

Create a new instance of `Graphlient::Client` and pass the query into a block.

```ruby
client = Graphlient::Client.new('https://test-graphql.biz/graphql',
  headers: {
    'Authorization' => 'Bearer 123'
  }
)

response = client.query do
  invoice(id: 10) do
    id
    total
    line_items do
      price
      item_type
    end
  end
end
```

This will call the endpoint setup in the configuration with `POST`, the `Authorization` header and `query` as

```graphql
invoice(id: 10) {
  id
  total
  line_items{
    price
    item_type
  }
}
```

The response is a JSON object.

### Use Graphlient::Query directly

You can directly use `Graphlient::Query` to generate GraphQL queries. Example:

```ruby
query = Graphlient::Query.new do
  query do
    invoice(id: 10) do
      line_items
    end
  end
end

query.to_s
# "\nquery{\n  invoice(id: 10){\n    line_items\n    }\n  }\n"
```

### Use Graphlient::Extension::Query

You can include `Graphlient::Extensions::Query` in your class. This will add a new `method_missing` method to your context which will be used to generate GraphQL queries.

```ruby
include Graphlient::Extensions::Query

query = invoice(id: 10) do
  line_items
end

query.to_s
# "\nquery{\n  invoice(id: 10){\n    line_items\n    }\n  }\n"
```

## License

MIT License, see [LICENSE](LICENSE)
