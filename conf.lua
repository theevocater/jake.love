function love.conf(t)
  t.window.width = 16*64
  t.window.height = 8*64
  package.path = package.path .. ';modules/lurker/?.lua;modules/lume/?.lua'
end
