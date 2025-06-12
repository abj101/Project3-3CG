local Player = {}
Player.__index = Player

function Player:new(name)
    local o = { name = name, deck = {}, hand = {}, points = 0, mana = 0 }
    setmetatable(o, Player)
    return o
end

function Player:reset()
    -- build deck: 20 random cards
    self.deck = {}
    for i=1,20 do
        local id = (i%3==1 and "C1") or (i%3==2 and "C2") or "C3"
        table.insert(self.deck, require("src.entities.Card").new(id))
    end
    -- shuffle
    for i = #self.deck, 2, -1 do
        local j = math.random(i)
        self.deck[i], self.deck[j] = self.deck[j], self.deck[i]
    end
    self.hand = {}
    -- draw 3 to start
    for i=1,3 do self:draw() end
    self.points = 0
    self.mana = 1
end

function Player:draw()
    if #self.hand < 7 and #self.deck > 0 then
        table.insert(self.hand, table.remove(self.deck,1))
    end
end

function Player:play(card)
    for i,c in ipairs(self.hand) do
        if c == card then table.remove(self.hand, i); break end
    end
end

return Player