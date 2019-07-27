module Strategy
	class Random < BaseStrategy
		MOVES = %w(left right up down)

		def next_tick state
			MOVES.sample
		end
	end
end