require 'slack-ruby-client'
require_relative '../quiz'
require_relative 'slack/quiz'
require_relative 'json/quiz'

module Slaq
  module IO
    class Slack
      include Slaq::IO::Slack::Quiz

      ::Slack::RealTime::Client.configure do |config|
        config.token = ENV['SLAQ_RTM_API_TOKEN']
        config.logger = Logger.new(STDOUT)
        config.logger.level = Logger::DEBUG
        raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
      end

      attr_reader :client, :io_json

      def initialize
        @client = ::Slack::RealTime::Client.new
        tmp_dir_path = File.expand_path("../../../tmp", __dir__)
        @io_json = Slaq::IO::Json.new(tmp_dir_path)
      end

      def handle_messages
        client.on :hello do
          puts "Successfully connected, welcome '#{client.self.name}'"
        end

        time_pressed_a = 0
        respondant = 'anonymous'
        answer = nil
        during_quiz = nil

        client.on :message do |data|
          time_taken_to_answer = data.ts.to_i - time_pressed_a
          if data.text != 'g' && data.text != 'q' && data.user == respondant && time_taken_to_answer < Slaq::Quiz::ANSWER_LIMIT_TIME
            if data.text == answer
              io_json.write_signal(signal: 'next')
              respondant = 'anonymous'
              during_quiz = nil
              post_correct(data.channel)
            else
              io_json.write_signal(signal: 'continue')
              respondant = 'anonymous'
              post_wrong(data.channel)
            end
          end

          case data.text
          when 'q'
            unless during_quiz
              io_json.truncate_quiz_file if io_json.quiz_file_exist?
              io_json.truncate_signal_file if io_json.signal_file_exist?
              quiz = Slaq::Quiz.new.random
              quiz.store("channel".to_sym, data.channel)
              answer = quiz[:quiz][:answer]
              during_quiz = true
              io_json.write_quiz(quiz)
              io_json.write_signal(signal: 'continue')
            end
          when 'a'
            if (during_quiz && respondant == 'anonymous') || time_taken_to_answer > Slaq::Quiz::ANSWER_LIMIT_TIME
              io_json.write_signal(signal: 'pause')
              post_urge_the_answer(data.channel, data.user)
              respondant = data.user
              time_pressed_a = data.ts.to_i
            end
          when 'g'
            if during_quiz
              post_answer(data.channel, answer)
              io_json.write_signal(signal: 'next')
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
end
