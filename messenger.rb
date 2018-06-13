class Messenger

  attr_reader :client, :data
  def initialize(client, data)
    @client = client
    @data = data
  end

  def quiz(question)
    before_post_ts = nil
    message = nil

    question.each_char.each_slice(2).map(&:join).each do |chars|
      if before_post_ts.nil?
        response = client.web_client.chat_postMessage(channel: data.channel, text: chars)
        before_post_ts = response.ts
        message = chars
      else
        message += chars
        client.web_client.chat_update(channel: data.channel, text: message, ts: before_post_ts)
      end
    end
  end

  def answer(message)
    client.message(channel: data.channel, text: "答え: #{message}")
  end

  def introduce
    client.message(channel: data.channel, text: "答えをどうぞ")
  end
end
