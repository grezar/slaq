module Slaq
  module IO
    class Slack
      module Quiz
        def post_quiz_text_continuously(quiz)
          question = quiz.fetch(:question)
          channel = quiz.fetch(:channel)
          signal = quiz.fetch(:signal)
          last_post_ts = nil

          question.chars.each_slice(2).map(&:join).each do |chars|
            if last_post_ts.nil?
              response = client.chat_postMessage(channel: channel, text: chars)
              last_post_ts = response.ts
              sended_chars = chars
            else
              if signal == 'stop'
                sleep 10
                posted_chars += chars
                client.chat_update(channel: channel, text: posted_chars, ts: last_post_ts)
              else
                posted_chars += chars
                client.chat_update(channel: channel, text: posted_chars, ts: last_post_ts)
              end
            end
          end
        end

        def post_answer_right
          client.message(channel: data.channel, text: "答えをどうぞ")
        end

        def post_correct
          client.message(channel: data.channel, text: ":soreseikai:")
        end

        def post_wrong
          client.message(channel: data.channel, text: ":tigaimasu:")
        end

        def post_answer
          client.message(channel: data.channel, text: "答え: #{message}")
        end
      end
    end
  end
end
