module Slaq
  class Quiz
    module Status
      CONTINUE = 'continue'
      PAUSE = 'pause'
      NEXT = 'next'

      def processing?
        if status.nil?
          false
        else
          status != Slaq::Quiz::Status::NEXT
        end
      end
    end
  end
end
