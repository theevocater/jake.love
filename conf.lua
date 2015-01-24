function love.conf(t)
  t.window.width = 16*64
  t.window.height = 8*64
  local lurker,lume,bump = 'modules/lurker/?.lua','modules/lume/?.lua','modules/bump/?.lua'
  package.path = package.path .. ';' .. lurker .. ';' .. lume .. ';' .. bump
end
