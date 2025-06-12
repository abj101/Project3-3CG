local Card = {}
Card.__index = Card

local prototypes = {}

-- Register a prototype
function Card.define(id, cost, power, text)
    local proto = setmetatable({ id = id, cost = cost, power = power, text = text, w = 60, h = 90 }, Card)
    prototypes[id] = proto
    return proto
end

-- Clone a prototype
function Card:clone()
    local copy = setmetatable({}, Card)
    for k,v in pairs(self) do copy[k] = v end
    copy.x = self.x or 0
    copy.y = self.y or 0
    copy.slot = nil
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

return Card
