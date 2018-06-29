module Slaq
  module IO
    class Json
      module Quiz
        def quiz_file_exist?
          File.exist?("#{path}/quiz.json")
        end

        def read_quiz
          File.open("#{path}/quiz.json", "r+") do |quiz_file|

            quiz_file.each_line do |line|
              if line.include?("question:")
                question = line.gsub(/^question:\s/, "")
              elsif line.include?("answer:")
                answer = line.gsub(/^answer:\s/, "")
              else
                signal = line.gsub(/^signal:\s/, "")
              end
            end

            # 読み込んだら空にする
            quiz_file = nil
          end
        end

        def write_quiz(quiz = {})
          File.open("#{path}/quiz.json", 'w') { |quiz_file| JSON.dump(quiz, quiz_file) }
        end
      end
    end
  end
end
