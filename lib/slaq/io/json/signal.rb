module Slaq
  module IO
    class Json
      module Signal
        def read_signal
          File.open("#{path}/signal.json", "r") { |signal_file| JSON.load(signal_file) }
        end

        def write_signal(signal = {})
          File.open("#{path}/signal.json", "w") { |signal_file| JSON.dump(quiz, signal_file) }
        end
      end
    end
  end
end
