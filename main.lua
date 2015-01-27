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
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
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

local function draw(box)
  r,g,b = color(box.c)
  love.graphics.setColor(r,g,b,70)
  love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
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
    speed = 200,
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

local function jakeUpdate(dt)
  local speed = jake.speed

  local dx, dy = 0, 0
  if love.keyboard.isDown('right') then
    dx = speed * dt
  elseif love.keyboard.isDown('left') then
    dx = -speed * dt
  end
  if love.keyboard.isDown('down') then
    dy = speed * dt
  elseif love.keyboard.isDown('up') then
    dy = -speed * dt
  end

  if dx ~= 0 or dy ~= 0 then
    jake.x, jake.y, _, col_len = world:move(jake, jake.x + dx, jake.y + dy)
  end
end

local function jakeDraw()
  if (debug) then
    draw(jake)
  end
  love.graphics.setColor(255,255,255)
  love.graphics.draw(jake.texture,
    jake.quads[jake.direction][jake.animation.iterator],
    jake.x,
    jake.y)
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
    print("enabling debug")
    debug = not debug
  end
end
