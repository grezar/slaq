module Slaq
  class Quiz
    ANSWER_LIMIT_TIME=10.freeze

    def random
      get_quizzes_from_text_file.sample
    end

    def get_quizzes_from_text_file
      quizzes_dir_path = File.expand_path('../../quizzes', __dir__)
      quizzes = []

      File.open("#{quizzes_dir_path}/quiz.txt", "r:UTF-8") do |quiz_file|
        quiz_file.each_line do |quiz|
          splited = quiz.split(",")
          quizzes << { quiz: { question: splited[0].chomp, answer: splited[1].chomp } }
        end
      end

      quizzes
    end
  end
end
