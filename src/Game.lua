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
    love.window.setTitle("Mythological Card Clash")
    screenWidth = 1280
    screenHeight = 720
    love.window.setMode(screenWidth, screenHeight)
    
    -- Define mythological card prototypes
    Card.define("WoodenCow", 1, 1, "Wooden Cow", "A simple wooden decoy.")
    Card.define("Pegasus", 3, 5, "Pegasus", "The legendary winged horse.")
    Card.define("Minotaur", 5, 9, "Minotaur", "Half-man, half-bull beast.")
    Card.define("Titan", 6, 12, "Titan", "Ancient primordial giant.")
    Card.define("Zeus", 5, 8, "Zeus", "When Revealed: Lower the power of each card in your opponent's hand by 1.", "zeus")
    Card.define("Ares", 6, 7, "Ares", "When Revealed: Gain +2 power for each enemy card here.", "ares")
    Card.define("Medusa", 3, 4, "Medusa", "When ANY other card is played here, lower that card's power by 1.", "medusa")
    Card.define("Cyclops", 3, 5, "Cyclops", "When Revealed: Discard your other cards here, gain +2 power for each discarded.", "cyclops")
    Card.define("Poseidon", 4, 7, "Poseidon", "When Revealed: Move away an enemy card here with the lowest power.", "poseidon")
    Card.define("Artemis", 1, 0, "Artemis", "When Revealed: Gain +5 power if there is exactly one enemy card here.", "artemis")
    Card.define("Hera", 2, 3, "Hera", "When Revealed: Give cards in your hand +1 power.", "hera")
    Card.define("Demeter", 1, 2, "Demeter", "When Revealed: Both players draw a card.", "demeter")
    Card.define("Hades", 3, 3, "Hades", "When Revealed: Gain +2 power for each card in your discard pile.", "hades")
    Card.define("Hercules", 5, 10, "Hercules", "When Revealed: Doubles its power if its the strongest card here.", "hercules")

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

function Game:mousepressed(x, y, button)
    if self.states.current.mousepressed then
        self.states.current:mousepressed(x, y, button)
    end
end

function Game:changeState(name)
    self.states:change(name)
end

return Game
