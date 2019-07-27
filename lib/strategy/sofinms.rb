module Strategy
	class Sofinms < BaseStrategy
		MOVES = %w(left right up down)
		@road = []

		def initialize config
			@confog = config
			@road = []
		end

		def get_allowed_movements x, y, lines
			allowed_movements = []
			# right
			if (x + 30) <= 900 and !lines.include?([x+30, y]) 
				allowed_movements.push('right')
			end
			# left
			if (x - 30) >= 0 and !lines.include?([x-30, y]) 
				allowed_movements.push('left')
			end
			# up
			if (y + 30) <= 900 and !lines.include?([x, y+30]) 
				allowed_movements.push('up')
			end
			# down
			if (y - 30) >= 0 and !lines.include?([x, y-30]) 
				allowed_movements.push('down')
			end

			allowed_movements
		end

		def get_next_position position, next_step
			x = position.x
			y = position.y
			if next_step == 'right'
				return {'x' => x + 30, 'y' => y}
			end
			if next_step == 'left'
				return {'x' => x -30, 'y' => y}
			end
			if next_step == 'up'
				return {'x' => x + 30, 'y' => y+30}
			end
			if next_step == 'down'
				return {'x' => x, 'y' => y-30}
			end
		end

		def attach_territory state
			if !state.me.lines.empty?
				x = state.me.position.x
				y = state.me.position.y
				# right
				if state.me.territory.include?([x+30, y]) 
					return 'right'
				end
				# left
				if state.me.territory.include?([x-30, y]) 
					return 'left'
				end
				# up
				if state.me.territory.include?([x, y+30]) 
					return 'up'
				end
				# down
				if state.me.territory.include?([x, y-30]) 
					return 'down'
				end
			end

			''
		end

		def check_for_return_to_territory state
			if state.me.lines.length > 5
				return true
			end
			return false
		end

		def create_road_to_territory

		end

		def next_move_from_road
		end

		def next_tick state
			allowed_movements = get_allowed_movements state.me.position.x, state.me.position.y, state.me.lines 

			# Если можно на следующем шаге присоединить территорию, то делаем это
			next_step = attach_territory state
			# Если нет, то рандомим следующий шаг
			if next_step.empty?
				# Если длина шлейфа слишком большая, то строим дорогу для возвращения по кратчайшему пути на территорию
				if check_for_return_to_territory state
					create_road_to_territory
				end

				if !@road.empty?
					next_step = next_move_from_road
				else
					next_step = allowed_movements.sample
					# Проверяем, что следующий шаг не приведёт нас в тупик
					next_position = get_next_position state.me.position, next_step
					next_allowed_movements = get_allowed_movements next_position['x'], next_position['y'], state.me.lines

					if next_allowed_movements.empty?
						allowed_movements.delete(next_step)
						next_step = allowed_movements.sample
					end
				end
			end

			file = File.open("/Users/sofinms/Sites/test_log", "w")
			file.puts next_step
			file.puts allowed_movements.to_json
			file.puts state.me.position.to_json
			file.puts state.me.lines.to_json
			file.close

			next_step
		end
	end
end