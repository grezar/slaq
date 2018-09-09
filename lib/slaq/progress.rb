module Slaq
  class Progress
    CONTINUE = 'continue'
    PAUSE = 'pause'
    NEXT = 'next'

    attr_reader :status, :revoked_users

    def initialize
      @status = nil
      @time_pressed_a = nil
      @revoked_users = []
    end

    def in_progress?
      if status.nil?
        false
      else
        status != Slaq::Quiz::Status::NEXT
      end
    end

    def revoked?(user)
      revoked_users.include?(user)
    end
  end
end
