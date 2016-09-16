minetest.register_node("tps_maze:mazeblock", {
	description = "Maze Generating Block",
	tiles = {"maze_mazeblock.png"},
	groups = {cracky=3, stone=1},
	
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec", 
			"size[8,6]"..
			"field[1,2.5;6.5,1;floor;Material for Floor:;default:desert_stone]"..
			"field[1,4;6.5,1;size;Number of Blocks Wide (odd numbers <93):;39]"..
			"button_exit[3,5;2,1;button;Done]"..
			"field[1,1;6.5,1;walls;Material for Walls:;wool:dark_green]")
	end,
	
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("walls", fields.walls)
		meta:set_string("floor", fields.floor)
		meta:set_string("size", fields.size)
	end,
	
	on_punch = function(pos, node, puncher)
		local meta = minetest.env:get_meta(pos)
		local walls = meta:get_string("walls")
		local floor = meta:get_string("floor")
		local size = tonumber(meta:get_string("size"))
		if walls == "" then
			minetest.chat_send_player(puncher:get_player_name(),"Please right-click to set values before punching.")
			return
		end
		if (size % 2 == 0) or (size > 91 ) then
			minetest.chat_send_player(puncher:get_player_name(),"Please choose an odd number of blocks less than 93 wide.")
			return
		end
        -- inital setup - creates a square of 8s (breakable wall) surrounded by a frame of 9s (unbreakable wall)
		local a = {}
		a[1] = 2
		a[2] = size * -2
		a[3] = -2
		a[4] = size * 2
		math.randomseed(os.time())
		local route = size + 2
		local zed = 0
		local maze = {}
		for i=1, (size * size) do
			maze[i] = 9
			zed = zed + 1
			if i > size and i < ((size * size) - size + 1) and zed~=size then
				maze[i] = 8
			end
			if zed > size then
				zed = 1
				maze[i] = 9
			end
		end
		-- generate maze
		maze[route] = 5
		local tran = 0
		local j = 0
		local m = 0
		local b = 0
		gen1 = function(j,m,b)
			j = math.random(4)
            m = j
            gen2(j,m,b)
		end
		gen2 = function(j,m,b)         
			b = route + a[j]
            if maze[b] == 8 then
                   maze[b] = j
                   tran = route + (a[j]/2)
                   maze[tran] = 7
                   route = b
                   gen1(j,m,b)
            end
            j = j + 1
            if j == 5 then
				j = 1
            end
            if j ~= m then
                gen2(j,m,b)
            end
            j = maze[route]
            maze[route] = 7
            if j < 5 then
                route = route - a[j]
                gen1(j,m,b)
            end
		end	
		gen1(j,m,b)
		-- output finished maze
		local maze2 = {}
		local ex = 0
		local zed = 0
		local why1 = 0
		local ex1 = 0
		local zed1 = 0
		for why=-1,2 do
			ex = 0
			zed = 0
			why1 = pos.y + why
			for i=1, (size * size) do
				zed = zed + 1
				if zed > size then
					zed = 1
					ex = ex + 1
				end
				if why > -1 then
					if maze[i] == 9 or maze[i] == 8 then
						maze2[i] = walls
					elseif maze[i] == 7 then
						maze2[i] = "air"
					end
				else
					maze2[i] = floor
				end
				--add start and end points
				if i == (size + 1) or i == ((size * size) - size) then
					if why > -1 then
						maze2[i] = "air"
					else
						if i == (size + 1) then
							maze2[i] = "tps_maze:start"
						else
							maze2[i] = "tps_maze:end"
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

minetest.register_node("tps_maze:start", {
	tiles = {"maze_start.png"},
	groups = {cracky=3, stone=1},
})

minetest.register_node("tps_maze:end", {
	tiles = {"maze_end.png"},
	groups = {cracky=3, stone=1},
})

-- register mazeblock craft
minetest.register_craft({
	output = "tps_maze:mazeblock",
	recipe = {
		{"default:cactus", "default:cactus", "default:cactus", },
		{"default:cactus", "", "default:cactus", },
		{"default:desert_stone", "default:desert_stone", "default:desert_stone", }
	}
})
