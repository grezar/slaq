require_relative '../io/slack'
require_relative '../io/json'

module Slaq
  module Workers
    module EventWorker
      def self.run!
        tmp_dir_path = File.expand_path("../../../tmp", __dir__)
        io_json = Slaq::IO::Json.new(tmp_dir_path)
        io_slack = Slaq::IO::Slack.new

        loop do
          next unless io_json.quiz_file_exist?
          quiz = io_json.read_quiz
          io_slack.post_quiz(quiz)
        end
      end
    end
  end
end
