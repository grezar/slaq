require 'google_drive'

module Slaq
  class Quiz
    ANSWER_LIMIT_TIME=10.freeze

    def random
      get_all_quizzes_from_google_drive.sample
    end

    def get_all_quizzes_from_google_drive
       [
         {
           quiz: {
             question: "物を荒々しくつかむ事を、ある鳥に例えて、なにつかみというでしょう?",
             answer: "わしづかみ"
           }
         },
         {
           quiz: {
             question: "牛２頭で、いちにちに耕した面積が起源といわれる、ヤード・ポンド法の面積の単位は何でしょう？",
             answer: "エーカー"
           }
         },
       ]
    end
  end
end
