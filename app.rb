require 'slack-ruby-client'
require_relative 'lib/slaq'

SLAQ_COMMANDS = %w(q a g s)

Slack::RealTime::Client.configure do |config|
  config.token = ENV['SLAQ_RTM_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::DEBUG
  raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
end

class App
  extend Slaq::Command

  class << self
    def start!
      client = Slack::RealTime::Client.new

      client.on :hello do
        puts "Successfully connected, welcome '#{client.self.name}'"
      end

      client.on :message do |data|
        if SLAQ_COMMANDS.include?(data.text)
          __send__("command_#{data.text}", data)
          next
        end

        unless progress.revoked?(data.user)
          answer = Slaq::Answer.new(data.user, data.text)
          answer.judge
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

    private

    def progress
      @progress ||= Slaq::Progress.new
    end

    def redis
      @redis ||= Slaq::Redis.new
    end
  end
end

App.start!
