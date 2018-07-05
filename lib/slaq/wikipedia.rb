require_relative 'wikipedia/link'

module Slaq
  class Wikipedia
    include Slaq::Wikipedia::Link

    ::Wikipedia.configure {
      domain 'ja.wikipedia.org'
    }

    def wikipedia
      ::Wikipedia
    end
  end
end
