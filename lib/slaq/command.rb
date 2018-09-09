module Slaq
  module Command
    def command_q(data)
      return if progress.in_progress?
      redis.flushdb
      quiz = Slaq::Quiz.new
      progress.status = Slaq::Progress::CONTINUE
      redis.set_quiz(data, quiz)
      redis.set_signal(progress.status)
    end

    def command_a(data)
      return unless progress.in_progress?
      return if progress.revoked?(data.user)

      if redis.get_signal == Slaq::Progress::CONTINUE
        progress.status = Slaq::Progress::PAUSE
        redis.set_signal(progress.status)
      end

      progress.respondent = data.user
      progress.time_pressed_a = data.ts.to_i
      post_urge_the_answer(data.channel, data.user)
    end

    def command_g(data)
      return unless progress.in_progress?
      progress.status = Slaq::Progress::NEXT
      redis.set_signal(progress.status)
      post_answer(data.channel, quiz.question, quiz.answer, quiz.wiki_link)
      progress.respondent = 'anonymous'
      progress.revoke(data.user)
    end

    def command_s(data)
      return if quiz.question.nil?
      post_answer(data.user, quiz.question, quiz.answer, quiz.wiki_link)
      progress.revoke(data.user)
    end

    def correct(data)
      progress.status = Slaq::Progress::NEXT
      redis.set_signal(progress.status)
      progress.respondent = 'anonymous'
      post_answer(data.channel, quiz.question, quiz.answer, quiz.wiki_link)
      post_correct(data.channel)
    end

    def incorrect(data)
      progress.status = Slaq::Progress::CONTINUE
      redis.set_signal(progress.status) if redis.get_signal != Slaq::Progress::NEXT
      progress.respondent = 'anonymous'
      progress.revoke(data.user)
      post_wrong(data.channel)
    end
  end
end
