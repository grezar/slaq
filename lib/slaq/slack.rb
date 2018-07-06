require 'slack-ruby-client'
require_relative 'quiz'
require_relative 'slack/quiz'
require_relative 'wikipedia'
require_relative 'redis'

module Slaq
  class Slack
    include Slaq::Slack::Quiz

    ::Slack::RealTime::Client.configure do |config|
      config.token = ENV['SLAQ_RTM_API_TOKEN']
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::DEBUG
      raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
    end

    attr_reader :client, :wikipedia

    def initialize
      @client = ::Slack::RealTime::Client.new
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
        if data.text != 'g' && data.text != 'q' && data.user == respondant && time_taken_to_answer < Slaq::Quiz::ANSWER_LIMIT_TIME
          if data.text == answer
            redis.set_signal('next')
            respondant = 'anonymous'
            during_quiz = nil
            post_answer(data.channel, question, answer, wiki_link)
            post_correct(data.channel)
          else
            redis.set_signal('continue')
            respondant = 'anonymous'
            post_wrong(data.channel)
          end
        end

        case data.text
        when 'q'
          unless during_quiz
            quiz = Slaq::Quiz.new.random
            quiz.store("channel".to_sym, data.channel)
            question = quiz[:quiz][:question]
            answer = quiz[:quiz][:answer]
            during_quiz = true
            wiki_link = wikipedia.find_link_by_answer(answer)
            Slaq::QuizWorker.perform_async(quiz)
            redis.set_signal('continue')
          end
        when 'a'
          if (during_quiz && respondant == 'anonymous') || time_taken_to_answer > Slaq::Quiz::ANSWER_LIMIT_TIME
            redis.set_signal('pause')
            post_urge_the_answer(data.channel, data.user)
            respondant = data.user
            time_pressed_a = data.ts.to_i
          end
        when 'g'
          if during_quiz
            post_answer(data.channel, question, answer, wiki_link)
            redis.set_signal('next')
            respondant = 'anonymous'
            during_quiz = nil
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
