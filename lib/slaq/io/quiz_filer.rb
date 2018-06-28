module Slaq
  module IO
    class QuizFiler
      tmp_dir_path = File.expand_path("../../tmp", __dir__)

      def write_quiz(quiz = {})
        question = quiz.fetch(:question)
        answer = quiz.fetch(:answer)

        File.open("#{tmp_dir_path}/quiz.txt", "w") do |quiz_file|
          quiz_file.puts("question: #{question}\n")
          quiz_file.puts("answer: #{answer}\n")
        end
      end

      def write_signal(signal = {})
        signal = signal.fetch(:signal)

        File.open("#{tmp_dir_path}/quiz.txt", "w") do |quiz_file|
          quiz_file.puts("signal: #{signal}")
        end
      end
    end
  end
end
