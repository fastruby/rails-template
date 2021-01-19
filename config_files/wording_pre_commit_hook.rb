module Overcommit::Hook::PreCommit
  # checks use of some words on code and on branch names
  class Wording < Base
    attr_accessor :current_file, :current_line

    def run
      return :fail, "Use `main` as the branch instead of `master`" if master_branch?

      applicable_files.each { |file| check_file(file) }

      return :fail, errors.join("\n") if errors.any?

      :pass
    end

    def check_file(filepath)
      self.current_file = filepath

      File.foreach(filepath).with_index do |line, lineno|
        self.current_line = lineno
        check(line, /blacklist/i, "disallowed list / disallowed")
        check(line, /whitelist/i, "allowed list / allowed")
      end
    rescue
      # rescue exception if trying to parse binary files
    end

    def check(line, regxp, replacement)
      return unless line.match?(regxp) # do nothing if line doesn't match regexp

      add_error("Check wording (prefer #{replacement}): #{line}")
    end

    def errors
      @errors ||= []
    end

    def add_error(message)
      errors.push("#{current_file}##{current_line}: #{message}")
    end

    def master_branch?
      current_branch == "master"
    end
  end
end
