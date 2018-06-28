require 'slaq/quizmaster'

module Slaq
  module Worker
    module Quiz
      def run
        tmp_dir_path = File.expand_path("../../tmp", __dir__)
        quizmaster = Slaq::Quizmaster.new

        loop do
          if question_file_exist?
            question = nil

            File.open("#{tmp_dir_path}/question.txt", "r+") do |question_file|
              question_file.each_line do |line|

                case line
                when line.include?("question:")
                  question = line.slice!(/^question:\s/)
                  quizmaster.question(question, signal)
                when line.include?("answer:")
                  answer = line.slice!(/^answer:\s/)
                  quizmaster.answer(answer)
                when line.include?("signal:")
                  signal = line.slice!(/^signal:\s/)
                end
              end
            end
          end
        end

        private
        def question_file_exist?
          File.exist?("tmp/question.txt")
        end
      end
    end
  end
end
