require 'excon'
require 'json'
require 'base64'

module Smollama
  class Client
    # Class-level configuration
    class << self
      attr_accessor :server_ip, :server_port, :default_model

      def configure
        yield self if block_given?
      end

      def base_url
        raise "Server IP not configured" unless server_ip
        port = server_port || 11434
        "http://#{server_ip}:#{port}"
      end
    end

    # Initialize with optional overrides
    def initialize(model: nil)
      @model = model || self.class.default_model
      raise "Model not specified" unless @model

      @connection = Excon.new(
        "#{self.class.base_url}/api/chat",
        persistent: true,
        headers: {
          'Content-Type' => 'application/json'
        }
      )
    end

    # Main chat method with configurable parameters
    def chat(message, temperature: nil, top_p: nil, max_tokens: nil, stream: false, images: nil)
      messages = build_messages(message, images: images)

      payload = {
        model: @model,
        messages: messages,
        stream: stream
      }

      # Add optional parameters if provided
      payload[:options] = {} if temperature || top_p
      payload[:options][:temperature] = temperature if temperature
      payload[:options][:top_p] = top_p if top_p
      payload[:options][:num_predict] = max_tokens if max_tokens

      if stream
        stream_response(payload) { |chunk| yield chunk if block_given? }
      else
        send_request(payload)
      end
    end

    # Convenience method for single message chat
    def ask(prompt, **options)
      chat(prompt, **options)
    end

    # Chat with conversation history
    def chat_with_history(messages, **options)
      raise "Messages must be an array" unless messages.is_a?(Array)

      payload = {
        model: @model,
        messages: messages,
        stream: options[:stream] || false
      }

      # Add optional parameters
      payload[:options] = {}
      payload[:options][:temperature] = options[:temperature] if options[:temperature]
      payload[:options][:top_p] = options[:top_p] if options[:top_p]
      payload[:options][:num_predict] = options[:max_tokens] if options[:max_tokens]

      if payload[:stream]
        stream_response(payload) { |chunk| yield chunk if block_given? }
      else
        send_request(payload)
      end
    end

    # Get available models
    def list_models
      response = Excon.get(
        "#{self.class.base_url}/api/tags",
        headers: { 'Content-Type' => 'application/json' }
      )

      JSON.parse(response.body)
    rescue Excon::Error => e
      { error: "Failed to list models: #{e.message}" }
    end

    # Check if server is reachable
    def ping
      response = Excon.get("#{self.class.base_url}/")
      response.status == 200
    rescue Excon::Error
      false
    end

    private

    def build_messages(input, images: nil)
      messages = case input
      when String
        [{ role: 'user', content: input }]
      when Hash
        [input]
      when Array
        input
      else
        raise "Invalid message format"
      end

      # Add images to the last user message if provided
      if images && !images.empty?
        encoded_images = encode_images(images)
        messages.last[:images] = encoded_images
      end

      messages
    end

    def encode_images(images)
      Array(images).map do |image|
        case image
        when String
          if image.start_with?('http://', 'https://')
            # URL - Ollama can handle URLs directly, but we'll fetch and encode
            require 'open-uri'
            Base64.strict_encode64(URI.open(image).read)
          elsif File.exist?(image)
            # File path
            Base64.strict_encode64(File.read(image))
          else
            # Assume it's already base64 encoded
            image
          end
        else
          raise "Invalid image format: #{image.class}"
        end
      end
    end

    def send_request(payload)
      response = @connection.post(
        body: payload.to_json,
        read_timeout: 120,
        write_timeout: 120
      )

      parse_response(response)
    rescue Excon::Error::Timeout => e
      { error: "Request timeout: #{e.message}" }
    rescue Excon::Error => e
      { error: "Request failed: #{e.message}" }
    end

    def stream_response(payload)
      buffer = ""

      @connection.post(
        body: payload.to_json,
        read_timeout: 120,
        write_timeout: 120,
        response_block: lambda do |chunk, remaining_bytes, total_bytes|
          buffer += chunk

          # Process complete JSON objects from buffer
          while (line_end = buffer.index("\n"))
            line = buffer[0...line_end]
            buffer = buffer[(line_end + 1)..-1]

            next if line.strip.empty?

            begin
              data = JSON.parse(line)
              yield data if block_given?
            rescue JSON::ParserError => e
              puts "Failed to parse JSON: #{e.message}"
            end
          end
        end
      )

      { status: 'stream_complete' }
    rescue Excon::Error => e
      { error: "Stream failed: #{e.message}" }
    end

    def parse_response(response)
      return { error: "Empty response" } if response.body.nil? || response.body.empty?

      data = JSON.parse(response.body)

      # Extract the assistant's message content
      if data['message']
        {
          content: data['message']['content'],
          model: data['model'],
          created_at: data['created_at'],
          total_duration: data['total_duration'],
          eval_count: data['eval_count'],
          eval_duration: data['eval_duration']
        }
      else
        data
      end
    rescue JSON::ParserError => e
      { error: "Failed to parse response: #{e.message}", raw: response.body }
    end
  end
end