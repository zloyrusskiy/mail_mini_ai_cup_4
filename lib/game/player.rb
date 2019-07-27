module Game
	class Player
		attr_reader :score, :direction, :territory, :lines, :position, :bonuses

		def initialize player_ext_obj
			@score = player_ext_obj[:score]
			@direction = player_ext_obj[:direction].to_sym unless player_ext_obj[:direction].nil?
			
			@territory = player_ext_obj[:territory].map { |i| Game::Point.new(i) }
			@lines = player_ext_obj[:lines].map { |i| Game::Point.new(i) }
			
			@position = Game::Point.new(player_ext_obj[:position])
			@bonuses = player_ext_obj[:bonuses].map {|i| Game::Bonus.new(i) }
		end
	end
end