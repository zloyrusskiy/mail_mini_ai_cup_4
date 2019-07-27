module Game
	class State
		attr_reader :me, :players, :tick_num, :bonuses

		def initialize state_ext_obj
			@players = state_ext_obj[:params][:players].reject { |(key, value)| key == :i }.values.map {|i| Game::Player.new(i) }
			@me = state_ext_obj[:params][:players].select { |(key, value)| key == :i }.values.map {|i| Game::Player.new(i) }.first
			@tick_num = state_ext_obj[:params][:tick_num]
			@bonuses = state_ext_obj[:params][:bonuses].map { |i| Game::Bonus.new(i) }
		end
	end
end