module Slaq
  module IO
    class Json
      module Signal

        def signal_file_exist?
          File.exist?("#{path}/signal.json")
        end

        def read_signal
          File.open("#{path}/signal.json", "r") { |signal_file| JSON.load(signal_file) }
        end

        def write_signal(signal = {})
          File.open("#{path}/signal.json", "w") { |signal_file| JSON.dump(signal, signal_file) }
        end

        def truncate_signal_file
          if signal_file_exist?
            File.open("#{path}/signal.json", "w") { |signal_file| signal_file.truncate(0) }
          end
        end
      end
    end
  end
end
