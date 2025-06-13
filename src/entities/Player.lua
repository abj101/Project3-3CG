local Player = {}
Player.__index = Player

function Player:new(name)
    local o = { 
        name = name, 
        deck = {}, 
        hand = {}, 
        discardPile = {},
        points = 0, 
        mana = 0 
    }
    setmetatable(o, Player)
    return o
end

function Player:reset()
    -- Build deck with mythological cards
    self.deck = {}
    local cardIds = {
        "WoodenCow", "WoodenCow", "Pegasus", "Minotaur", "Minotaur", "Titan", "Zeus", "Ares", 
        "Medusa", "Cyclops", "Cyclops", "Poseidon", "Artemis", "Artemis", "Hera", "Demeter", 
        "Hades", "Hercules", "Medusa", "Pegasus"
    }
    
    -- Create multiple copies of each card for variety
    for i = 1, 20 do
        local id = cardIds[((i-1) % #cardIds) + 1]
        local Card = require("src.entities.Card")
        table.insert(self.deck, Card.new(id))
    end
    
    -- Shuffle deck
    for i = #self.deck, 2, -1 do
        local j = math.random(i)
        self.deck[i], self.deck[j] = self.deck[j], self.deck[i]
    end
    
    self.hand = {}
    self.discardPile = {}
    
    -- Draw starting hand
    for i = 1, 3 do 
        self:draw() 
    end
    
    self.points = 0
    self.mana = 1
end

function Player:draw()
    if #self.hand < 7 and #self.deck > 0 then
        table.insert(self.hand, table.remove(self.deck, 1))
    end
end

function Player:play(card)
    for i, c in ipairs(self.hand) do
        if c == card then 
            table.remove(self.hand, i)
            break 
        end
    end
end

return Player