require 'slack-ruby-client'
require_relative 'quiz'
require_relative 'slack/quiz'
require_relative 'wikipedia'
require_relative 'redis'

module Slaq
  class Slack
    include Slaq::Slack::Quiz

    COMMANDS = %w(q a g s)

    ::Slack::RealTime::Client.configure do |config|
      config.token = ENV['SLAQ_RTM_API_TOKEN']
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::DEBUG
      raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
    end

    attr_reader :client, :redis, :wikipedia

    def initialize
      @client = ::Slack::RealTime::Client.new
      @redis = Slaq::Redis.new
      @wikipedia = Slaq::Wikipedia.new
    end

    def handle_messages
      client.on :hello do
        puts "Successfully connected, welcome '#{client.self.name}'"
      end

      time_pressed_a = 0
      respondant = 'anonymous'
      question = nil
      answer = nil
      during_quiz = nil
      wiki_link = nil

      client.on :message do |data|
        time_taken_to_answer = data.ts.to_i - time_pressed_a
        if !Slaq::Slack::COMMANDS.include?(data.text) && data.user == respondant && time_taken_to_answer < Slaq::Quiz::ANSWER_LIMIT_TIME
          if data.text == answer
            redis.set_signal('next')
            respondant = 'anonymous'
            during_quiz = nil
            post_answer(data.channel, question, answer, wiki_link)
            post_correct(data.channel)
          else
            redis.set_signal('continue') if redis.get_signal != 'next'
            respondant = 'anonymous'
            post_wrong(data.channel)
          end
        end

        case data.text
        when 'q'
          unless during_quiz
            redis.flushdb
            quiz = Slaq::Quiz.new.random
            question = quiz[:quiz][:question]
            answer = quiz[:quiz][:answer]
            during_quiz = true
            wiki_link = wikipedia.find_link_by_answer(answer)
            redis.set_channel(data.channel)
            redis.set_question(question)
            redis.set_answer(answer)
            redis.set_signal('continue')
          end
        when 'a'
          if (during_quiz && respondant == 'anonymous') || time_taken_to_answer > Slaq::Quiz::ANSWER_LIMIT_TIME
            redis.set_signal('pause') if redis.get_signal == 'continue'
            post_urge_the_answer(data.channel, data.user)
            respondant = data.user
            time_pressed_a = data.ts.to_i
          end
        when 'g'
          if during_quiz
            redis.set_signal('next')
            post_answer(data.channel, question, answer, wiki_link)
            respondant = 'anonymous'
            during_quiz = nil
          end
        when 's'
          unless question.nil?
            post_answer(data.user, question, answer, wiki_link)
          end
        end
      end

      client.on :close do |data|
        puts 'Connection closing, exiting.'
      end

      client.on :closed do |data|
        puts 'Connection has been disconnected.'
        client.start!
      end

      client.start!
    end
  end
end
