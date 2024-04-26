# frozen_string_literal: true

require 'yaml'
require 'i18n_uno/open_ai_client'

module I18nUno
  class Translator
    attr_reader :source_file, :target_file

    def initialize(sot_file, target_file)
      @source_file  = sot_file
      @target_file  = target_file
      @target_file_yaml = YAML.load_file(target_file.file_path)
    end

    def process(delta)
      delta.values_from!(@source_file)

      if delta.anything_to_translate?
        delta = send_to_chatgpt_api(delta)

        target_file.add_missing_keys_to_target_file!(delta)
        target_file.match_order_as_file!(source_file)
        target_file.set_values_from_delta!(delta)
        target_file.save!
      else
        puts 'Missing keys are all null, nothing to translate'
      end
    end

    private

    def send_to_chatgpt_api(delta)
      values_to_translate = delta.values
      client = OpenAIClient.new
      translated_values = []

      values_to_translate.each_slice(200) do |chunk|
        messages = [%Q(
          Please translate the following list of strings from the source language specified by '#{source_file.locale}'
          to the target language indicated by '#{target_file.locale}'. The translations should be suitable for use
          in a user interface, taking into account that shorter strings are likely to be used as button labels or
          element captions. Never translate inside "%{}" brackets. The output should be in the form of an array
          containing the translated messages, ensuring that each translated value is accurate and correctly formatted
          for JSON parsing. Special attention should be paid to maintaining the context and usability of each UI
          element in the target language. Below is the list for translation:
        ).gsub(/\s{2,}/, ' ').strip]

        messages << chunk.to_json

        response = client.complete(messages: messages)
        chunk_translated_values = JSON.parse(response)

        translated_values.concat(chunk_translated_values)
      end

      delta.translated_values = translated_values
      delta
    end
  end
end
