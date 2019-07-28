module Strategy
	class Sofinms < BaseStrategy
		MOVES = %w(left right up down)
		@road = []

		def initialize config
			@confog = config
			@road = []
			@prev_move = ''
		end

		def get_allowed_movements x, y, lines
			allowed_movements = []
			# right
			if (x + 30) <= 915 and !is_points_include_xy(lines, [x+30, y]) 
				allowed_movements.push('right')
			end
			# left
			if (x - 30) >= 15 and !is_points_include_xy(lines, [x-30, y]) 
				allowed_movements.push('left')
			end
			# up
			if (y + 30) <= 915 and !is_points_include_xy(lines, [x, y+30]) 
				allowed_movements.push('up')
			end
			# down
			if (y - 30) >= 15 and !is_points_include_xy(lines, [x, y-30]) 
				allowed_movements.push('down')
			end

			case @prev_move
			when 'up'
				allowed_movements.delete 'down'
			when 'down'
				allowed_movements.delete 'up'
			when 'right'
				allowed_movements.delete 'left'
			when 'left'
				allowed_movements.delete 'right'
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

		def is_points_include_xy territory, xy
			territory.each do |point|
				return true if point.x == xy[0] && point.y == xy[1]
			end

			return false
		end

		def attach_territory state
			if !state.me.lines.empty?
				x = state.me.position.x
				y = state.me.position.y
				# right
				if is_points_include_xy(state.me.territory, [x+30, y]) && @prev_move != 'left'
					return 'right'
				end
				# left
				if is_points_include_xy(state.me.territory, [x-30, y]) && @prev_move != 'right'
					return 'left'
				end
				# up
				if is_points_include_xy(state.me.territory, [x, y+30]) && @prev_move != 'down'
					return 'up'
				end
				# down
				if is_points_include_xy(state.me.territory, [x, y-30]) && @prev_move != 'up'
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

		def create_road_to_territory me
			nearest_territory_point = me.territory.sample
			draw_a_star_path [me.position.x, me.position.y], [nearest_territory_point.x, nearest_territory_point.y], me.lines
		end

		def next_move_from_road
			next_move = @road.shift 1

			next_move[0]
		end

		def draw_a_star_path current_xy, finish_xy, lines
			y_lines = []
			(0..30).to_a.each do |y|
				line_x = ''
				(0..30).to_a.each do |x|
					symbal = ' '
					symbal = '#' if is_points_include_xy(lines, [x*30 + 15,y*30 + 15])
					symbal = 'A' if x == ((current_xy[0] - 15).to_f / 30.0).round && y == ((current_xy[1] - 15).to_f / 30.0).round
					symbal = 'B' if x == ((finish_xy[0] - 15).to_f / 30.0).round && y == ((finish_xy[1] - 15).to_f / 30.0).round
					line_x += symbal
				end
				y_lines.push(line_x)
			end
			dungeon = y_lines.reverse.join("\n")
			# Creating the graph
			graph = Graph.new(dungeon)
			# Creating the astar object
			astar = ASTAR.new(graph.start, graph.stop)
			# Performing the search
			path  = astar.search

			str_path = graph.to_s(path)
			map = str_path.reverse.map do |y_line|
				y_line.split('')
			end

			str = ''
			(0..(map.length - 1)).to_a.each do |y|
				(0..(map[y].length - 1)).to_a.each do |x|
					str += map[y][x]
					if map[y][x] == 'A'
						set_road map, [y,x]
						@road
					end
				end
			end
		end

		def set_road map, current_yx
			map[current_yx[0]][current_yx[1]] = ''
			y = current_yx[0]
			x = current_yx[1]
			if y + 1 <= map.length - 1 && ['B','*'].include?(map[y + 1][x])
				@road.push('up')
				return true if map[y + 1][x] == 'B'
				set_road map, [y + 1, x]
			end
			if y - 1 >= 0 && ['B','*'].include?(map[y - 1][x])
				@road.push('down')
				return true if map[y - 1][x] == 'B'
				set_road map, [y - 1, x]
			end
			if x + 1 <= map[y].length - 1 && ['B','*'].include?(map[y][x+1])
				@road.push('right')
				return true if map[y][x+1] == 'B' 
				set_road map, [y, x + 1]
			end
			if x - 1 >= 0 && ['B','*'].include?(map[y][x - 1])
				@road.push('left')
				return true if map[y][x - 1] == 'B'
				set_road map, [y, x - 1]
			end
		end

		def next_tick state
			# file = File.open("/Users/sofinms/Sites/test_log", "w")
			# file.puts 'road:'
			# file.puts @road.to_json
			allowed_movements = get_allowed_movements state.me.position.x, state.me.position.y, state.me.lines 

			# Если можно на следующем шаге присоединить территорию, то делаем это
			next_step = attach_territory state
			# file.puts 'attach_territory:'
			# file.puts next_step
			# Если нет, то рандомим следующий шаг
			if next_step.empty?
				# Если длина шлейфа слишком большая, то строим дорогу для возвращения по кратчайшему пути на территорию
				if @road.empty? && check_for_return_to_territory(state)
					create_road_to_territory state.me
				end

				if !@road.empty?
					next_step = next_move_from_road
					# file.puts 'road-step:'
					# file.puts next_step
				else
					next_step = allowed_movements.sample
					# file.puts 'allowed_movements:'
					# file.puts next_step
					# Проверяем, что следующий шаг не приведёт нас в тупик
					next_position = get_next_position state.me.position, next_step
					next_allowed_movements = get_allowed_movements next_position['x'], next_position['y'], state.me.lines

					if next_allowed_movements.empty?
						allowed_movements.delete(next_step)
						next_step = allowed_movements.sample
						# file.puts 'next_allowed_movements:'
						# file.puts next_step
					end
				end
			end
			# file.puts state.me.position.x
			# file.puts state.me.position.y
			# file.puts 'prev move:'
			# file.puts @prev_move
			# file.close
			@prev_move = next_step

			next_step
		end
	end

	class ASTAR

	  def initialize(start, stop)
	    [start, stop].each do |e|
	      raise ArgumentError, 
	        "Required a Node as input." +
	        "Received a #{e.class}" unless e.is_a? Node
	    end
	    
	  
	    # Let's register a starting node and a ending node
	    @start = start
	    @stop  = stop
	    
	    # There will be two sets at the center of the algorithm.
	    # The first is the openset, that is the set that contains
	    # all the nodes that we have not explored yet.
	    # It is initialized with only the starting node.
	    @openset = [@start]
	    # The closed set is the second set that contains all
	    # the nodes thar already been explored and are in our
	    # path or are failing strategy
	    @closedset = []
	    
	    # Let's initialize the starting point
	    # Obviously it has distance from start that is zero
	    @start.g = 0
	    # and we evaluate the distance from the ending point
	    @start.h = @start.distance(@stop)
	  end
	  
	  def search
	    # The search continues until there are nodes in the openset
	    # If there are no nodes, the path will be an empty list.
	    while @openset.size > 0
	      # The next node is the one that has the minimum distance
	      # from the origin and the minimum distance from the exit.
	      # Thus it should have the minimum value of f.
	      x = openset_min_f()
	      
	      # If the next node selected is the stop node we are arrived.
	      if x == @stop
	        # And we can return the path by reconstructing it 
	        # recursively backward.
	        return reconstruct_path(x)
	      end
	      
	      # We are now inspecting the node x. We have to remove it
	      # from the openset, and to add it to the closedset.
	      @openset -= [x]
	      @closedset += [x]
	      
	      # Let's test all the nodes that are near to the current one
	      x.near.each do |y|
	        
	        # Obviously, we do not analyze the current node if it
	        # is already in the closed set
	        next if @closedset.include?(y)
	        
	        # Let's make an evaluation of the distance from the 
	        # starting point. We can evaluate the distance in a way
	        # that we actually get a correct valu of distance.
	        # It must be saved in a temporary variable, because 
	        # it must be checked against the g score inside the node
	        # (if it was already evaluated)
	        g_score = x.g + x.distance(y)
	        
	        # There are three condition to be taken into account
	        #  1. y is not in the openset. This is always an improvement
	        #  2. y is in the openset, but the new g_score is lower
	        #     so we have found a better strategy to reach y
	        #  3. y has already a better g_score, or inany case
	        #     this strategy is not an improvement
	        
	        # First case: the y point is a new node for the openset
	        # thus it is an improvement
	        if not @openset.include?(y)
	          @openset += [y]
	          improving = true
	        # Second case: the y point was already into the openset 
	        # but with a value of g that is lower with respect to the
	        # one we have just found. That means that our current strategy
	        # is reaching the point y faster. This means that we are 
	        # improving.
	        elsif g_score < y.g
	          improving = true
	        # Third case: The y point is not in the openset, and the
	        # g_score is not lower with respect to the one already saved
	        # into the node y. Thus, we are not improving and this 
	        # current strategy is not good.
	        else
	          improving = false
	        end
	        
	        # We had an improvement
	        if improving
	          # so we reach y from x
	          y.prev = x
	          # we update the gscore value
	          y.g = g_score
	          # and we update also the value of the heuristic
	          # distance from the stop
	          y.h = y.distance(@stop)
	        end
	      end # for
	      
	      # The loop instruction is over, thus we are ready to 
	      # select a new node.
	    end # while
	    
	    # If we never encountered a return before means that we 
	    # have finished the node in the openset and we never
	    # reached the @stop point.
	    # We are returning an empty path.
	    return []
	  end
	  
	  private
	  
	  ##
	  # Searches the node with the minimum f in the openset
	  def openset_min_f
	    ret = @openset[0]
	    for i in 1...@openset.size
	      ret = @openset[i] if ret.f > @openset[i].f
	    end
	    return ret
	  end # openset_min_f
	  
	  ##
	  # It reconstructs the path by using a recursive function
	  # that runs from the last node till the beginning.
	  # It is stopped when the analyzed node has prev == nil
	  def reconstruct_path(curr)
	    return ( curr.prev ? reconstruct_path(curr.prev) + [curr] : [] )
	  end # reconstruct_path

	end

	class Graph
	  # The only attributes that are exposed are start and
	  # stop, as reading only attributes
	  attr_reader :start, :stop
	  
	  ##
	  # 
	  # La funzione di inizializzazione si prende una stringa multilinea in
	  # ingresso e la trasforma in un grafo, nel quale si vanno
	  # a identificare in particolare il punto di partenza e il punto di arrivo
	  def initialize(d, start = "A", stop = "B", 
	                 obst = "#", empty = " ", out = "*")
	    
	    [d, start, stop, obst, empty, out].each do |input|
	      raise ArgumentError,
	        "All arguments must be a String\n" +
	        "Received a #{input.class} instead" unless input.is_a? String
	    end # each
	    
	    [start, stop, obst, empty, out].each do |input|
	      raise ArgumentError,
	        "Character specification must be of size 1\n" +
	        "Received a String with size #{input.size}" unless input.size == 1
	    end # each
	    
	    @a = start
	    @b = stop
	    @o = obst  
	    @s = empty
	    @p = out
	    
	    # It's now the time to convert the input in some sort of matrix
	    # so that will be easier to create the connectivity. The
	    # two methods used are explained here:
	    # split: https://ruby-doc.org/core-2.4.0/String.html#method-i-split 
	    # map: https://ruby-doc.org/core-2.4.0/Array.html#method-i-map
	    @str = d.split("\n").map { |e| e.split("") }
	    
	    # Let's read the number of rows and of columns and check the 
	    # consistency
	    @rows, @cols = @str.size, @str[0].size
	    @str.each_with_index do |r, i|
	      raise ArgumentError,
	        "The number of columns of the input string is not consistent.\n" +
	        "Row #{i} contains #{r.size} chars instead of #{@cols}.\n" +
	        "Please chech for spaces at the end of the row" unless r.size == @cols
	    end # each_with_index
	    
	    # We are now building the @dungeon matrix, that is used to create the nodes
	    # Where there are obstacles, we leave a nil
	    @dungeon = Array.new(@rows) { Array.new(@cols) { nil } }
	    
	    # We search for starting and stopping point and we create the 
	    # @start and @stop attributes in that points. If no @start
	    # or no @stop is found, it raises an Error
	    str_each do |v, r, c|
	      @start = Node.new(r, c) if v.upcase == @a
	      @stop  = Node.new(r, c) if v.upcase == @b
	    end
	    raise ArgumentError,
	      "The string provided does not contain a starting point " + 
	      "with char = #{@a}" unless @start
	    raise ArgumentError,
	      "The string provided does not contain a stopping point " + 
	      "with char = #{@b}" unless @stop
	    
	    # Let's assign a value for each position of the dungeon
	    #  - @a: the it is the start node
	    #  - @b: then it is the stop node
	    #  - @o: then it is an obstacle node and its with a nil
	    #  - else: let's put inside a new node
	    map do |v, r, c|
	      s = @str[r][c]
	      if s == @a
	        @start
	      elsif s == @b
	        @stop
	      elsif s == @o
	        nil
	      elsif s == @s
	        Node.new(r, c)
	      else
	        binding.pry
	        raise ArgumentError,
	          "Unknown char found in string: #{s}"
	      end
	    end
	    
	    # It's time to build the connectivity of the graph. If there
	    # is something near the current node, that it is added to the
	    # near attribute of the node.
	    # == PLEASE NOTE ==
	    # We are using only the four directions in space, but it is
	    # easy to expand it to the four direction in space by 
	    # adding the directions in the array.
	    each do |v, r, c|
	      next unless v
	      [[r + 1, c], 
	       [r, c + 1], 
	       [r - 1, c], 
	       [r, c - 1]].each do |p|
	        next unless inside?(p[0], p[1])
	        v.insert(@dungeon[p[0]][p[1]]) if @dungeon[p[0]][p[1]] 
	      end
	    end
	  end # initialize
	  
	  ##
	  # Print the dungeon. If a path (Array of Nodes) is given as input
	  # it will be printed on the screen using chars @p
	  def to_s(path = nil)
	    str_ = @str.map(&:dup)
	    if path
	      raise ArgumentError, 
	        "Input must be an Array.\n" +
	        "Received a #{path.class}" unless path.is_a? Array
	      for n in path[0...path.size-1] 
	        raise ArgumentError,
	          "Input must contain all Nodes.\n" +
	          "Received a #{n.class}" unless n.is_a? Node
	        str_[n.r][n.c] = @p
	      end
	    end
	    str_ = str_.map { |l| l.join}
	    return str_
	  end # print_path
	  
	  private 
	  
	  ##
	  # Acts on each element of @str, and calls a block
	  # that receives the value in position, the row number
	  # and the column number
	  def str_each 
	    for r in 0...@rows
	      for c in 0...@cols
	        yield(@str[r][c], r, c)
	      end
	    end
	    return @str
	  end # str_each

	  ##
	  # Acts on each element of @dungeon, and calls a block
	  # that receives the value in position, the row number
	  # and the column number.
	  # It modifies the content of @dungeon.
	  def map
	    for r in 0...@rows
	      for c in 0...@cols
	        @dungeon[r][c] = yield(@dungeon[r][c], r, c)
	      end
	    end
	    return @dungeon
	  end # map
	  
	  ##
	  # Acts on each element of @dungeon, and calls a block
	  # that receives the value in position, the row number
	  # and the column number.
	  def each
	    for r in 0...@rows
	      for c in 0...@cols
	        yield(@dungeon[r][c], r, c)
	      end
	    end
	    return @dungeon
	  end # map
	  
	  
	  ##
	  # Specify if we are inside or outside of the matrix
	  def inside?(r, c)
	    return ((0...@rows).include?(r) and (0...@cols).include?(c))
	  end # inside?
	  
	end # Graph

	class Node
	  attr_accessor :g, :h, :prev
	  attr_reader :r, :c, :near

	  ##
	  # Initialize an empty new Node. The only informations it has
	  # are the coordinates (r, c).
	  def initialize(r, c)
	    [r, c].each do |input|
	      raise ArgumentError,
	        "input must be a Numeric.\n" + 
	        "Received a #{input.class}" unless input.is_a? Numeric
	    end
	    @r = r
	    @c = c
	    
	    @g = 0.0
	    @h = 0.0
	    
	    @prev = nil
	    @near = []
	  end
	  
	  ##
	  # The total heuristic distance
	  def f
	    self.g + self.h
	  end
	  
	  ##
	  # Evaluates the distance of the current node with another 
	  # node n.
	  def distance(n)
	    raise ArgumentError,
	      "A Node must be given as input.\n" +
	      "Received a #{n.class}" unless n.is_a? Node
	    return (
	      (@r - n.r) ** 2 +
	      (@c - n.c) ** 2
	    ) ** (0.5)
	  end

	  ##
	  # Add a new edge to a Node in the edges list @near.
	  def insert(n)
	    raise ArgumentError,
	      "A Node must be given as input.\n" +
	      "Received a #{n.class}" unless n.is_a? Node
	    @near << n
	  end
	end
end