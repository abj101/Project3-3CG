local RevealState = {}
RevealState.__index = RevealState

function RevealState:new(game)
    return setmetatable({ 
        game = game, 
        timer = 0, 
        displayDuration = 3.0,
        results = {}
    }, RevealState)
end

function RevealState:enter()
    local g = self.game
    local p1, p2 = g.player1, g.player2
    
    -- Add opponent cards (simple AI: play random cards)
    self:addOpponentCards()
    
    -- Store current state for display
    self.slots = {}
    for pid = 1, 2 do
        self.slots[pid] = {}
        for loc = 1, 3 do
            self.slots[pid][loc] = {
                cards = {},
                x = g.p1Slots[pid] and g.p1Slots[pid][loc].x or 0,
                y = g.p1Slots[pid] and g.p1Slots[pid][loc].y or 0,
                w = g.p1Slots[pid] and g.p1Slots[pid][loc].w or 200,
                h = g.p1Slots[pid] and g.p1Slots[pid][loc].h or 100
            }
            -- Copy cards from game slots
            if g.p1Slots[pid] and g.p1Slots[pid][loc] then
                for _, card in ipairs(g.p1Slots[pid][loc].cards) do
                    table.insert(self.slots[pid][loc].cards, card)
                end
            end
            if g.p2Slots[pid] and g.p2Slots[pid][loc] then
                for _, card in ipairs(g.p2Slots[pid][loc].cards) do
                    table.insert(self.slots[pid][loc].cards, card)
                end
            end
        end
    end
    
    -- Compute scores per location
    self.results = {}
    for loc = 1, 3 do
        local sum1, sum2 = 0, 0
        for _, c in ipairs(self.slots[1][loc].cards) do 
            sum1 = sum1 + c.power 
        end
        for _, c in ipairs(self.slots[2][loc].cards) do 
            sum2 = sum2 + c.power 
        end
        
        -- Handle ties
        local winner = nil
        if sum1 == sum2 then
            -- Random tiebreaker
            if math.random(2) == 1 then 
                sum1 = sum1 + 1
                winner = 1
            else 
                sum2 = sum2 + 1
                winner = 2
            end
        else
            winner = (sum1 > sum2) and 1 or 2
        end
        
        -- Award points
        if sum1 > sum2 then
            p1.points = p1.points + (sum1 - sum2)
        else
            p2.points = p2.points + (sum2 - sum1)
        end
        
        -- Store results for display
        self.results[loc] = {
            p1Power = sum1,
            p2Power = sum2,
            winner = winner,
            pointsAwarded = math.abs(sum1 - sum2)
        }
    end
    
    self.timer = 0
end

function RevealState:addOpponentCards()
    local g = self.game
    local p2 = g.player2
    
    -- Simple AI: play cards randomly up to available mana
    local availableMana = p2.mana
    local playableCards = {}
    
    -- Find cards that can be played
    for _, card in ipairs(p2.hand) do
        if card.cost <= availableMana then
            table.insert(playableCards, card)
        end
    end
    
    -- Play cards randomly to random locations
    while availableMana > 0 and #playableCards > 0 do
        local cardIndex = math.random(#playableCards)
        local card = playableCards[cardIndex]
        local location = math.random(3)
        
        -- Find a location that isn't full
        local attempts = 0
        while #g.p2Slots[2][location].cards >= 4 and attempts < 3 do
            location = math.random(3)
            attempts = attempts + 1
        end
        
        -- If we found a valid location, play the card
        if #g.p2Slots[2][location].cards < 4 then
            table.insert(g.p2Slots[2][location].cards, card)
            availableMana = availableMana - card.cost
            
            -- Remove card from hand and playable cards
            for i, handCard in ipairs(p2.hand) do
                if handCard == card then
                    table.remove(p2.hand, i)
                    break
                end
            end
            table.remove(playableCards, cardIndex)
            
            -- Update playable cards based on remaining mana
            for i = #playableCards, 1, -1 do
                if playableCards[i].cost > availableMana then
                    table.remove(playableCards, i)
                end
            end
        else
            break -- No valid locations, stop trying
        end
    end
end

function RevealState:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.displayDuration then
        local g = self.game
        
        -- Check for game end
        local p1, p2 = g.player1, g.player2
        if p1.points >= g.winningScore or p2.points >= g.winningScore then
            g:changeState("EndState")
            return
        end
        
        -- Continue to next turn
        g.turn = g.turn + 1
        g:changeState("PlayState")
    end
end

function RevealState:draw()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Background
    love.graphics.setColor(0.03, 0.03, 0.08)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    local titleFont = love.graphics.newFont(24)
    love.graphics.setFont(titleFont)
    love.graphics.printf("BATTLE RESULTS", 0, 50, screenW, "center")
    
    -- Draw locations and cards
    local locationNames = {"The Peak", "Sanctum", "Wakanda"}
    for loc = 1, 3 do
        local x = 50 + (loc - 1) * (screenW - 100) / 3
        local y = 150
        local w = (screenW - 150) / 3
        local h = 300
        
        -- Location background
        love.graphics.setColor(0.1, 0.1, 0.2)
        love.graphics.rectangle("fill", x, y, w, h, 8)
        love.graphics.setColor(0.6, 0.4, 0.2)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, w, h, 8)
        
        -- Location name
        love.graphics.setColor(1, 0.9, 0.7)
        local nameFont = love.graphics.newFont(16)
        love.graphics.setFont(nameFont)
        love.graphics.printf(locationNames[loc], x, y + 10, w, "center")
        
        -- Player 2 cards (top)
        love.graphics.setColor(0.8, 0.4, 0.4)
        love.graphics.printf("Player 2", x, y + 40, w, "center")
        self:drawLocationCards(self.slots[2][loc].cards, x + 10, y + 60, w - 20, 80)
        
        -- Player 1 cards (bottom)
        love.graphics.setColor(0.4, 0.4, 0.8)
        love.graphics.printf("Player 1", x, y + 160, w, "center")
        self:drawLocationCards(self.slots[1][loc].cards, x + 10, y + 180, w - 20, 80)
        
        -- Results
        local result = self.results[loc]
        if result then
            love.graphics.setColor(1, 1, 1)
            local resultFont = love.graphics.newFont(14)
            love.graphics.setFont(resultFont)
            
            local resultText = string.format("P1: %d vs P2: %d", result.p1Power, result.p2Power)
            love.graphics.printf(resultText, x, y + h - 60, w, "center")
            
            local winnerColor = result.winner == 1 and {0.4, 0.8, 0.4} or {0.8, 0.4, 0.4}
            love.graphics.setColor(winnerColor)
            local winnerText = string.format("Player %d wins! (+%d pts)", result.winner, result.pointsAwarded)
            love.graphics.printf(winnerText, x, y + h - 35, w, "center")
        end
    end
    
    -- Current scores
    love.graphics.setColor(1, 1, 1)
    local scoreFont = love.graphics.newFont(18)
    love.graphics.setFont(scoreFont)
    local scoreText = string.format("Scores - Player 1: %d | Player 2: %d", 
                                   self.game.player1.points, self.game.player2.points)
    love.graphics.printf(scoreText, 0, screenH - 100, screenW, "center")
    
    -- Continue instruction
    local timeLeft = self.displayDuration - self.timer
    local instrFont = love.graphics.newFont(14)
    love.graphics.setFont(instrFont)
    local instrText = string.format("Continuing in %.1f seconds...", timeLeft)
    love.graphics.printf(instrText, 0, screenH - 60, screenW, "center")
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function RevealState:drawLocationCards(cards, x, y, w, h)
    if #cards == 0 then
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.printf("No cards", x, y + h/2 - 10, w, "center")
        return
    end
    
    local cardW = math.min(40, w / math.max(#cards, 4))
    local cardH = cardW * 1.5
    local spacing = math.min(cardW + 5, w / #cards)
    local startX = x + (w - (spacing * (#cards - 1) + cardW)) / 2
    
    for i, card in ipairs(cards) do
        local cardX = startX + (i - 1) * spacing
        local cardY = y + (h - cardH) / 2
        
        -- Card background
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", cardX, cardY, cardW, cardH, 2)
        
        -- Card border
        love.graphics.setColor(0.6, 0.6, 0.8)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", cardX, cardY, cardW, cardH, 2)
        
        -- Power
        love.graphics.setColor(1, 1, 1)
        local powerFont = love.graphics.newFont(math.max(8, cardW * 0.3))
        love.graphics.setFont(powerFont)
        love.graphics.printf(tostring(card.power), cardX, cardY + cardH - 20, cardW, "center")
    end
end

function RevealState:keypressed(key)
    if key == "space" or key == "return" then
        -- Allow skipping the reveal
        local g = self.game
        if g.player1.points >= g.winningScore or g.player2.points >= g.winningScore then
            g:changeState("EndState")
        else
            g.turn = g.turn + 1
            g:changeState("PlayState")
        end
    end
end

function RevealState:exit() end

return RevealState