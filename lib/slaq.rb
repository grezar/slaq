require 'slack-ruby-client'
require 'eventmachine'
require_relative 'slaq/quiz'
require_relative 'slaq/quizmaster'

module Slaq
  ANSWER_LIMIT_TIME=10.freeze

  Slack::RealTime::Client.configure do |config|
    config.token = ENV['SLAQ_RTM_API_TOKEN']
    config.logger = Logger.new(STDOUT)
    config.logger.level = Logger::DEBUG
    raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
  end

  def self.start!
    client = Slack::RealTime::Client.new
    quizmaster = Slaq::Quizmaster.new(client)
    quiz_filer = Slaq::IO::QuizFiler.new

    client.on :hello do
      puts "Successfully connected, welcome '#{client.self.name}'"
    end

    time_pressed_a = 0
    respondant = nil
    answer = nil

    client.on :message do |data|

      time_taken_to_answer = data.ts.to_i - time_pressed_a
      if data.text != 'g' && data.user == respondant && time_taken_to_answer < ANSWER_LIMIT_TIME
        if data.text == answer
          quizmaster.correct
          quiz_filer.write_signal(signal: 'next')
        else
          quizmaster.wrong
          quiz_filter.write_signal(signal: 'start')
        end
      end

      case data.text
      when 'q' then
        quiz = Quiz.new.random
        answer = quiz.fetch(:answer)
        quiz_filer.write_quiz(quiz)
      when 'a' then
        respondant = data.user
        time_pressed_a = data.ts.to_i
        quiz_filer.write_signal(signal: 'stop')
      when 'g' then
        quizmaster.answer(answer)
      end
    end

    client.on :close do |_data|
      puts 'Connection closing, exiting.'
    end

    client.on :closed do |_data|
      puts 'Connection has been disconnected.'
      client.start!
    end

    client.start!
    Slaq::Worker::Quiz.start!
  end
end
