local StateMachine = require "src.StateMachine"
local MenuState    = require "src.states.MenuState"
local PlayState    = require "src.states.PlayState"
local RevealState  = require "src.states.RevealState"
local EndState     = require "src.states.EndState"
local Card         = require "src.entities.Card"
local Player       = require "src.entities.Player"

local Game = {}
Game.__index = Game

function Game:new()
    return setmetatable({ turn = 1, winningScore = 15 }, Game)
end

function Game:load()
    -- Define prototypes (extend these as needed)
    Card.define("C1", 1, 2, "Weakling")
    Card.define("C2", 2, 4, "Bruiser")
    Card.define("C3", 3, 6, "Champion")

    -- Players
    self.player1 = Player:new("Player 1")
    self.player2 = Player:new("Player 2")

    -- State machine
    self.states = StateMachine:new({
        ["MenuState"]  = function() return MenuState:new(self) end,
        ["PlayState"]  = function() return PlayState:new(self) end,
        ["RevealState"] = function() return RevealState:new(self) end,
        ["EndState"]   = function() return EndState:new(self) end,
    })
    self.states:change("MenuState")
end

function Game:update(dt)
    self.states:update(dt)
end

function Game:draw()
    self.states:draw()
end

function Game:keypressed(key)
    if self.states.current.keypressed then
        self.states.current:keypressed(key)
    end
end

function Game:changeState(name)
    self.states:change(name)
end

return Game
