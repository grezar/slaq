require 'redis'
require 'json'

module Slaq
  class Redis

    def flushdb
      redis.flushdb
    end

    def set_quiz(data, quiz)
      set_channel(data.channel)
      set_question(quiz.question)
      set_answer(quiz.answer)
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
      @redis ||= ::Redis.new(url: ENV['REDIS_URL'])
    end
  end
end
