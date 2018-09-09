require 'wikipedia'

module Slaq
  class Wikipedia

    ::Wikipedia.configure {
      domain 'ja.wikipedia.org'
    }

    def self.find_link_by_answer(answer)
      page = ::Wikipedia.find(answer)
      page.fullurl
    end
  end
end
