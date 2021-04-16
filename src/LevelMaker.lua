LevelMaker = Class{}

function LevelMaker.generate(width, height)
local tiles = {}
local entities = {}
local objects = {}

local tileID = TILE_ID_GROUND

local topper = true
local tileset = math.random(20)
local topperset = math.random(20)

--key and unlocked block will have the same colour
local keyColor = math.random(1, 4)

--here we have the flag ready to spawn
local pole = GameObject{
	x = (width - 4) * TILE_SIZE, y = 3 * TILE_SIZE,
	texture = 'poles',
	width = 16, height = 48,
	frame = POLES[math.random(1, #POLES)],
	solid = false, collidable = true,
	consumable = true,
	onConsume = function (player, object)
		gStateMachine:change('play', {
		score = player.score,
		width = width
		})
	end
}
local flag = GameObject{
	x = (width - 4) * TILE_SIZE + 10, y = 3 * TILE_SIZE,
	texture = 'flags',
	width = 16, height = 16,
	frame = FLAGS[math.random(1, #FLAGS)],
	solid = false,
	collidable = false
}

local keyBlock = GameObject{
--remember to include a condition of no pillars or cliffs in width/2
	texture = 'jump-blocks',
	x = (width/2 - 1)* TILE_SIZE,
	y = 3 * TILE_SIZE,
	width = 16,
	height = 16,
	frame = math.random(#JUMP_BLOCKS),
	collidable = true,
	hit = false,
	solid = true,
	onCollide = function(obj)
	--spawn a key if we haven't already hit the block
		if not obj.hit then
			local key = GameObject{
			texture = 'locke-and-key',
			x = (width/2 - 1) * TILE_SIZE,
			y = 3 * TILE_SIZE - 4,
			width = 16, height = 16,
			frame = keyColor,
			collidable = true, consumable = true,
			solid = false,
			onConsume = function(player, object)
				gSounds['pickup']:play()
				--now we have a key. Create the block
				local unlocked = GameObject{
					texture = 'locke-and-key',
					x = math.random(width/2 + 6 ,width - 6) * TILE_SIZE,
					y = 3 * TILE_SIZE,
					width = 16, height = 16,
					frame = keyColor + 4,
					collidable = true,
					consumable = true,
					hit = false,
					solid = true,
					onCollide = function(player, object)
						gSounds['powerup-reveal']:play()
						table.remove(objects, ulocked)
						table.insert(objects, pole)
						table.insert(objects, flag)
					end
					}
				table.insert(objects, unlocked)
			end
			}
			Timer.tween(0.1, {
			[key] = {y = (4 - 2) * TILE_SIZE}
			})
			gSounds['powerup-reveal']:play()
			table.insert(objects, key)
		end
			obj.hit = true
		end
	}
table.insert(objects, keyBlock)

for x = 1, height do
	table.insert(tiles, {})
end

for x = 1, width do
local tileID = TILE_ID_EMPTY

	--empty space of sky
	for y = 1, 6 do
		table.insert(tiles[y], Tile(x, y, tileID, nil, tileset, topperset))
	end

	--empty space of radcliffs. As pillars, I made sure that they don't appear either at the beginning of the level or at the very end
	if math.random(7) == 1 and x > 2 and x < width - 5 then
		for y = 7, height do
			table.insert(tiles[y], Tile(x, y, tileID, nil, tileset, topperset))
		end
	else
		tileID = TILE_ID_GROUND
		local blockHeight = 4
		
		for y = 7, height do
			table.insert(tiles[y], Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
		end
		
		if math.random(8) == 1 and x > 2 and x < width - 5 then
			blockHeight = 2
			--chance to generate bush on a pillar
			if math.random(8)== 1 then
				table.insert(objects, GameObject {
					texture = 'bushes',
					x = (x - 1) * TILE_SIZE,
					y = (4 - 1) * TILE_SIZE,
					width = 16,
					height = 16,
					frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
					
				})
			end
			--pillar tiles
			tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
			tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
			tiles[7][x].topper = nil
		
		--chance to generate bushes
		elseif math.random(8) == 1 then
			table.insert(objects, GameObject{
				texture = 'bushes',
				x = (x - 1) * TILE_SIZE,
				y = (6 - 1) * TILE_SIZE,
				width = 16,
				height = 16,
				frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
				collidable = false
			})
		end
		
		--chance to spawn a block
		if math.random(10) == 1 and x > 2 and x < width - 5 then
			table.insert(objects,
				GameObject{
				texture = 'jump-blocks',
				x = (x - 1) * TILE_SIZE,
				y = (blockHeight - 1) * TILE_SIZE,
				width = 16,
				height = 16,
				frame = math.random(#JUMP_BLOCKS),
				collidable = true,
				hit = false,
				solid = true,
				onCollide = function(obj)
				
				--spawn a gem if we haven't already hit the block
					if not obj.hit then
					--chance to spawn a gem
						if math.random(5) == 1 then
							local gem = GameObject{
								texture = 'gems',
								x = (x - 1) * TILE_SIZE,
								y = (blockHeight - 1) * TILE_SIZE - 4,
								width = 16,
								height = 16,
								frame = math.random(#GEMS),
								collidable = true,
								consumable = true,
								solid = false,
								onConsume = function(player, object)
									gSounds['pickup']:play()
									player.score = player.score + 100
								end
							}
							
							Timer.tween(0.1, {
								[gem] = {y = (blockHeight - 2) * TILE_SIZE}
							})
							gSounds['powerup-reveal']:play()
							table.insert(objects, gem)
						end
						obj.hit = true
					end
					
					gSounds['empty-block']:play()
				end
				})
		end
		
	end

end
local map = TileMap(width, height)
map.tiles = tiles
return GameLevel(entities, objects, map)
end