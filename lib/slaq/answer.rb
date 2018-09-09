module Slaq
  class Answer
    attr_reader :answer

    def initialize(answerer, answer)
      @answerer = answerer
      @answer = answer
    end

    def judge
      if answer == quiz.answer
        command.correct
      else
        command.incorrect
      end
    end
  end
end
