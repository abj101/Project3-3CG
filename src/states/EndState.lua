local EndState = {}
EndState.__index = EndState

function EndState:new(game)
    return setmetatable({ game = game }, EndState)
end

function EndState:enter() end

function EndState:update(dt) end

function EndState:draw()
    local p1 = self.game.player1
    local p2 = self.game.player2
    local winner = (p1.points > p2.points) and p1 or p2

    -- Draw winner message
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(winner.name .. " wins!", 0, love.graphics.getHeight()/2 - 60, love.graphics.getWidth(), "center")

    -- Draw the final score for both players
    love.graphics.setFont(love.graphics.newFont(18))
    local scoreText = string.format("Final Score\n%s: %d  -  %s: %d", p1.name, p1.points, p2.name, p2.points)
    love.graphics.printf(scoreText, 0, love.graphics.getHeight()/2 - 10, love.graphics.getWidth(), "center")

    -- Draw restart prompt
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Press ENTER to restart", 0, love.graphics.getHeight()/2 + 60, love.graphics.getWidth(), "center")
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