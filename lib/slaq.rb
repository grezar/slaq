require 'slack-ruby-client'
require_relative 'slaq/io/slack'
require_relative 'slaq/workers/event_worker'

module Slaq
  def self.start!
    io_slack = Slaq::IO::Slack.new
    io_slack.handle_messages
  end
end
