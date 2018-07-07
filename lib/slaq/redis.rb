require 'redis'
require 'json'

module Slaq
  class Redis

    def flushdb
      redis.flushdb
    end

    def set_question(question)
      redis.set("question", question)
    end

    def get_question
      redis.get("question")
    end

    def set_answer(answer)
      redis.set("answer", answer)
    end

    def get_answer
      redis.get("answer")
    end

    def set_quiz(quiz)
      redis.set("quiz", quiz.to_json)
    end

    def get_quiz
      redis.get("quiz")
    end

    def set_signal(signal)
      redis.set("signal", signal)
    end

    def get_signal
      redis.get("signal")
    end

    def set_channel(channel)
      redis.set("channel", channel)
    end

    def get_channel
      redis.get("channel")
    end

    def redis
      redis ||= ::Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])
    end
  end
end
