module Overcommit::Hook::PreCommit
  # checks OmbuLabs and FastRuby.io branding
  class Branding < Base
    # valid variants of the brands
    VALID_OMBULABS = [/OmbuLabs/, /www\.ombulabs\.com/, /ombulabs\//, /ombulabs-styleguide/, /ombu_labs/, /github\.com\/ombulabs/]
    VALID_FASTRUBY = [/FastRuby\.io/, /https?:\/\/\S*fastruby\S*\.io/, /fastruby[\/:]/, /fastruby-io-styleguide/]

    def run
      applicable_files.each { |file| check_file(file) }

      return :fail, errors.join("\n") if errors.any?

      :pass
    end

    def check_file(filepath)
      @current_file = filepath

      File.foreach(filepath).with_index do |line, lineno|
        @current_line = lineno
        check(line, /omb.\s*labs/i, VALID_OMBULABS)
        check(line, /fastruby/i, VALID_FASTRUBY)
      end
    rescue
      # rescue exception if trying to parse binary files
    end

    def check(line, regxp, valid_list)
      return unless line.match?(regxp) # do nothing if line doesn't match regexp

      clean_line = line
      valid_list.each { |brand| clean_line.gsub!(brand, "") }

      return unless line.match?(regxp) # if it doesn't match it means all ocurrences were valid

      # # do nothing if line contains valid 
      # invalid_line = valid_list.none? { |valid_brand| line =~ valid_brand }
      # return unless invalid_line

      add_error("Invalid branding: #{line}")
    end

    def errors
      @errors ||= []
    end

    def add_error(message)
      errors.push("#{@current_file}##{@current_line}: #{message}")
    end
  end
end
