module Strategy
	class BaseStrategy
		attr_reader :config

		def initialize config
			@config = config
		end

		def log_debug msg
			$stderr.puts msg
		end
	end
end