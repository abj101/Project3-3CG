local EndState = {}
EndState.__index = EndState

function EndState:new(game)
    return setmetatable({ game = game }, EndState)
end

function EndState:enter() end

function EndState:update(dt) end

function EndState:draw()
    local winner = (self.game.player1.points > self.game.player2.points) and self.game.player1 or self.game.player2
    love.graphics.printf(winner.name .. " wins!", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
    love.graphics.printf("Press ENTER to restart", 0, love.graphics.getHeight()/2 + 30, love.graphics.getWidth(), "center")
end

function EndState:keypressed(key)
    if key == "return" then
        self.game.turn = 1
        self.game.player1:reset()
        self.game.player2:reset()
        self.game:changeState("MenuState")
    end
end

function EndState:exit() end

return EndState