local Grabber = require "src.Grabber"
local PlayState = {}
PlayState.__index = PlayState

function PlayState:new(game)
    local o = { game = game, grabber = nil, slots = {} }
    setmetatable(o, PlayState)
    return o
end

function PlayState:enter()
    -- setup players for this turn
    local g = self.game
    g.player1.mana = g.turn
    g.player2.mana = g.turn
    g.player1:draw()
    g.player2:draw()

    -- create slots: 2 players x 3 locations x max 4
    self.slots = {}
    for pid=1,2 do
        self.slots[pid] = {}
        for loc=1,3 do
            self.slots[pid][loc] = { cards = {}, x = 100 + (loc-1)*200 + (pid-1)*600, y = 200, w = 60, h = 90 }
        end
    end

    self.grabber = Grabber:new(self)
end

function PlayState:update(dt)
    self.grabber:update()
end

function PlayState:draw()
    -- draw players' hands and slots
    love.graphics.print("Turn "..self.game.turn, 10, 10)
    for pid,player in ipairs({self.game.player1,self.game.player2}) do
        -- hand
        for i,card in ipairs(player.hand) do
            card.originX = 100 + (i-1)*70 + (pid-1)*600
            card.originY = (pid==1) and 500 or 650
            card.x,card.y,card.w,card.h = card.originX, card.originY, card.w, card.h
            love.graphics.rectangle("line", card.x, card.y, card.w, card.h)
            love.graphics.print(card.id, card.x+5, card.y+5)
        end
    end
    -- slots
    for pid,locs in pairs(self.slots) do
        for loc,slot in pairs(locs) do
            love.graphics.rectangle("line", slot.x, slot.y, slot.w*4 + 10, slot.h)
            for idx,card in ipairs(slot.cards) do
                love.graphics.rectangle("line", slot.x + (idx-1)*(slot.w+5), slot.y, slot.w, slot.h)
                love.graphics.print(card.id, slot.x + (idx-1)*(slot.w+5)+5, slot.y+5)
            end
        end
    end
end

function PlayState:keypressed(key)
    if key == "return" then self:submit() end
end

function PlayState:submit()
    -- store staged cards
    self.game.p1Slots = self.slots[1]
    self.game.p2Slots = self.slots[2]
    self.game:changeState("RevealState")
end

-- Helpers for Grabber
function PlayState:cardAt(x,y)
    for pid,player in ipairs({self.game.player1,self.game.player2}) do
        for _,card in ipairs(player.hand) do
            if x>=card.x and x<=card.x+card.w and y>=card.y and y<=card.y+card.h then return card end
        end
    end
end

function PlayState:slotAt(x,y)
    for pid,locs in pairs(self.slots) do
        for loc,slot in pairs(locs) do
            -- slot area
            local rect = { x=slot.x, y=slot.y, w=slot.w*4+10, h=slot.h }
            if x>=rect.x and x<=rect.x+rect.w and y>=rect.y and y<=rect.y+rect.h then
                slot.canAccept = function(_,card) return #slot.cards<4 and card.cost<= (self.game['player'..pid].mana) end
                slot.place = function(_,card)
                    table.insert(slot.cards, card)
                    self.game['player'..pid]:play(card)
                    self.game['player'..pid].mana = self.game['player'..pid].mana - card.cost
                    card.x = slot.x + (#slot.cards-1)*(slot.w+5)
                    card.y = slot.y
                end
                return slot
            end
        end
    end
end

function PlayState:exit() end

return PlayState
