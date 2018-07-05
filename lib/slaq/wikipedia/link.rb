require 'wikipedia'

module Slaq
  class Wikipedia
    module Link
      def find_link_by_answer(answer)
        page = wikipedia.find(answer)
        page.fullurl
      end
    end
  end
end
