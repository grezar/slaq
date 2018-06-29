require_relative '../io/slack'
require_relative '../io/json'

module Slaq
  module Workers
    module EventWorker
      def self.run!
        tmp_dir_path = File.expand_path("../../../tmp", __dir__)
        io_json = Slaq::IO::Json.new(tmp_dir_path)
        io_slack = Slaq::IO::Slack.new
        io_json.truncate_quiz_file if io_json.quiz_file_exist?
        io_json.truncate_signal_file if io_json.signal_file_exist?

        loop do
          next unless io_json.quiz_file_exist? && io_json.quiz_file_has_content?
          sleep 0.1
          quiz = io_json.read_quiz
          io_slack.post_quiz_text_continuously(quiz)
        end
      end
    end
  end
end
