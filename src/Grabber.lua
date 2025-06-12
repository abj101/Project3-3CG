-- src/Grabber.lua
local Grabber = {}
Grabber.__index = Grabber

-- Utility: check if point inside rect
local function inside(x,y,rect)
    return x >= rect.x and x <= rect.x+rect.w and y >= rect.y and y <= rect.y+rect.h
end

function Grabber:new(context)
    return setmetatable({ target = nil, _dragging = false, context = context }, Grabber)
end

function Grabber:update()
    local x,y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        if not self._dragging then
            self:grab(x,y)
            self._dragging = true
        else
            self:move(x,y)
        end
    elseif self._dragging then
        self:drop(x,y)
        self._dragging = false
    end
end

function Grabber:grab(x,y)
    local card = self:findCardAt(x,y)
    if card then
        self.target = card
        card:pickUp()
    end
end

function Grabber:move(x,y)
    if self.target then
        self.target.x = x - self.target.w/2
        self.target.y = y - self.target.h/2
    end
end

function Grabber:drop(x,y)
    if not self.target then return end
    local slot = self:findSlotAt(x,y)
    if slot and slot:canAccept(self.target) then
        slot:place(self.target)
    else
        self.target:reset()
    end
    self.target = nil
end

function Grabber:findCardAt(x,y)
    return self.context:cardAt(x,y)
end

function Grabber:findSlotAt(x,y)
    return self.context:slotAt(x,y)
end

return Grabber
