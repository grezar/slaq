require_relative '../../quiz'

module Slaq
  module IO
    class Slack
      module Quiz
        def post_quiz_text_continuously(quiz = {})
          question = quiz["quiz"]["question"]
          channel = quiz["channel"]
          last_post_ts = nil
          posted_chars = nil
          during_quiz = nil

          question.chars.each_slice(2).map(&:join).each do |chars|
            signal = io_json.read_signal["signal"]

            if last_post_ts.nil? && signal != 'next'
              response = client.web_client.chat_postMessage(channel: channel, text: chars)
              last_post_ts = response.ts
              posted_chars = chars
            else
              case signal
              when 'continue'
                posted_chars += chars
                client.web_client.chat_update(channel: channel, text: posted_chars, ts: last_post_ts)
              when 'next'
                break
              when 'pause'
                pause_time = 0
                posted_chars += chars
                until signal != 'pause'
                  sleep 0.1
                  pause_time += 0.1
                  puts pause_time
                  signal = io_json.read_signal["signal"]
                  if pause_time > Slaq::Quiz::ANSWER_LIMIT_TIME
                    post_timeup(channel)
                    sleep 1
                    client.web_client.chat_update(channel: channel, text: posted_chars, ts: last_post_ts)
                    signal = io_json.write_signal(signal: 'continue')
                    next
                  end
                end
                client.web_client.chat_update(channel: channel, text: posted_chars, ts: last_post_ts)
              else
                raise 'Unknown signal'
              end
            end
          end
          io_json.truncate_quiz_file
        end

        def post_urge_the_answer(channel, respondant)
          client.message(channel: channel, text: "<@#{respondant}> 答えをどうぞ")
        end

        def post_correct(channel)
          client.message(channel: channel, text: ":soreseikai:")
        end

        def post_wrong(channel)
          client.message(channel: channel, text: ":tigaimasu:")
        end

        def post_answer(channel, question, answer, wiki_link)
          client.web_client.chat_postMessage(
            channel: channel,
            as_user: true,
            attachments: [
              {
                mrkdwn_in: [
                    "pretext"
                ],
                pretext: "_#{question}_",
                title: answer,
                title_link: wiki_link,
                color: "#2eb886",
                author_name: "正解は...",
                author_link: "https://github.com/grezar/slaq",
                author_icon: "http://d2dcan0armyq93.cloudfront.net/photo/odai/400/c212265aabeb54f3680925e73ef9b583_400.jpg"
              }
            ]
          )
        end

        def post_timeup(channel)
          client.web_client.chat_postMessage(channel: channel, text: "不正解。時間切れです")
        end
      end
    end
  end
end
