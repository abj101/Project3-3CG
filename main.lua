local Game = require "src.Game"

function love.load()
    game = Game:new()
    game:load()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    if game and game:keypressed() then
      game:keypressed(key)
    end
end