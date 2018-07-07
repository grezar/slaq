require_relative '../slack'

module Slaq
  module Workers
    class QuizWorker
      def self.run!
        slack = Slaq::Slack.new
        redis = Slaq::Redis.new
        redis.flushdb

        loop do
          if redis.get_signal == 'continue'
            slack.post_quiz_text_continuously
            redis.set_signal('next')
          end
        end
      end
    end
  end
end
