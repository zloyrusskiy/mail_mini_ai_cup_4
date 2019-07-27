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

		def get_next_position position, next_step
			if next_step == 'right'
				return [position[0] + 30, position[1]]
			end
			if next_step == 'left'
				return [position[0] -30, position[1]]
			end
			if next_step == 'up'
				return [position[0], position[1]+30]
			end
			if next_step == 'down'
				return [position[0], position[1]-30]
			end
		end

		def attach_territory state
			if !state["params"]["players"]["i"]['lines'].empty?
				x = state["params"]["players"]["i"]["position"][0]
				y = state["params"]["players"]["i"]["position"][1]
				# right
				if state["params"]["players"]["i"]['territory'].include?([x+30, y]) 
					return 'right'
				end
				# left
				if state["params"]["players"]["i"]['territory'].include?([x-30, y]) 
					return 'left'
				end
				# up
				if state["params"]["players"]["i"]['territory'].include?([x, y+30]) 
					return 'up'
				end
				# down
				if state["params"]["players"]["i"]['territory'].include?([x, y-30]) 
					return 'down'
				end
			end

			''
		end

		def next_tick config, state
			allowed_movements = get_allowed_movements state

			# Если можно на следующем шаге присоединить территорию, то делаем это
			next_step = attach_territory state
			# Если нет, то рандомим следующий шаг
			if next_step.empty?
				next_step = allowed_movements.sample
				# Проверяем, что следующий шаг не приведёт нас в тупик
				next_state = state
				next_state["params"]["players"]["i"]["position"] = get_next_position next_state["params"]["players"]["i"]["position"], next_step
				next_allowed_movements = get_allowed_movements state

				if next_allowed_movements.empty?
					allowed_movements.delete(next_step)
					next_step = allowed_movements.sample
				end
			end

			file = File.open("/Users/sofinms/Sites/test_log", "w")
			file.puts next_step
			file.puts allowed_movements.to_json
			file.puts state["params"]["players"]["i"]["position"].to_json
			file.puts state["params"]["players"]["i"]['lines'].to_json
			file.close

			next_step
		end
	end
end