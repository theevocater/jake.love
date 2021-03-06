function love.load()
  tileH, tileW = 64, 64
  local tilesetH, tilesetW = 0,0
  Tileset = love.graphics.newImage("TileSheet.png")
  tilesetH, tilesetW = Tileset:getHeight(), Tileset:getWidth()
  TileQuads = {
    love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH),
  }
  TileTable = {
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1},
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  }
  love.physics.setMeter(32)
  world = love.physics.newWorld( 0, 9.81*32, sleep )
  -- from physics tutorial
  objects = {} -- table to hold all our physical objects

  --let's create the ground
  --objects.ground = {}
  --objects.ground.body = love.physics.newBody(world, love.window.getWidth()/2, love.window.getHeight()-tileH/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  --objects.ground.shape = love.physics.newRectangleShape(love.window.getWidth(), tileH) --make a rectangle with a width of 650 and a height of 50
  --objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body
  --objects.ground.texture = Tileset
  --objects.ground.quad = TileQuads[1]

  objects.platforms = {}
  for rowIndex=1, #TileTable do
    local row = TileTable[rowIndex]
    objects.platforms[rowIndex] = {}
    for columnIndex=1, #row do
      local number = row[columnIndex]
      local curr = {}
      -- we need to put the body at
      -- width,height = (columnIndex*tileW),(rowIndex*tileH)
      -- the shape (the rectangle we create next) anchors to the body from
      -- its center, so we have to move it tileW/2, tileH/2
      local w,h = (columnIndex*tileW)-tileW/2, (rowIndex*tileH)-tileH/2
      if not (number == 2) then
        curr.body = love.physics.newBody(world, w, h)
        curr.shape = love.physics.newRectangleShape(tileW, tileH)
        curr.fixture = love.physics.newFixture(curr.body, curr.shape) --attach shape to body
      end
      curr.texture = Tileset
      curr.quad = TileQuads[number]
      curr.number = number
      objects.platforms[rowIndex][columnIndex] = curr
    end
  end

  objects.jake = {}
  objects.jake.body = love.physics.newBody(world, love.window.getWidth()/2, love.window.getHeight()/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  objects.jake.shape = love.physics.newRectangleShape(tileW, tileH) -- jake is roughly a rectangle
  objects.jake.fixture = love.physics.newFixture(objects.jake.body, objects.jake.shape, 1) -- Attach fixture to body and give it a density of 1.
  objects.jake.texture = love.graphics.newImage("SpriteSheetWithStep.png")
  tilesetH, tilesetW = objects.jake.texture:getHeight(), objects.jake.texture:getWidth()
  objects.jake.quads = {
    front = {
      love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH),
      love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH)
    },
    back = {
      love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH),
      love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH)
    },
    right = {
      love.graphics.newQuad(0, tileH*2, tileW, tileH, tilesetW, tilesetH),
      love.graphics.newQuad(0, tileH*3, tileW, tileH, tilesetW, tilesetH)
    },
    left = {
      love.graphics.newQuad(0, tileH*4, tileW, tileH, tilesetW, tilesetH),
      love.graphics.newQuad(0, tileH*5, tileW, tileH, tilesetW, tilesetH)
    }
  }
  objects.jake.direction = 'front'
  objects.jake.moving = false
  objects.jake.animation = {}
  objects.jake.animation.timer = 0
  objects.jake.animation.iterator = 1

end

function love.draw()
  love.graphics.setColor(255,255,255)
  for rowIndex=1, #TileTable do
    local row = TileTable[rowIndex]
    for columnIndex=1, #row do
      local number = row[columnIndex]
      if not (number == 0) then
        love.graphics.draw(Tileset, TileQuads[number], (columnIndex-1)*tileW, (rowIndex-1)*tileH)
      end
    end
  end

  -- draw jake
  love.graphics.draw(objects.jake.texture,
    objects.jake.quads[objects.jake.direction][objects.jake.animation.iterator],
    objects.jake.body:getX() - tileW/2,
    objects.jake.body:getY() - tileH/2)

  -- draw bounding boxes of shapes
  love.graphics.setColor(0,0,0)
  for rowIndex=1, #objects.platforms do
    local row = objects.platforms[rowIndex]
    for columnIndex=1, #row do
      if (row[columnIndex].fixture) then
        love.graphics.polygon("line", row[columnIndex].body:getWorldPoints(row[columnIndex].shape:getPoints()))
      end
    end
  end
end

function love.update(dt)
  world:update(dt)
  --require("lurker").update()
	if objects.jake.moving then
		objects.jake.animation.timer = objects.jake.animation.timer + dt
		if objects.jake.animation.timer > 0.2 then
			objects.jake.animation.timer = 0
			objects.jake.animation.iterator = objects.jake.animation.iterator + 1
			if objects.jake.animation.iterator > 2 then
				objects.jake.animation.iterator = 1
			end
		end
	end
  --here we are going to create some keyboard events
  if love.keyboard.isDown("right") then --press the right arrow key to push the jake to the right
    objects.jake.moving = true
    objects.jake.direction = "right"
    objects.jake.iterator = 1
    objects.jake.body:applyForce(400, 0)
  elseif love.keyboard.isDown("left") then --press the left arrow key to push the jake to the left
    objects.jake.moving = true
    objects.jake.direction = "left"
    objects.jake.iterator = 1
    objects.jake.body:applyForce(-400, 0)
  elseif love.keyboard.isDown("up") then --press the up arrow key to set the jake in the air
    objects.jake.moving = false
    objects.jake.direction = "front"
    objects.jake.iterator = 1
    objects.jake.body:applyForce(0, -10000)
  elseif love.keyboard.isDown("down") then --press the up arrow key to set the jake in the air
    objects.jake.moving = false
    objects.jake.direction = "back"
    objects.jake.iterator = 1
    objects.jake.body:applyForce(0, 10000)
  end
end
