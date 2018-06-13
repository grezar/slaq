require 'google_drive'

module Slaq
  class Quiz
    def random
      get_all_quizzes_from_google_drive.sample
    end

    def get_all_quizzes_from_google_drive
       [
         {question: "物を荒々しくつかむ事を、ある鳥に例えて、なにつかみというでしょう?", answer: "わしづかみ"},
         {question: "牛２頭で、いちにちに耕した面積が起源といわれる、ヤード・ポンド法の面積の単位は何でしょう？", answer: "エーカー"},
         {question: "世界三大料理と言えば、フランス料理、中華料理と、あと一つは何でしょう？", answer: "トルコ料理"},
         {question: "いわゆる「四書五経」の「四書」とは、『大学』『孟子』『論語』となんでしょう？", answer: "中庸"}
       ]
    end
  end
end
