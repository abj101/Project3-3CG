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
    
    -- Reset players if this is turn 1 (first time entering PlayState)
    if g.turn == 1 then
        g.player1:reset()
        g.player2:reset()
    end
    
    g.player1.mana = g.turn
    g.player2.mana = g.turn
    g.player1:draw()
    g.player2:draw()

    -- Get screen dimensions
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Reserve space for player 1 hand area (bottom) and player 2 info (top)
    local handHeight = 140
    local player2InfoHeight = 40
    local gameAreaH = screenH - handHeight - player2InfoHeight - 30
    
    self.submitButton = {
        x = 20,
        y = screenH / 2 - 30,
        w = 80,
        h = 60
    }
    
    -- Calculate larger location dimensions to use more space
    local locationW = math.min(260, (screenW - 60) / 3.2)
    local locationH = math.min(gameAreaH - 20, 320)
    local locationSpacing = math.max(15, (screenW - locationW * 3) / 4)
    
    -- Center locations in the game area
    local totalWidth = (locationW * 3) + (locationSpacing * 2)
    local startX = (screenW - totalWidth) / 2
    local centerY = player2InfoHeight + 20 + (gameAreaH / 2)
    
    -- create slots: 2 players x 3 locations (larger slots for 4 cards)
    self.slots = {}
    for pid = 1, 2 do
        self.slots[pid] = {}
        for loc = 1, 3 do
            local x = startX + (loc - 1) * (locationW + locationSpacing)
            local slotH = locationH * 0.42 -- Larger slot height
            -- Player 2 (top) gets negative offset, Player 1 (bottom) gets positive offset
            local y = centerY - slotH/2 + (pid == 2 and -slotH - 8 or slotH + 8)
            
            self.slots[pid][loc] = { 
                cards = {}, 
                x = x + 8, -- Inset from location border
                y = y,
                w = locationW - 16, -- Account for inset
                h = slotH,
                locationId = loc,
                playerId = pid
            }
        end
    end

    self.grabber = Grabber:new(self)
    
    -- Initialize hand card positions
    self:initializeHandPositions()
end

function PlayState:initializeHandPositions()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local handHeight = 140
    local handBoxW = screenW - 20
    local handBoxH = handHeight - 10
    local handCardW = math.min(80, (screenW - 120) / 8)
    local handCardH = handCardW * 1.3
    
    local player = self.game.player1
    local cardAreaH = handBoxH - 25
    local cardY = screenH - handBoxH - 5 + (cardAreaH - handCardH) / 2
    
    local maxHandCards = math.floor((handBoxW - 40) / (handCardW + 5))
    local actualCards = math.min(#player.hand, maxHandCards)
    
    if actualCards > 0 then
        local totalHandW = actualCards * handCardW + (actualCards - 1) * 5
        local handStartX = 10 + (handBoxW - totalHandW) / 2
        
        -- Set initial positions for all hand cards
        for i, card in ipairs(player.hand) do
            if i <= maxHandCards then
                card.originX = handStartX + (i - 1) * (handCardW + 5)
                card.originY = cardY
                card.x = card.originX
                card.y = card.originY
                card.w = handCardW
                card.h = handCardH
            end
        end
    end
end

function PlayState:update(dt)
    self.grabber:update()
end

function PlayState:drawCard(card, x, y, w, h, isInHand)
    local cardW = w or 60
    local cardH = h or 80
    
    -- Ensure card stays within bounds
    x = math.max(0, math.min(x, love.graphics.getWidth() - cardW))
    y = math.max(0, math.min(y, love.graphics.getHeight() - cardH))
    
    -- Card shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", x + 2, y + 2, cardW, cardH, 4)
    
    -- Card background
    love.graphics.setColor(0.15, 0.15, 0.25)
    love.graphics.rectangle("fill", x, y, cardW, cardH, 4)
    
    -- Card border with rarity color
    local borderColor = {0.4, 0.6, 1} -- Blue for common
    if card.id == "C2" then borderColor = {0.6, 0.4, 1} -- Purple for uncommon
    elseif card.id == "C3" then borderColor = {1, 0.6, 0.2} end -- Orange for rare
    
    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, cardW, cardH, 4)
    
    -- Card art area (proportional)
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", x + 2, y + 2, cardW - 4, cardH * 0.6, 2)
    
    -- Cost crystal (top left) - scaled
    local crystalSize = math.min(10, cardW * 0.15)
    love.graphics.setColor(0.2, 0.4, 0.8)
    love.graphics.circle("fill", x + crystalSize + 3, y + crystalSize + 3, crystalSize)
    love.graphics.setColor(1, 1, 1)
    local fontSize = math.max(8, crystalSize * 0.8)
    love.graphics.setFont(love.graphics.newFont(fontSize))
    love.graphics.printf(tostring(card.cost), x + 3, y + crystalSize - 2, crystalSize * 2, "center")
    
    -- Power crystal (bottom right) - scaled
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.circle("fill", x + cardW - crystalSize - 3, y + cardH - crystalSize - 3, crystalSize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(tostring(card.power), x + cardW - crystalSize * 2, y + cardH - crystalSize - 2, crystalSize * 2, "center")
    
    -- Card name - scaled font
    love.graphics.setColor(1, 1, 1)
    local nameFont = math.max(8, cardW * 0.12)
    love.graphics.setFont(love.graphics.newFont(nameFont))
    love.graphics.printf(card.text, x + 2, y + cardH * 0.68, cardW - 4, "center")
    
    -- Hover effect for hand cards
    if isInHand then
        local mx, my = love.mouse.getPosition()
        if mx >= x and mx <= x + cardW and my >= y and my <= y + cardH then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.rectangle("fill", x, y, cardW, cardH, 4)
        end
    end
end

function PlayState:drawHandBox(player, x, y, w, h)
    -- Hand box background
    love.graphics.setColor(0.08, 0.08, 0.15, 0.95)
    love.graphics.rectangle("fill", x, y, w, h, 8)
    
    -- Hand box border
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 8)
    
    -- Player info section (at bottom of hand box)
    local infoH = 25
    local infoY = y + h - infoH
    
    -- Player info background
    love.graphics.setColor(0.12, 0.12, 0.2)
    love.graphics.rectangle("fill", x + 2, infoY + 2, w - 4, infoH - 4, 6)
    
    -- Player name and stats
    love.graphics.setColor(1, 1, 1)
    local infoFont = math.max(10, math.min(14, w * 0.025))
    love.graphics.setFont(love.graphics.newFont(infoFont))
    local infoText = player.name .. " | Mana: " .. player.mana .. " | Points: " .. player.points
    love.graphics.printf(infoText, x + 10, infoY + 8, w - 20, "center")
    
    return y -- Return card area start Y
end

function PlayState:drawSubmitButton()
    local btn = self.submitButton
    local mx, my = love.mouse.getPosition()
    local isHovered = mx >= btn.x and mx <= btn.x + btn.w and my >= btn.y and my <= btn.y + btn.h
    
    -- Button shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", btn.x + 3, btn.y + 3, btn.w, btn.h, 8)
    
    -- Button background
    if isHovered then
        love.graphics.setColor(0.3, 0.5, 0.8)
    else
        love.graphics.setColor(0.2, 0.4, 0.7)
    end
    love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 8)
    
    -- Button border
    love.graphics.setColor(0.4, 0.6, 0.9)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 8)
    
    -- Button text
    love.graphics.setColor(1, 1, 1)
    local buttonFont = love.graphics.newFont(14)
    love.graphics.setFont(buttonFont)
    love.graphics.printf("END\nTURN", btn.x, btn.y + btn.h/2 - 14, btn.w, "center")
end

function PlayState:drawPlayer2Info(player, x, y, w, h)
    -- Simple background
    love.graphics.setColor(0.08, 0.08, 0.15, 0.8)
    love.graphics.rectangle("fill", x, y, w, h, 6)
    
    -- Border
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 6)
    
    -- Player name and stats
    love.graphics.setColor(1, 1, 1)
    local infoFont = math.max(12, math.min(16, w * 0.025))
    love.graphics.setFont(love.graphics.newFont(infoFont))
    local infoText = player.name .. " | Mana: " .. player.mana .. " | Points: " .. player.points
    love.graphics.printf(infoText, x + 10, y + (h - 16) / 2, w - 20, "center")
end

function PlayState:drawLocation(locationId, x, y, w, h)
    local locationNames = {"The Peak", "Sanctum", "Wakanda"}
    
    -- Location background
    love.graphics.setColor(0.08, 0.08, 0.18)
    love.graphics.rectangle("fill", x, y, w, h, 8)
    
    -- Location border
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 8)
    
    -- Location name header
    local headerH = 30
    love.graphics.setColor(0.12, 0.12, 0.25)
    love.graphics.rectangle("fill", x + 2, y + 2, w - 4, headerH, 6)
    
    -- Location name
    love.graphics.setColor(1, 0.9, 0.7)
    local nameFont = math.max(12, math.min(16, w * 0.08))
    love.graphics.setFont(love.graphics.newFont(nameFont))
    love.graphics.printf(locationNames[locationId], x + 5, y + 8, w - 10, "center")
    
    -- Player zones with better spacing
    local zoneStartY = y + headerH + 5
    local totalZoneH = h - headerH - 10
    local zoneH = (totalZoneH - 6) / 2
    
    -- Player 2 zone (top)
    love.graphics.setColor(0.35, 0.15, 0.25, 0.4)
    love.graphics.rectangle("fill", x + 8, zoneStartY, w - 16, zoneH, 4)
    love.graphics.setColor(0.45, 0.25, 0.35, 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 8, zoneStartY, w - 16, zoneH, 4)
    
    -- Player 1 zone (bottom)
    love.graphics.setColor(0.15, 0.25, 0.35, 0.4)
    love.graphics.rectangle("fill", x + 8, zoneStartY + zoneH + 6, w - 16, zoneH, 4)
    love.graphics.setColor(0.25, 0.35, 0.45, 0.6)
    love.graphics.rectangle("line", x + 8, zoneStartY + zoneH + 6, w - 16, zoneH, 4)
    
    -- Zone separator
    love.graphics.setColor(0.5, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    local midY = zoneStartY + zoneH + 3
    love.graphics.line(x + 8, midY, x + w - 8, midY)
end

function PlayState:draw()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Background
    love.graphics.setColor(0.03, 0.03, 0.08)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    -- Calculate dimensions
    local handHeight = 140
    local player2InfoHeight = 40
    local handCardW = math.min(80, (screenW - 120) / 8)
    local handCardH = handCardW * 1.3
    local locationCardW = math.min(65, handCardW * 0.85)
    local locationCardH = locationCardW * 1.3
    
    -- Draw player 2 info (top)
    self:drawPlayer2Info(self.game.player2, 10, 5, screenW - 20, player2InfoHeight)
    
    -- Draw player 1 hand box (bottom)
    local handBoxW = screenW - 20
    local handBoxH = handHeight - 10
    local p1HandY = self:drawHandBox(self.game.player1, 10, screenH - handBoxH - 5, handBoxW, handBoxH)
    
    self:drawSubmitButton()
    
    -- Draw locations
    for loc = 1, 3 do
        local slot = self.slots[2][loc] -- Use player 2 slot for top reference
        local locationY = slot.y - 40
        local locationH = (self.slots[1][loc].y + self.slots[1][loc].h) - locationY + 15
        self:drawLocation(loc, slot.x - 8, locationY, slot.w + 16, locationH)
    end
    
    -- Draw cards in locations with proper spacing for 4 cards
    for pid, locs in pairs(self.slots) do
        for loc, slot in pairs(locs) do
            local cardCount = #slot.cards
            if cardCount > 0 then
                local cardSpacing = math.min(locationCardW + 5, (slot.w - locationCardW) / math.max(1, cardCount - 1))
                local startX = slot.x + (slot.w - (locationCardW + cardSpacing * (cardCount - 1))) / 2
                
                for idx, card in ipairs(slot.cards) do
                    local cardX = startX + (idx - 1) * cardSpacing
                    local cardY = slot.y + (slot.h - locationCardH) / 2
                    
                    -- Ensure card fits in slot
                    cardX = math.max(slot.x, math.min(cardX, slot.x + slot.w - locationCardW))
                    
                    self:drawCard(card, cardX, cardY, locationCardW, locationCardH, false)
                end
            end
        end
    end
    
    -- Draw player 1 hand in bottom box
    local player = self.game.player1
    local cardAreaH = handBoxH - 25
    local cardY = p1HandY + (cardAreaH - handCardH) / 2
    
    local maxHandCards = math.floor((handBoxW - 40) / (handCardW + 5))
    local actualCards = math.min(#player.hand, maxHandCards)
    
    if actualCards > 0 then
        local totalHandW = actualCards * handCardW + (actualCards - 1) * 5
        local handStartX = 10 + (handBoxW - totalHandW) / 2
        
        -- Draw hand cards
        for i, card in ipairs(player.hand) do
            if i <= maxHandCards then
                -- Only set positions if card is not being dragged
                if not (self.grabber.target == card) then
                    card.originX = handStartX + (i - 1) * (handCardW + 5)
                    card.originY = cardY
                    card.x, card.y = card.originX, card.originY
                    card.w, card.h = handCardW, handCardH
                end
                
                -- Dim unplayable cards
                if card.cost > player.mana then
                    love.graphics.setColor(0.4, 0.4, 0.4)
                    self:drawCard(card, card.x, card.y, card.w, card.h, true)
                    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
                    love.graphics.rectangle("fill", card.x, card.y, card.w, card.h, 4)
                else
                    love.graphics.setColor(1, 1, 1)
                    self:drawCard(card, card.x, card.y, card.w, card.h, true)
                end
            end
        end
    end
    
    -- Turn info - positioned between player 2 info and locations
    love.graphics.setColor(1, 1, 1)
    local turnFont = math.max(14, math.min(20, screenW * 0.025))
    love.graphics.setFont(love.graphics.newFont(turnFont))
    love.graphics.printf("Turn " .. self.game.turn, 0, player2InfoHeight + 50, screenW/11, "center")
    
    -- Instructions - positioned above player 1 hand
    local instrFont = math.max(10, math.min(14, screenW * 0.018))
    love.graphics.setFont(love.graphics.newFont(instrFont))
    love.graphics.printf("Drag cards to locations • Press SUBMIT to end turn", 
                       0, screenH - handHeight - 25, screenW, "center")
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function PlayState:keypressed(key)
    if key == "return" then self:submit() end
end

function PlayState:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        local btn = self.submitButton
        if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
            self:submit()
        end
    end
end

function PlayState:submit()
    -- store staged cards - fix the reference
    self.game.p1Slots = self.slots
    self.game.p2Slots = self.slots  -- Both players use the same slot structure
    self.game:changeState("RevealState")
end

-- Helpers for Grabber
function PlayState:cardAt(x, y)
    -- Only check player 1's hand since they're the only one who can drag cards
    local player = self.game.player1
    for _, card in ipairs(player.hand) do
        if card.x and card.y and card.w and card.h then
            if x >= card.x and x <= card.x + card.w and y >= card.y and y <= card.y + card.h then 
                -- Only allow dragging if player can afford the card
                if card.cost <= player.mana then
                    return card 
                end
            end
        end
    end
end

function PlayState:slotAt(x, y)
    -- Only allow placing in player 1's slots
    local pid = 1
    local locs = self.slots[pid]
    for loc, slot in pairs(locs) do
        if x >= slot.x and x <= slot.x + slot.w and y >= slot.y and y <= slot.y + slot.h then
            slot.canAccept = function(_, card) 
                return #slot.cards < 4 and card.cost <= (self.game.player1.mana) 
            end
            slot.place = function(_, card)
                table.insert(slot.cards, card)
                self.game.player1:play(card)
                self.game.player1.mana = self.game.player1.mana - card.cost
            end
            return slot
        end
    end
end

function PlayState:exit() end

return PlayState