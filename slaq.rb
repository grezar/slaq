require 'slack-ruby-client'
require 'eventmachine'
require './quiz'
require './messenger'

Slack::RealTime::Client.configure do |config|
  config.token = ENV['SLAQ_RTM_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
  fail 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}'"
end

answer_time = nil
respondant = nil
answer = nil

client.on :message do |data|
  messenger ||= Messenger.new(client, data)

  if answer_time && data.user == respondant && data.text != 'g'
    if data.text == answer
      client.message(channel: data.channel, text: ":soreseikai:")
      answer_time = false
    else
      client.message(channel: data.channel, text: ":tigaimasu:")
    end
  end

  case data.text
  when 'q' then
    quiz = Quiz.new.get_all_quiz.sample
    question = quiz.fetch(:question)
    answer = quiz.fetch(:answer)
    messenger.quiz(question)
  when 'a' then
    messenger.introduce
    answer_time = true
    respondant = data.user
  when 'g' then
    messenger.answer(answer)
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
