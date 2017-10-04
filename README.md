# Graphlient ![](https://travis-ci.org/ashkan18/graphlient.svg?branch=master)
Ruby Client for consuming GraphQL based APIs.

## Installation
Add following line to your Gemfile

```ruby
gem 'graphlient'
```

## Configuration

Add `graphlient.rb under config/initializers. You can use this config to setup `graphql_endpoint`. Here is a sample of configuration:

```ruby
# config/initializers/graphlient.rb
Graphlient.configure do |config|
  config.graphql_endpoint = 'http://test-graphql.biz/graphql'  # target GraphQL endpoint
end
```

## Usage
There are 3 different usages.

### Graphlient::Client
After configuring the client, you can use the client by passing the query in a block.

```ruby
response = Graphlient::Client.query(headers: { 'Authorization' => 'Bearer 123'}) do
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

This will call the endpoint setup in the configuration with `POST` and passes `query` as
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
It also sets the `Authorization` header based on passed in data.

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
You can include `Graphlient::Extension::Query` in your module. This will add new `method_missing` method to your context which will be used to generate GraphQL queries.

```ruby
include Graphlient::Extension::Query
query = invoice(id: 10) do
  line_items
end

query.to_s
# "\nquery{\n  invoice(id: 10){\n    line_items\n    }\n  }\n"
```
