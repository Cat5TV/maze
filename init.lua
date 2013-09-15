minetest.register_node("maze:mazeblock", {
	description = "Maze Generating Block",
	tiles = {"maze_mazeblock.png"},
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	on_rightclick = function(pos, node, clicker)
        -- inital setup
		a = {}
		a[1] = 2
		a[2] = -78
		a[3] = -2
		a[4] = 78
		math.randomseed(os.time())
		route = 41
		zed = 0
		maze = {}
		for i=1, 1521 do
			maze[i] = 9
			zed = zed + 1
			if i > 39 and i < 1483 and zed~=39 then
				maze[i] = 8
			end
			if zed > 39 then
				zed = 1
				maze[i] = 9
			end
		end
		-- generate maze
		maze[route] = 5
		::gen1::
		j = math.random(4)
		m = j
		::gen2::
		b = route + a[j]
		if maze[b] == 8 then
			maze[b] = j
			tran = route + (a[j]/2)
			maze[tran] = 7
			route = b
			goto gen1
		end
		j = j + 1
		if j == 5 then
			j = 1
		end
		if j ~= m then
			goto gen2
		end
		j = maze[route]
		maze[route] = 7
		if j < 5 then
			route = route - a[j]
			goto gen1
		end
		-- output finished maze
		maze2 = {}
		for why=-1,2 do
			ex = 0
			zed = 0
			why1 = pos.y + why
			for i=1, 1521 do
				zed = zed + 1
				if zed > 39 then
					zed = 1
					ex = ex + 1
				end
				if why > -1 then
					if maze[i] == 9 or maze[i] == 8 then
						maze2[i] = "default:cactus"
					elseif maze[i] == 7 then
						maze2[i] = "air"
					end
				else
					maze2[i] = "default:desert_stone"
				end
				--add start and end points
				if i == 40 or i == 1482 then
					if why > -1 then
						maze2[i] = "air"
					else
						if i == 40 then
							maze2[i] = "maze:start"
						else
							maze2[i] = "maze:end"
						end
					end
				end
				ex1 = pos.x + ex - 1
				zed1 = pos.z + zed - 1
				minetest.set_node({x=ex1, y=why1, z=zed1},{name=maze2[i]})
			end
		end	                
    end,
})

minetest.register_node("maze:start", {
	tiles = {"maze_start.png"},
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
})

minetest.register_node("maze:end", {
	tiles = {"maze_end.png"},
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
})

-- register mazeblock craft
minetest.register_craft({
	output = "maze:mazeblock",
	recipe = {
		{"default:cactus", "default:cactus", "default:cactus", },
		{"default:cactus", "", "default:cactus", },
		{"default:desert_stone", "default:desert_stone", "default:desert_stone", }
	}
})
