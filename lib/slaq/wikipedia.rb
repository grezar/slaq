module Slaq
  class Wikipedia

    ::Wikipedia.configure {
      domain 'ja.wikipedia.org'
    }

    def wikipedia
      ::Wikipedia
    end

    def find_link_by_answer(answer)
      page = wikipedia.find(answer)
      page.fullurl
    end
  end
end
