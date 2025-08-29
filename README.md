# SmolLama

A simple, lightweight Ruby client for the Ollama API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smollama'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install smollama

## Usage

### Basic Configuration

Configure the client at application startup:

```ruby
require 'smollama'

Smollama::Client.configure do |config|
  config.server_ip = '10.120.1.122'
  config.server_port = 11434  # optional, defaults to 11434
  config.default_model = 'gpt-oss'
end
```

### Simple Chat

```ruby
client = Smollama::Client.new

response = client.ask("Hello, how are you?")
puts response[:content]
```

### Chat with Parameters

```ruby
response = client.chat(
  "Explain quantum computing",
  temperature: 0.7,
  top_p: 0.9,
  max_tokens: 500
)
puts response[:content]
```

### Streaming Responses

```ruby
client.chat("Tell me a story", stream: true) do |chunk|
  print chunk['message']['content'] if chunk['message']
end
```

### Chat with Conversation History

```ruby
messages = [
  { role: 'system', content: 'You are a helpful assistant.' },
  { role: 'user', content: 'What is Ruby?' },
  { role: 'assistant', content: 'Ruby is a dynamic programming language.' },
  { role: 'user', content: 'What makes it special?' }
]

response = client.chat_with_history(messages, temperature: 0.8)
puts response[:content]
```

### Using Different Models

```ruby
# Use a different model for a specific client
special_client = Smollama::Client.new(model: 'llama2')
response = special_client.ask("Hello!")
```

### Server Health Check

```ruby
if client.ping
  puts "Ollama server is reachable"
else
  puts "Cannot reach Ollama server"
end
```

### List Available Models

```ruby
models = client.list_models
puts "Available models: #{models['models'].map { |m| m['name'] }.join(', ')}"
```

## Configuration Options

- `server_ip`: The IP address of your Ollama server (required)
- `server_port`: The port number (optional, defaults to 11434)
- `default_model`: The default model to use for all clients

## Chat Parameters

- `temperature`: Controls randomness (0.0 to 1.0)
- `top_p`: Controls nucleus sampling (0.0 to 1.0)
- `max_tokens`: Maximum number of tokens to generate
- `stream`: Enable streaming responses (boolean)

## Response Format

Non-streaming responses return a hash with:

- `:content` - The generated text
- `:model` - Model used
- `:created_at` - Timestamp
- `:total_duration` - Total processing time
- `:eval_count` - Number of tokens evaluated
- `:eval_duration` - Evaluation time

## Error Handling

The client gracefully handles errors and returns error information in the response:

```ruby
response = client.ask("Hello")
if response[:error]
  puts "Error: #{response[:error]}"
else
  puts response[:content]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/makevoid/smollama.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).