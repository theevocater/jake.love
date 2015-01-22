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
  Tileset = love.graphics.newImage("SpriteSheetWithStep.png")
  tilesetH, tilesetW = Tileset:getHeight(), Tileset:getWidth()
  TileQuads = {
    love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH),
  }
end

function love.draw()
  love.graphics.print("Tileset is " .. Tileset:getHeight() .. " and " .. Tileset:getWidth(), 0, 0)
  love.graphics.draw(JakeTileset, 400, 0)
  love.graphics.draw(JakeTileset, JakeQuads[1], 0, 20 + tileH*0)
end
