require 'slack-ruby-client'

module Slaq
  module Worker
    module Quiz

      Slack.configure do |config| config.token = ENV['SLAQ_RTM_API_TOKEN']
        config.logger = Logger.new(STDOUT)
        config.logger.level = Logger::DEBUG
        raise 'Missing ENV[SLAQ_RTM_API_TOKEN]!' unless config.token
      end

      def self.run
        tmp_dir_path = File.expand_path("../../../tmp", __dir__)
        signal = nil

        client = Slack::Web::Client.new

        loop do
          next unless File.exist?("#{tmp_dir_path}/quiz.json")
          question = nil
          answer = nil

          File.open("#{tmp_dir_path}/quiz.json", "r+") do |question_file|

            question_file.each_line do |line|
              if line.include?("question:")
                question = line.gsub(/^question:\s/, "")
              elsif line.include?("answer:")
                answer = line.gsub(/^answer:\s/, "")
              else
                signal = line.gsub(/^signal:\s/, "")
              end
            end

            before_post_ts = nil
            message = nil

            question.chars.each_slice(2).map(&:join).each do |char|
              if before_post_ts.nil?
                response = client.chat_postMessage(channel: data.channel, text: chars)
                before_post_ts = response.ts
                message = chars
              else
                if signal == 'stop'
                  sleep 10
                  message += chars
                  client.chat_update(channel: data.channel, text: message, ts: before_post_ts)
                else
                  message += chars
                  client.chat_update(channel: data.channel, text: message, ts: before_post_ts)
                end
              end
            end
          end
        end
      end
    end
  end
end
