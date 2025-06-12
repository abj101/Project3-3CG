local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new(factories)
    return setmetatable({ stateFactories = factories, current = nil }, StateMachine)
end

function StateMachine:change(name)
    assert(self.stateFactories[name], "Unknown state: "..name)
    if self.current and self.current.exit then self.current:exit() end
    self.current = self.stateFactories[name]() 
    if self.current.enter then self.current:enter() end
end

function StateMachine:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function StateMachine:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

return StateMachine