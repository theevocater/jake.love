local bump = require 'bump'
--local bump_debug = require 'bump_debug'

local tileSize = 64

local debug = false

local TileTable = {
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
  {2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1},
  {1,1,1,2,2,2,2,2,1,2,2,2,2,2,2,2},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

-- helper functions
local function addObject(world, object)
  world:add(object, object.x, object.y, object.w, object.h)
end

local function color(c)
  if (c == 0) then return 255,0,0
  elseif (c == 1) then return 0,0,255
  elseif (c == 2) then return 0,255,0
  else return 0,0,0
  end
end

local function drawDebug(box)
  r,g,b = color(box.c)
  love.graphics.setColor(r,g,b,70)
  love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
end

local function draw(box)
  if (debug) then
    drawDebug(box)
  end
  love.graphics.draw(box.texture, box.quad, box.x, box.y)
end
-- helper functions

--jake
local jake = {}

local function jakeLoad(world)
  -- set up the defaults
  jake = { 
    name = "Jake",
    x = 0,
    y = 0,
    w = tileSize,
    h = tileSize,
    c = 0,
    dx = 0,
    dy = 0,
    speed = 16,
    dxCap = 8,
    jump = 16,
    direction = 'front',
    moving = false,
    animation = {
      timer = 0,
      iterator = 1
    }
  }
  -- add the texture information
  jake.texture = love.graphics.newImage("SpriteSheetWithStep.png")
  jake.tilesetH = jake.texture:getHeight()
  jake.tilesetW = jake.texture:getWidth()
  jake.quads = {
    front = {
      love.graphics.newQuad(0, 0, tileSize, tileSize, jake.tilesetW, jake.tilesetH),
      love.graphics.newQuad(0, 0, tileSize, tileSize, jake.tilesetW, jake.tilesetH)
    },
    back = {
      love.graphics.newQuad(0, tileSize, tileSize, tileSize, jake.tilesetW, jake.tilesetH),
      love.graphics.newQuad(0, tileSize, tileSize, tileSize, jake.tilesetW, jake.tilesetH)
    },
    right = {
      love.graphics.newQuad(0, tileSize*2, tileSize, tileSize, jake.tilesetW, jake.tilesetH),
      love.graphics.newQuad(0, tileSize*3, tileSize, tileSize, jake.tilesetW, jake.tilesetH)
    },
    left = {
      love.graphics.newQuad(0, tileSize*4, tileSize, tileSize, jake.tilesetW, jake.tilesetH),
      love.graphics.newQuad(0, tileSize*5, tileSize, tileSize, jake.tilesetW, jake.tilesetH)
    }
  }
  addObject(world, jake)
end
local gravity = 64

local function detectSignChange(a,b)
  if a * b <= 0 then
    return true
  else
    return false
  end
end

local function jakeUpdate(dt)
  local speed = jake.speed

  local dx, dy = jake.dx, jake.dy
  -- this is a mess, should probably pull out the slowing down parts of it
  if love.keyboard.isDown('right') and dx < jake.dxCap then
    dx = dx + speed * dt
  elseif love.keyboard.isDown('left') and dx > -jake.dxCap then
    dx = dx - (speed * dt)
  elseif (dx ~= 0 and dy == 0) then
    -- not walking, so skid to a stop
    if (jake.direction == 'left') then
      dx = dx + (3*speed * dt)
    elseif (jake.direction == 'right') then
      dx = dx - (3*speed * dt)
    end
    if detectSignChange(jake.dx, dx) then
      dx = 0
    end
  end

  -- only jump if on the ground
  if love.keyboard.isDown('up') and dy == 0 then
    dy = -jake.jump
  end

  -- apply gravity
  dy = dy + (gravity * dt)

  local x,y = 0,0
  if dx ~= 0 or dy ~= 0 then
    x, y, _, col_len = world:move(jake, jake.x + dx, jake.y + dy)
    if jake.y == y then
      jake.dy = 0
    else
      jake.y = y
      jake.dy = dy
    end
    if jake.x == x then
      jake.moving = false
      jake.dx = 0
      jake.direction = 'front'
    else
      jake.moving = true
      jake.x = x
      jake.dx = dx
      if (dx > 0) then
        jake.direction = "right"
      else
        jake.direction = "left"
      end
    end
  end

  if (jake.dx == 0 and jake.dy == 0) then
    jake.moving = false
    if love.keyboard.isDown('down') then
      jake.direction = 'back'
    else
      jake.direction = 'front'
    end
  end

  -- do animation
	if jake.moving then
		jake.animation.timer = jake.animation.timer + dt
		if jake.animation.timer > 0.2 then
			jake.animation.timer = 0
			jake.animation.iterator = jake.animation.iterator + 1
			if jake.animation.iterator > 2 then
				jake.animation.iterator = 1
			end
		end
	end
end

local function jakeDraw()
  if (debug) then
    drawDebug(jake)
  end
  love.graphics.setColor(255,255,255)
  love.graphics.draw(jake.texture,
    jake.quads[jake.direction][jake.animation.iterator], jake.x, jake.y)
end
-- jake

-- world
local objects = {}
local function loadWorld(world)

  -- add walls to outside
  local walls = {
    { name='top', x=-1, y=-1, w=love.graphics.getWidth(), h=1},
    { name='bottom', x=-1, y=love.graphics.getHeight()+1, w=love.graphics.getWidth(), h=1},
    { name='left', x=-1, y=-1, w=1, h=love.graphics.getHeight()},
    { name='right', x=love.graphics.getWidth()+1, y=-1, w=1, h=love.graphics.getHeight()}
  }
  for _,wall in ipairs(walls) do
    addObject(world, wall)
  end

  -- load the tileset for the world background stuff
  local Tileset = love.graphics.newImage("TileSheet.png")
  local tilesetH, tilesetW = Tileset:getHeight(), Tileset:getWidth()
  local TileQuads = {
    love.graphics.newQuad(0, 0, tileSize, tileSize, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileSize, tileSize, tileSize, tilesetW, tilesetH),
  }

  -- create boxes for each tile
  for rowIndex,row in ipairs(TileTable) do
    for columnIndex,number in ipairs(row) do
      local curr = {}
      -- we need to put the tile at
      -- width,height = (columnIndex*tileW),(rowIndex*tileH)
      curr.x,curr.y = ((columnIndex-1)*tileSize), ((rowIndex-1)*tileSize)
      curr.w,curr.h = tileSize,tileSize
      -- number 2 is currently sky which doesn't collide
      if not (number == 2) then
        addObject(world, curr)
      end
      curr.c = number
      curr.texture = Tileset
      curr.quad = TileQuads[number]
      table.insert(objects, curr)
    end
  end
end
-- world

function love.load()
  world = bump.newWorld(tileSize)

  jakeLoad(world)
  loadWorld(world)
end

function love.update(dt)
  jakeUpdate(dt)
end

function love.draw()
  for _,object in ipairs(objects) do
    draw(object)
  end
  jakeDraw()
end

function love.keyreleased(key)
  if key == "tab" then
    debug = not debug
  end
end
