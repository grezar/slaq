require_relative 'quiz/respondent'
require_relative 'quiz/status'
require_relative 'wikipedia'

module Slaq
  class Quiz
    include Slaq::Quiz::Respondent
    include Slaq::Quiz::Status

    ANSWER_LIMIT_TIME=10.freeze

    attr_accessor :question, :answer, :wiki_link, :status, :respondent, :time_pressed_a, :revoked_users, :quizzes

    def initialize
      @question = nil
      @answer = nil
      @wiki_link = nil
      @status = nil
      @respondent = 'anonymous'
      @time_pressed_a = nil
      @revoked_users = []
      @quizzes = []

      set_quizzes_from_text_file
    end

    def random
      quizzes.sample
    end

    private

    def set_quizzes_from_text_file
      quizzes_dir_path = File.expand_path('../../quizzes', __dir__)

      File.open("#{quizzes_dir_path}/quiz.txt", "r:UTF-8") do |quiz_file|
        quiz_file.each_line do |quiz|
          splited = quiz.split(",")
          quizzes << { quiz: { question: splited[0].chomp, answer: splited[1].chomp } }
        end
      end
    end
  end
end
