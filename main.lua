function love.load()
  tileH, tileW = 64, 64
  JakeTileset = love.graphics.newImage("SpriteSheetWithStep.png")
  local tilesetH, tilesetW = JakeTileset:getHeight(), JakeTileset:getWidth()
  JakeQuads = {
    love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileH*2, tileW, tileH, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileH*3, tileW, tileH, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileH*4, tileW, tileH, tilesetW, tilesetH),
    love.graphics.newQuad(0, tileH*5, tileW, tileH, tilesetW, tilesetH)
  }
  Tileset = love.graphics.newImage("TileSheet.png")
  tilesetH, tilesetW = Tileset:getHeight(), Tileset:getWidth()
  TileQuads = {
    love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH),
  }
  TileTable = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  }
  love.physics.setMeter(32)
  world = love.physics.newWorld( 0, 9.81*32, sleep )
  -- from physics tutorial
  objects = {} -- table to hold all our physical objects

  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, love.window.getWidth()/2, love.window.getHeight()-tileH/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(love.window.getWidth(), tileH) --make a rectangle with a width of 650 and a height of 50
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body

  --let's create a ball
  objects.ball = {}
  objects.ball.body = love.physics.newBody(world, love.window.getWidth()/2, love.window.getHeight()/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  objects.ball.shape = love.physics.newCircleShape(16) --the ball's shape has a radius of 20
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
  objects.ball.fixture:setRestitution(0.9) --let the ball bounce

  --let's create a couple blocks to play around with
  objects.block1 = {}
  objects.block1.body = love.physics.newBody(world, 600, 400, "dynamic")
  objects.block1.shape = love.physics.newRectangleShape(0, 0, 50, 100)
  objects.block1.fixture = love.physics.newFixture(objects.block1.body, objects.block1.shape, 5) -- A higher density gives it more mass.

  objects.block2 = {}
  objects.block2.body = love.physics.newBody(world, 200, 400, "dynamic")
  objects.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
  objects.block2.fixture = love.physics.newFixture(objects.block2.body, objects.block2.shape, 2)
end

function love.draw()
  --love.graphics.draw(JakeTileset, JakeQuads[1], 0, 20 + tileH*0)
  --love.graphics.draw(JakeTileset, JakeQuads[1], 0, 20 + tileH*0)
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
  --love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  --love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates

  love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())

  love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end

function love.update(dt)
  world:update(dt)
  require("lurker").update()
end
