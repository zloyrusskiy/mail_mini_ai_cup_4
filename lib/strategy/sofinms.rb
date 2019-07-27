module Strategy
	class Sofinms < BaseStrategy
		MOVES = %w(left right up down)

		def get_allowed_movements state
			allowed_movements = []

			x = state.me[:position][0]
			y = state.me[:position][1]
			# right
			if (x + 30) <= 900 and !state.me[:lines].include?([x+30, y]) 
				allowed_movements.push('right')
			end
			# left
			if (x - 30) >= 0 and !state.me[:lines].include?([x-30, y]) 
				allowed_movements.push('left')
			end
			# up
			if (y + 30) <= 900 and !state.me[:lines].include?([x, y+30]) 
				allowed_movements.push('up')
			end
			# down
			if (y - 30) >= 0 and !state.me[:lines].include?([x, y-30]) 
				allowed_movements.push('down')
			end

			allowed_movements
		end

		def next_tick state
			allowed_movements = get_allowed_movements state

			log_debug allowed_movements.inspect

			allowed_movements.sample
		end
	end
end