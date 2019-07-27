module Game
	class State
		attr_reader :me, :players, :tick_num

		def initialize state_ext_obj
			@players = state_ext_obj[:params][:players].reject { |(key, value)| key == :i }.values
			@me = state_ext_obj[:params][:players].select { |(key, value)| key == :i }.values.first
			@tick_num = state_ext_obj[:params][:tick_num]
		end
	end
end