module Strategy
	class Sofinms
		MOVES = %w(left right up down)

		def get_allowed_movements state
			allowed_movements = []
			x = state["params"]["players"]["i"]["position"][0]
			y = state["params"]["players"]["i"]["position"][1]
			# right
			if (x + 30) <= 900 and !state["params"]["players"]["i"]['lines'].include?([x+30, y]) 
				allowed_movements.push('right')
			end
			# left
			if (x - 30) >= 0 and !state["params"]["players"]["i"]['lines'].include?([x-30, y]) 
				allowed_movements.push('left')
			end
			# up
			if (y + 30) <= 900 and !state["params"]["players"]["i"]['lines'].include?([x, y+30]) 
				allowed_movements.push('up')
			end
			# down
			if (y - 30) >= 0 and !state["params"]["players"]["i"]['lines'].include?([x, y-30]) 
				allowed_movements.push('down')
			end

			allowed_movements
		end

		def next_tick config, state
			state = game_config.get_current_state
			allowed_movements = get_allowed_movements state

			file = File.open("/Users/sofinms/Sites/test_log", "w")
			file.puts allowed_movements.to_json
			file.close

			allowed_movements.sample
		end
	end
end