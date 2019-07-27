module Strategy
	class Simple
		MOVES = %w(left right up down)

		def next_tick
			MOVES.sample
		end
	end
end