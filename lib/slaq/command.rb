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
      return unless quiz.processing?
      return unless answer.has_answer_rights?

      if redis.get_signal == Slaq::Progress::CONTINUE
        progress.status = Slaq::Progress::PAUSE
        redis.set_signal(progress.status)
      end

      quiz.respondent = data.user
      quiz.time_pressed_a = data.ts.to_i
      post_urge_the_answer(data.channel, data.user)
    end

    def command_g(data)
      return unless quiz.processing?
      progress.status = Slaq::Progress::NEXT
      redis.set_signal(progress.status)
      post_answer(data.channel, quiz.question, quiz.answer, quiz.wiki_link)
      quiz.respondent = 'anonymous'
      quiz.revoke_answer_rights(data.user)
    end

    def command_s(data)
      return if quiz.question.nil?
      post_answer(data.user, quiz.question, quiz.answer, quiz.wiki_link)
      quiz.revoke_answer_rights(data.user)
    end

    def correct(data)
      progress.status = Slaq::Progress::NEXT
      redis.set_signal(progress.status)
      quiz.respondent = 'anonymous'
      post_answer(data.channel, quiz.question, quiz.answer, quiz.wiki_link)
      post_correct(data.channel)
    end

    def incorrect(data)
      progress.status = Slaq::Progress::CONTINUE
      redis.set_signal(progress.status) if redis.get_signal != Slaq::Progress::NEXT
      quiz.respondent = 'anonymous'
      quiz.revoke_answer_rights(data.user)
      post_wrong(data.channel)
    end
  end
end
