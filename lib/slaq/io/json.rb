require 'json'

module Slaq
  module IO
    class Json
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def write_quiz(quiz = {})
        File.open("#{path}/quiz.json", 'w') { |quiz_file| JSON.dump(quiz, quiz_file) }
      end

      def write_signal(signal = {})
        File.open("#{path}/signal.json", "w") { |quiz_file| JSON.dump(quiz, quiz_file) }
      end
    end
  end
end
