module Slaq
  class Quiz
    module Respondent

      def answerable?(data)
        respondent?(data.user) && !slaq_command?(data.text) && !exceed_answer_limit_time?(data.ts.to_i) && has_answer_rights?(data.user)
      end

      def respondent?(user)
        respondent == user
      end

      def slaq_command?(text)
        Slaq::Slack::COMMANDS.include?(text)
      end

      def exceed_answer_limit_time?(answer_time)
        (answer_time - time_pressed_a) > ANSWER_LIMIT_TIME
      end

      def has_answer_rights?(user)
        !revoked_users.include?(user)
      end

      def revoke_answer_rights(user)
        revoked_users.push(user)
      end
    end
  end
end
