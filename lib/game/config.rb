require 'json'

module Game
	class Config
		attr_reader :x_cells_count, :y_cells_count, :player_init_speed, :cell_width

		def initialize config
			@x_cells_count = config[:x_cells_count]
			@y_cells_count = config[:y_cells_count]
			@player_init_speed = config[:speed]
			@cell_width = config[:width]
		end
	end
end