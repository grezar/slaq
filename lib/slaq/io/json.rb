require 'json'
require_relative '../io/json/quiz'
require_relative '../io/json/signal'

module Slaq
  module IO
    class Json
      include Slaq::IO::Json::Quiz
      include Slaq::IO::Json::Signal

      attr_reader :path

      def initialize(path)
        @path = path
      end
    end
  end
end
