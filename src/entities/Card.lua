local Card = {}
Card.__index = Card

local prototypes = {}

-- Register a prototype
function Card.define(id, cost, power, name, text, ability)
    local proto = setmetatable({ 
        id = id, 
        cost = cost, 
        basePower = power, 
        power = power,
        name = name,
        text = text, 
        ability = ability,
        w = 60, 
        h = 90,
        powerModifier = 0,
        revealed = false,
    }, Card)
    prototypes[id] = proto
    return proto
end

-- Clone a prototype
function Card:clone()
    local copy = setmetatable({}, Card)
    for k,v in pairs(self) do 
        if type(v) ~= "function" then
            copy[k] = v 
        end
    end
    copy.x = self.x or 0
    copy.y = self.y or 0
    copy.slot = nil
    copy.power = self.basePower
    copy.powerModifier = 0
    copy.revealed = false
    return copy
end

-- Create instance by id
function Card.new(id)
    assert(prototypes[id], "Unknown card: "..id)
    return prototypes[id]:clone()
end

-- Called when picked up
function Card:pickUp()
    self.slot = nil
end

-- Reset to original slot or hand
function Card:reset()
    if self.originX and self.originY then
        self.x = self.originX
        self.y = self.originY
    end
end

-- Apply power modifier
function Card:modifyPower(amount)
    self.powerModifier = self.powerModifier + amount
    self.power = math.max(0, self.basePower + self.powerModifier)
end

-- Reset power to base
function Card:resetPower()
    self.powerModifier = 0
    self.power = self.basePower
end

-- Trigger card ability when revealed
function Card:triggerAbility(game, location, player, opponent)
    if self.revealed or not self.ability then return end
    self.revealed = true
    
    local p1Slots = game.p1Slots
    local p2Slots = game.p2Slots
    local isPlayer1 = (player == game.player1)
    local mySlots = isPlayer1 and p1Slots or p2Slots
    local enemySlots = isPlayer1 and p2Slots or p1Slots
    
    if self.id == "Zeus" then
        -- Lower the power of each card in opponent's hand by 1
        for _, card in ipairs(opponent.hand) do
            card:modifyPower(-1)
        end
        
    elseif self.id == "Ares" then
        -- Gain +2 power for each enemy card here
        local enemyCards = enemySlots[location].cards
        local powerGain = #enemyCards * 2
        self:modifyPower(powerGain)
        
    elseif self.id == "Medusa" then
        -- When ANY other card is played here, lower that card's power by 1
        -- This is handled in the placement logic
        
    elseif self.id == "Cyclops" then
        -- Discard other cards here, gain +2 power for each discarded
        local myCards = mySlots[location].cards
        local cardsToDiscard = {}
        for _, card in ipairs(myCards) do
            if card ~= self then
                table.insert(cardsToDiscard, card)
            end
        end
        
        -- Remove discarded cards and add to discard pile
        for _, card in ipairs(cardsToDiscard) do
            for i, c in ipairs(myCards) do
                if c == card then
                    table.remove(myCards, i)
                    table.insert(player.discardPile or {}, card)
                    break
                end
            end
        end
        
        -- Gain power
        self:modifyPower(#cardsToDiscard * 2)
        
    elseif self.id == "Poseidon" then
        -- Move away an enemy card here with the lowest power
        local enemyCards = enemySlots[location].cards
        if #enemyCards > 0 then
            local lowestCard = enemyCards[1]
            for _, card in ipairs(enemyCards) do
                if card.power < lowestCard.power then
                    lowestCard = card
                end
            end
            
            -- Remove from current location and add back to opponent's hand
            for i, card in ipairs(enemyCards) do
                if card == lowestCard then
                    table.remove(enemyCards, i)
                    table.insert(opponent.hand, card)
                    -- Refund mana
                    if isPlayer1 then
                        game.player2.mana = game.player2.mana + card.cost
                    else
                        game.player1.mana = game.player1.mana + card.cost
                    end
                    break
                end
            end
        end
        
    elseif self.id == "Artemis" then
        -- Gain +5 power if there is exactly one enemy card here
        local enemyCards = enemySlots[location].cards
        if #enemyCards == 1 then
            self:modifyPower(5)
        end
        
    elseif self.id == "Hera" then
        -- Give cards in your hand +1 power
        for _, card in ipairs(player.hand) do
            card:modifyPower(1)
        end
        
    elseif self.id == "Demeter" then
        -- Both players draw a card
        game.player1:draw()
        game.player2:draw()
        
    elseif self.id == "Hades" then
        -- Gain +2 power for each card in your discard pile
        local discardCount = #(player.discardPile or {})
        self:modifyPower(discardCount * 2)
        
    elseif self.id == "Hercules" then
        -- Doubles its power if its the strongest card here
        local allCards = {}
        for _, card in ipairs(mySlots[location].cards) do
            table.insert(allCards, card)
        end
        for _, card in ipairs(enemySlots[location].cards) do
            table.insert(allCards, card)
        end
        
        local isStrongest = true
        for _, card in ipairs(allCards) do
            if card ~= self and card.power >= self.power then
                isStrongest = false
                break
            end
        end
        
        if isStrongest then
            self:modifyPower(self.power) -- Double the power
        end
    end
end

return Card