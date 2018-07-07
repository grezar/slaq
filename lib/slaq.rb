require 'slack-ruby-client'
require_relative 'slaq/slack'
require_relative 'slaq/workers/quiz_worker'

module Slaq
  def self.start!
    slack = Slaq::Slack.new
    slack.handle_messages
  end
end
