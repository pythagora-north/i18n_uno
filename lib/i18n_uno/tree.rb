# frozen_string_literal: true

module I18nUno
  class Tree
    attr_reader :locale

    def initialize(locale)
      @locale = locale
      @data   = []       # [{ file: I18nUno::File, delta: I18nUno::DiffDelta }]
      collect_files
    end

    def process_delta_changes(source_of_truth_tree)
      entries_with_delta = extract_entries_with_delta

      if entries_with_delta.empty?
        puts "No changes detected for '#{locale}' locale."
        return
      end

      files_completed  = 0
      puts "Processing locale '#{locale}' there are #{entries_with_delta.count} files with changes. "
      entries_with_delta.each_with_index do |entry, index|
        printf("Processing file %-40s [#{index + 1}/#{entries_with_delta.count}] ... ", "'#{entry[:file].pp_file_name}'")

        if entry[:delta].any_new_keys?
          sot_file = source_of_truth_tree.find_file(entry[:file])
          translator = I18nUno::Translator.new(sot_file, entry[:file])
          translator.process(entry[:delta])
        end

        if entry[:delta].any_removed_keys? && !entry[:delta].complete_file_diff?
          entry[:file].remove_keys_from_file!(entry[:delta])
        end

        entry[:processed] = true

        puts 'OK'
      end
    end

    def extract_entries_with_delta
      @data.select do |entry|
        entry[:delta].present? && entry[:delta].any_changes?
      end
    end

    def add_delta!(file, diff_delta)
      @data.each do |entry|
        if entry[:file] == file
          entry[:delta] = diff_delta
          break
        end
      end
    end

    def files
      @data.map { |entry| entry[:file] }
    end

    def any?
      @data.any?
    end

    def empty?
      @data.empty?
    end

    def each(&block)
      files.each(&block)
    end

    def find_file(target_file)
      files.find { |file| file.file_path.match(/#{target_file.file_identifier}/) }
    end

    def find_or_create_file(sot_file)
      file = find_file(sot_file)

      if file.nil?
        file = sot_file.create_in_locale(locale)
        @data << { file: file, delta: nil, new_file: true, processed: false }
      end

      file
    end

    def clean_not_processed_files
      @data.each do |entry|
        if (entry[:new_file] && !entry[:processed])
          ::File.delete(entry[:file].file_path)
        end
      end

    end

    private

    def collect_files
      path_pattern = ::File.join(I18nUno.config.load_path, '**', "#{locale}.yml")
      Dir.glob(path_pattern).map do |file_path|
        @data << { file: I18nUno::File.new(file_path), delta: nil }
      end
    end
  end
end
