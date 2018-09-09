module Slaq
  class Progress
    CONTINUE = 'continue'
    PAUSE = 'pause'
    NEXT = 'next'

    attr_accessor :status, :respondent, :revoked_users

    def initialize
      @status = nil
      @respondent = nil
      @time_pressed_a = nil
      @revoked_users = []
    end

    def in_progress?
      if status.nil?
        false
      else
        status != NEXT
      end
    end

    def revoke(user)
      revoked_users.push(user)
    end

    def revoked?(user)
      revoked_users.include?(user)
    end
  end
end
