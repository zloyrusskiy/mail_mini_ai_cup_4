module Game
	class Bonus
		attr_reader :type, :position, :ticks

		def initialize bonus_ext_obj
			@type = case bonus_ext_obj[:type]
				when 'n' then :nitro
				when 's' then :slow
				when 'saw' then :saw
			end

			@position = Game::Point.new(bonus_ext_obj[:position])

			@ticks = bonus_ext_obj[:ticks]
		end
	end
end