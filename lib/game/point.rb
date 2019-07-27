module Game
	class Point
		attr_reader :x, :y

		def initialize point_ext_obj
			@x = point_ext_obj[0]
			@y = point_ext_obj[1]
		end
	end
end