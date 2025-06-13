local RevealState = {}
RevealState.__index = RevealState

function RevealState:new(game)
    return setmetatable({ game = game }, RevealState)
end

function RevealState:enter()
    local g = self.game
    local p1, p2 = g.player1, g.player2
    
    -- Reset all card powers to base values
    for loc = 1, 3 do
        for _, card in ipairs(g.p1Slots[loc].cards) do
            card:resetPower()
        end
        for _, card in ipairs(g.p2Slots[loc].cards) do
            card:resetPower()
        end
    end
    
    -- Trigger card abilities for each location
    for loc = 1, 3 do
        -- Trigger abilities for all cards in this location
        for _, card in ipairs(g.p1Slots[loc].cards) do
            card:triggerAbility(g, loc, p1, p2)
        end
        for _, card in ipairs(g.p2Slots[loc].cards) do
            card:triggerAbility(g, loc, p2, p1)
        end
    end
    
    -- Compute per location after abilities
    for loc = 1, 3 do
        local sum1, sum2 = 0, 0
        for _, c in ipairs(g.p1Slots[loc].cards) do 
            sum1 = sum1 + c.power 
        end
        for _, c in ipairs(g.p2Slots[loc].cards) do 
            sum2 = sum2 + c.power 
        end
        
        -- Handle ties with random winner
        if sum1 == sum2 then
            if math.random(2) == 1 then 
                sum1 = sum1 + 1 
            else 
                sum2 = sum2 + 1 
            end
        end
        
        -- Award points based on power difference
        if sum1 > sum2 then
            p1.points = p1.points + (sum1 - sum2)
        else
            p2.points = p2.points + (sum2 - sum1)
        end
    end
    
    -- Move played cards to discard piles
    for loc = 1, 3 do
        for _, card in ipairs(g.p1Slots[loc].cards) do
            table.insert(p1.discardPile, card)
        end
        for _, card in ipairs(g.p2Slots[loc].cards) do
            table.insert(p2.discardPile, card)
        end
    end
    
    -- Check win condition
    local t1, t2 = p1.points >= g.winningScore, p2.points >= g.winningScore
    if t1 or t2 then
        self.winner = (p1.points > p2.points) and p1 or p2
        g:changeState("EndState") 
        return
    else
        g.turn = g.turn + 1
    end
    
    g:changeState("PlayState")
end

function RevealState:update(dt) end
function RevealState:draw() end
function RevealState:keypressed() end
function RevealState:exit() end

return RevealState