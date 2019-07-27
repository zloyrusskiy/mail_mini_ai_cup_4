require 'json'

module Game
	class Config
		@start_config = {}
		@current_state = {}
		
		def set_start_config config
			@start_config = JSON.parse(config)
		end

		def get_start_config
			@start_config
		end

		def set_current_state state
			@current_state = JSON.parse(state)
		end

		def get_current_state
			@current_state
		end
	end
end