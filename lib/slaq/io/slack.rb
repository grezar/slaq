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

      attr_reader :client

      def initialize
        @client = ::Slack::RealTime::Client.new
      end

      def handle_messages
        tmp_dir_path = File.expand_path("../../../tmp", __dir__)
        io_json = Slaq::IO::Json.new(tmp_dir_path)

        client.on :hello do
          puts "Successfully connected, welcome '#{client.self.name}'"
        end

        time_pressed_a = 0
        respondant = nil
        answer = nil

        client.on :message do |data|
          time_taken_to_answer = data.ts.to_i - time_pressed_a
          if data.text != 'g' && data.user == respondant && time_taken_to_answer < Slaq::Quiz::ANSWER_LIMIT_TIME
            if data.text == answer
              io_slack.post_correct
              io_json.write_signal(signal: 'next')
            else
              io_slack.post_wrong
              io_json.write_signal(signal: 'start')
            end
          end

          case data.text
          when 'q'
            quiz = Slaq::Quiz.new
            quiz.current = quiz.random
            answer = quiz.fetch(:quiz).fetch(:answer)
            io_json.write_quiz(quiz)
          when 'a'
            respondant = data.user
            time_pressed_a = data.ts.to_i
            io_json.write_signal(signal: 'stop')
          when 'g'
            io_slack.post_answer(answer)
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
