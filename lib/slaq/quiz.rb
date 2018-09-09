require_relative 'quiz/respondent'
require_relative 'progress'
require_relative 'wikipedia'

module Slaq
  class Quiz
    include Slaq::Quiz::Respondent

    ANSWER_LIMIT_TIME=10.freeze

    attr_accessor :question, :answer, :wiki_link

    def initialize
      quiz = random
      @question = quiz[:question]
      @answer = quiz[:answer]
      @wiki_link = Slaq::Wikipedia.find_link_by_answer(answer)
    end

    def random
      quizzes.sample
    end

    private

    def quizzes
      @quizzes ||= set_quizzes_from_text_file
    end

    def set_quizzes_from_text_file
      quizzes = []
      quizzes_dir_path = File.expand_path('../../quizzes', __dir__)

      File.open("#{quizzes_dir_path}/quiz.txt", "r:UTF-8") do |quiz_file|
        quiz_file.each_line do |quiz|
          splited = quiz.split(",")
          quizzes << { question: splited[0].chomp, answer: splited[1].chomp }
        end
      end

      quizzes
    end
  end
end
