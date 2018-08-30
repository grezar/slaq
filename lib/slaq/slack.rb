require 'slack-ruby-client'
require_relative 'quiz'
require_relative 'slack/quiz'
require_relative 'redis'

module Slaq
  class Slack
    include Slaq::Slack::Quiz

    COMMANDS = %w(q a g s)
    POST_INTERVAL = 0.1

    ::Slack::RealTime::Client.configure do |config|
      config.token = ENV['SLAQ_RTM_API_TOKEN']
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::DEBUG
      raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
    end

    attr_reader :client, :redis, :quiz, :wikipedia

    def initialize
      @client = ::Slack::RealTime::Client.new
      @redis = Slaq::Redis.new
      @quiz = Slaq::Quiz.new
      @wikipedia = Slaq::Wikipedia.new
    end

    def handle_messages
      client.on :hello do
        puts "Successfully connected, welcome '#{client.self.name}'"
      end

      client.on :message do |data|
        if quiz.answerable?(data)
          if data.text == quiz.answer
            quiz.status = Slaq::Quiz::Status::NEXT
            redis.set_signal(quiz.status)
            quiz.respondent = 'anonymous'
            post_answer(data.channel, quiz.question, quiz.answer, quiz.wiki_link)
            post_correct(data.channel)
          else
            quiz.status = Slaq::Quiz::Status::CONTINUE
            redis.set_signal(quiz.status) if redis.get_signal != Slaq::Quiz::Status::NEXT
            quiz.respondent = 'anonymous'
            quiz.revoke_answer_rights(data.user)
            post_wrong(data.channel)
          end
        end

        case data.text
        when 'q', ':question:'
          unless quiz.processing?
            redis.flushdb
            quiz.revoked_users.clear
            quiz.status = Slaq::Quiz::Status::CONTINUE
            selected_quiz = quiz.random
            quiz.question = selected_quiz[:quiz][:question]
            quiz.answer = selected_quiz[:quiz][:answer]
            quiz.wiki_link = wikipedia.find_link_by_answer(quiz.answer)
            redis.set_quiz(data, quiz)
            redis.set_signal(quiz.status)
          end
        when 'a', ':raised_hand:', ':raising_hand:', ':man-raising-hand:', ':woman-raising-hand:'
          if quiz.processing? && quiz.has_answer_rights?(data.user) && quiz.respondent == 'anonymous'
            if redis.get_signal == Slaq::Quiz::Status::CONTINUE
              quiz.status = Slaq::Quiz::Status::PAUSE
              redis.set_signal(quiz.status)
            end
            quiz.respondent = data.user
            quiz.time_pressed_a = data.ts.to_i
            post_urge_the_answer(data.channel, data.user)
          end
        when 'g', ':middle_finger:', ':hankey:', ':fu:', ':shrug:', ':shrug_woman:', ':man-shrugging:'
          if quiz.processing?
            quiz.status = Slaq::Quiz::Status::NEXT
            redis.set_signal(quiz.status)
            post_answer(data.channel, quiz.question, quiz.answer, quiz.wiki_link)
            quiz.respondent = 'anonymous'
            quiz.revoke_answer_rights(data.user)
          end
        when 's', ':he:'
          unless quiz.question.nil?
            post_answer(data.user, quiz.question, quiz.answer, quiz.wiki_link)
            quiz.revoke_answer_rights(data.user)
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
