
# frozen_string_literal: true

require 'faraday'

module I18nUno
  class OpenAIClient
    def initialize
      @connection = Faraday.new(
        url: 'https://api.openai.com',
        headers: { 'Authorization' => "Bearer #{I18nUno.config.open_ai_key}",
                   'Content-Type' => 'application/json; charset=utf-8' }
      ) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.options[:timeout] = 600
        faraday.options[:open_timeout] = 30
      end
    end

    def complete(messages:, response_format: nil)
      request_body = {
        model: I18nUno.config.open_ai_model,
        messages: messages
      }

      request_body[:response_format] = response_format if response_format

      response = @connection.post('/v1/chat/completions') do |request|
        request.body = request_body.to_json
      end

      JSON.parse(response.body)['choices'].first['message']['content']
    rescue StandardError => e
      Rails.logger.error(e)
      raise
    end
  end
end
