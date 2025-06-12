local MenuState = {}
MenuState.__index = MenuState

function MenuState:new(game)
    return setmetatable({ game = game }, MenuState)
end

function MenuState:update(dt) end

function MenuState:draw()
    love.graphics.printf("CARD CLASH GAME", 0, love.graphics.getHeight()/4, love.graphics.getWidth(), "center")
    love.graphics.printf("Press ENTER to start", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
end

function MenuState:keypressed(key)
    if key == "return" then
      self.game:changeState("PlayState")
    end
end

function MenuState:enter() end
function MenuState:exit() end

return MenuState