# frozen_string_literal: true

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

    def complete(messages:)
      response = @connection.post('/v1/chat/completions') do |request|
        request.body = {
          model: I18nUno.config.open_ai_model,
          messages: messages.map { |message| { role: :user, content: message } },
          max_tokens: 4096
        }.to_json
      end

      JSON.parse(response.body)['choices'].first['message']['content']
    rescue StandardError => e
      Rails.logger.error(e)
      raise
    end
  end
end
