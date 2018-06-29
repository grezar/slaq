module Slaq
  module IO
    class Json
      module Quiz
        def quiz_file_exist?
          File.exist?("#{path}/quiz.json")
        end

        def quiz_file_has_content?
          File.size?("#{path}/quiz.json")
        end

        def read_quiz
          quiz = nil
          File.open("#{path}/quiz.json", "r+") do |quiz_file|
            quiz = JSON.load(quiz_file)
          end
          quiz
        end

        def write_quiz(quiz = {})
          File.open("#{path}/quiz.json", 'w') do |quiz_file|
            JSON.dump(quiz, quiz_file)
          end
        end

        def truncate_quiz_file
          if quiz_file_exist?
            File.open("#{path}/quiz.json", 'w') { |quiz_file| quiz_file.truncate(0) }
          end
        end
      end
    end
  end
end
